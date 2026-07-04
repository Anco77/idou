import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/patterns_providers.dart';
import '../../theme/app_colors.dart';

class PatternsPage extends ConsumerWidget {
  const PatternsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(patternsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('图纸中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: '上传图纸',
            onPressed: () => context.push('/recognition/upload'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recognition/upload'),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.patterns.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('暂无图纸', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('上传图纸并确认扣除后，将自动保存到此处'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(patternsStateProvider.notifier).loadPatterns(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.patterns.length,
                    itemBuilder: (context, index) {
                      final pattern = state.patterns[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(pattern.originalImage),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          title: Text(
                            pattern.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            pattern.uploadTime.toString().substring(0, 16),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: pattern.isCompleted
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pattern.isCompleted ? '已完成' : '未完成',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: pattern.isCompleted ? AppColors.success : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () => context.go('/patterns/detail/${pattern.id}'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

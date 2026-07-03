import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_update_service.dart';
import '../providers/update_providers.dart';

class UpdateDialog extends ConsumerStatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0;
  String? _error;
  String? _installerPath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('版本 ${widget.updateInfo.version}'),
          const SizedBox(height: 8),
          Text(widget.updateInfo.releaseNotes),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      );
    }

    if (_installerPath != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('版本 ${widget.updateInfo.version}'),
          const SizedBox(height: 8),
          Text(widget.updateInfo.releaseNotes),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('下载完成，点击安装即可更新', style: TextStyle(color: Colors.green)),
            ],
          ),
        ],
      );
    }

    if (_isDownloading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('版本 ${widget.updateInfo.version}'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 8),
          Text('${(_progress * 100).toStringAsFixed(0)}%'),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('版本 ${widget.updateInfo.version} 可用'),
        const SizedBox(height: 8),
        Text(widget.updateInfo.releaseNotes),
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_error != null) {
      return [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        FilledButton(onPressed: _startDownload, child: const Text('重试')),
      ];
    }

    if (_installerPath != null) {
      return [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('稍后')),
        FilledButton(onPressed: _install, child: const Text('立即安装')),
      ];
    }

    if (_isDownloading) {
      return [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
      ];
    }

    return [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('稍后')),
      FilledButton(onPressed: _startDownload, child: const Text('立即更新')),
    ];
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    final service = ref.read(appUpdateServiceProvider);
    final path = await service.downloadUpdate((progress) {
      if (mounted) {
        setState(() => _progress = progress);
        ref.read(updateDownloadProvider.notifier).state = progress;
      }
    });

    if (!mounted) return;

    if (path != null) {
      setState(() {
        _installerPath = path;
        _isDownloading = false;
      });
    } else {
      setState(() {
        _error = '下载失败，请检查网络后重试';
        _isDownloading = false;
      });
    }
  }

  Future<void> _install() async {
    if (_installerPath == null) return;
    final service = ref.read(appUpdateServiceProvider);
    await service.installUpdate(_installerPath!);
  }
}

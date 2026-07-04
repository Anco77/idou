import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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

  bool get _isWindows => !Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    // Windows: show manual download message
    if (_isWindows) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('版本 ${widget.updateInfo.version} 可用'),
          const SizedBox(height: 8),
          Text(widget.updateInfo.releaseNotes),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Windows 版本请前往 GitHub Releases 页面手动下载安装',
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

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
    // Windows: only show guide button
    if (_isWindows) {
      return [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        FilledButton.icon(
          icon: const Icon(Icons.open_in_browser, size: 18),
          label: const Text('前往下载'),
          onPressed: () async {
            final url = Uri.parse(
              'https://github.com/Anco77/idou/releases/tag/v${widget.updateInfo.version}',
            );
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
            Navigator.pop(context);
          },
        ),
      ];
    }

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
    final success = await service.installUpdate(_installerPath!);
    if (mounted && success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('安装程序已启动，请完成安装')),
      );
    }
  }
}

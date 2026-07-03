import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LowStockBanner extends StatelessWidget {
  final int count;
  final int total;
  final VoidCallback? onTap;

  const LowStockBanner({
    super.key,
    required this.count,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final ratio = total > 0 ? count / total : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.lowStockBg,
          border: Border(
            bottom: BorderSide(color: AppColors.lowStock.withValues(alpha: 0.3)),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '有 $count 种色号库存不足 500 颗',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.warning, size: 20),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                backgroundColor: AppColors.lowStock.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

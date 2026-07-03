import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LowStockBanner extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const LowStockBanner({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.lowStockBg,
          border: Border(
            bottom: BorderSide(color: AppColors.lowStock.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
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
            const Icon(Icons.chevron_right, color: AppColors.warning, size: 20),
          ],
        ),
      ),
    );
  }
}

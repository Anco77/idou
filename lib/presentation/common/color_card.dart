import 'package:flutter/material.dart';
import '../../core/database/daos/inventory_dao.dart';
import '../theme/app_colors.dart';

class ColorCard extends StatelessWidget {
  final InventoryWithColor item;
  final VoidCallback? onAdd;
  final VoidCallback? onSubtract;
  final VoidCallback? onTap;

  const ColorCard({
    super.key,
    required this.item,
    this.onAdd,
    this.onSubtract,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = item.isLowStock;
    final color = Color.fromARGB(255, item.r, item.g, item.b);

    return Card(
      color: isLow ? AppColors.lowStockBg : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 颜色色块 + 低量标记
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '#${item.colorId.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (isLow)
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              // 数量
              Text(
                '${item.currentQty}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLow ? AppColors.lowStock : Colors.black87,
                ),
              ),
              Text(
                '颗',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const Spacer(),
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.remove,
                    onTap: onSubtract,
                    color: Colors.red.shade300,
                  ),
                  _ActionButton(
                    icon: Icons.add,
                    onTap: onAdd,
                    color: Colors.green.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

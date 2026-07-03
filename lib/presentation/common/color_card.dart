import 'package:flutter/material.dart';
import '../../core/database/daos/inventory_dao.dart';

enum _StockLevel { critical, low, medium, sufficient }

_StockLevel _stockLevel(int qty) {
  if (qty < 400) return _StockLevel.critical;
  if (qty < 700) return _StockLevel.low;
  if (qty < 1000) return _StockLevel.medium;
  return _StockLevel.sufficient;
}

Color _stockColor(_StockLevel level) {
  switch (level) {
    case _StockLevel.critical: return const Color(0xFFE53935);
    case _StockLevel.low: return const Color(0xFFFB8C00);
    case _StockLevel.medium: return const Color(0xFFFDD835);
    case _StockLevel.sufficient: return const Color(0xFF43A047);
  }
}

String _stockLabel(_StockLevel level) {
  switch (level) {
    case _StockLevel.critical: return '紧缺';
    case _StockLevel.low: return '较少';
    case _StockLevel.medium: return '适中';
    case _StockLevel.sufficient: return '充足';
  }
}

class ColorCard extends StatelessWidget {
  final InventoryWithColor item;
  final VoidCallback? onAdd;
  final VoidCallback? onSubtract;
  final VoidCallback? onSetQty;
  final VoidCallback? onTap;

  const ColorCard({
    super.key,
    required this.item,
    this.onAdd,
    this.onSubtract,
    this.onSetQty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color.fromARGB(255, item.r, item.g, item.b);
    final level = _stockLevel(item.currentQty);
    final slColor = _stockColor(level);
    final ratio = (item.currentQty / 1000).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final contentW = w - 12;

        final fontSizeMard = (w * 0.2).clamp(14.0, 36.0);
        final fontSizeQty = (w * 0.18).clamp(12.0, 32.0);
        final fontSizeUnit = (w * 0.065).clamp(8.0, 14.0);
        final fontSizeLabel = (w * 0.065).clamp(8.0, 14.0);
        final barHeight = (w * 0.055).clamp(4.0, 10.0);
        final btnSize = (contentW / 3.5).clamp(26.0, 48.0);
        final iconSize = btnSize * 0.5;

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onTap,
                        child: Column(
                          children: [
                            Text(
                              item.mardId,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeMard,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Colors.black54, blurRadius: 6),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: Container(
                                      height: barHeight,
                                      color: Colors.white24,
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: ratio,
                                        child: Container(color: slColor),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _stockLabel(level),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: fontSizeLabel,
                                          color: slColor,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    if (level == _StockLevel.critical) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.warning_amber_rounded,
                                          color: Colors.amber, size: 16),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${item.currentQty}',
                                        style: TextStyle(
                                          fontSize: fontSizeQty,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: const [
                                            Shadow(color: Colors.black54, blurRadius: 6),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: Text(
                                          '颗',
                                          style: TextStyle(
                                            fontSize: fontSizeUnit,
                                            color: Colors.white70,
                                            shadows: const [
                                              Shadow(color: Colors.black54, blurRadius: 4),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (onSubtract != null)
                          _ActionButton(
                            size: btnSize,
                            iconSize: iconSize,
                            icon: Icons.remove,
                            onTap: onSubtract,
                          ),
                        if (onSetQty != null)
                          _ActionButton(
                            size: btnSize,
                            iconSize: iconSize,
                            icon: Icons.edit_note,
                            onTap: onSetQty,
                          ),
                        if (onAdd != null)
                          _ActionButton(
                            size: btnSize,
                            iconSize: iconSize,
                            icon: Icons.add,
                            onTap: onAdd,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatefulWidget {
  final double size;
  final double iconSize;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.size,
    required this.iconSize,
    required this.icon,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, size: widget.iconSize, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

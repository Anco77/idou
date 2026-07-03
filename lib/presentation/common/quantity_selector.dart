import 'package:flutter/material.dart';

/// 数量选择器弹窗
class QuantitySelector extends StatefulWidget {
  final String title;
  final int initialValue;
  final bool allowCustom;

  const QuantitySelector({
    super.key,
    required this.title,
    this.initialValue = 1,
    this.allowCustom = true,
  });

  /// 显示选择器弹窗
  static Future<int?> show(BuildContext context, {
    String title = '选择数量',
    int initialValue = 1,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      builder: (context) => QuantitySelector(
        title: title,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _selected;
  final _customController = TextEditingController();
  bool _isCustom = false;

  static const _quickOptions = [1, 5, 10, 50, 100, 500];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
    _customController.text = widget.initialValue.toString();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // 快捷选项
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickOptions.map((opt) {
              final isSelected = !_isCustom && _selected == opt;
              return ChoiceChip(
                label: Text('$opt'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selected = opt;
                    _isCustom = false;
                  });
                },
              );
            }).toList(),
          ),
          if (widget.allowCustom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '自定义数量',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) {
                setState(() {
                  _isCustom = v.isNotEmpty;
                  _selected = int.tryParse(v) ?? 0;
                });
              },
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected > 0
                  ? () => Navigator.pop(context, _selected)
                  : null,
              child: Text('确认 ($_selected 颗)'),
            ),
          ),
        ],
      ),
    );
  }
}

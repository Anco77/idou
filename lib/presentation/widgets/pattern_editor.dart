import 'package:flutter/material.dart';

import '../../domain/models/pattern.dart';
import '../../domain/models/bead_color.dart';
import '../controllers/pattern_editor_controller.dart';

class PatternEditor extends StatefulWidget {
  final PatternEditorController controller;
  final List<BeadColor> palette;

  const PatternEditor({
    super.key,
    required this.controller,
    required this.palette,
  });

  @override
  State<PatternEditor> createState() => _PatternEditorState();
}

class _PatternEditorState extends State<PatternEditor> {
  int? _selectedColor;
  bool _showLabels = true;
  String _paletteQuery = '';

  @override
  Widget build(BuildContext context) {
    final grid = widget.controller.grid;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Undo',
              onPressed: widget.controller.canUndo ? _undo : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: 'Redo',
              onPressed: widget.controller.canRedo ? _redo : null,
              icon: const Icon(Icons.redo),
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '搜索色号',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (value) => setState(
                  () => _paletteQuery = value.trim().toLowerCase(),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Toggle labels',
              onPressed: () => setState(() => _showLabels = !_showLabels),
              icon: Icon(_showLabels ? Icons.grid_3x3 : Icons.grid_4x4),
            ),
          ],
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: widget.palette
                .where((color) =>
                    _paletteQuery.isEmpty ||
                    color.code.toLowerCase().contains(_paletteQuery) ||
                    color.displayName.toLowerCase().contains(_paletteQuery))
                .map((color) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Text(color.code),
                        selected: _selectedColor == color.id,
                        onSelected: (_) => setState(
                          () => _selectedColor = color.id,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => InteractiveViewer(
              constrained: false,
              minScale: .5,
              maxScale: 4,
              child: SizedBox(
                width: constraints.maxWidth,
                height: grid.rows * 28,
                child: GridView.builder(
                  key: const Key('pattern-grid'),
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grid.rows * grid.columns,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: grid.columns,
                    mainAxisExtent: 28,
                  ),
                  itemBuilder: (context, index) {
                    final row = index ~/ grid.columns;
                    final column = index % grid.columns;
                    final cell = grid.cellAt(row, column);
                    return InkWell(
                      key: ValueKey('pattern-cell-$row-$column'),
                      onTap: () => _toggleCell(row, column, cell),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cell == null
                              ? Colors.transparent
                              : _color(cell.color),
                          border: Border.all(color: Colors.black12),
                        ),
                        alignment: Alignment.center,
                        child: cell == null || !_showLabels
                            ? null
                            : Text(cell.color.code,
                                style: const TextStyle(fontSize: 8)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _color(BeadColor color) =>
      Color.fromARGB(255, color.red, color.green, color.blue);

  void _toggleCell(int row, int column, PatternCell? current) {
    final selected =
        widget.palette.where((color) => color.id == _selectedColor).firstOrNull;
    final next = selected == null
        ? null
        : PatternCell(color: selected, source: CellSource.manual);
    widget.controller.setCell(row, column, current == null ? next : null);
    setState(() {});
  }

  void _undo() {
    widget.controller.undo();
    setState(() {});
  }

  void _redo() {
    widget.controller.redo();
    setState(() {});
  }
}

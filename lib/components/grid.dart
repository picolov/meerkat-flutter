import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class Grid extends StatelessWidget {
  final List<Widget> children;
  final int rowSize;
  final int colSize;

  const Grid(
      {Key? key,
      required this.rowSize,
      required this.colSize,
      required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TrackSize> rowSizes = [];
    List<TrackSize> columnSizes = [];
    for (int i = 0; i < rowSize; i++) {
      rowSizes.add(1.fr);
    }
    for (int j = 0; j < rowSize; j++) {
      columnSizes.add(1.fr);
    }
    return LayoutGrid(
      columnSizes: columnSizes,
      rowSizes: rowSizes,
      children: children,
    );
  }
}

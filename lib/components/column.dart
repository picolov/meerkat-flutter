import 'package:flutter/material.dart';

class ColumnContainer extends StatelessWidget {
  final List<Widget> children;

  const ColumnContainer({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children,
    );
  }
}

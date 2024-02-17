import 'package:flutter/material.dart';

class RowContainer extends StatelessWidget {
  final List<Widget> children;

  const RowContainer({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}

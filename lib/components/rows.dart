import 'package:flutter/material.dart';

class Rows extends StatelessWidget {
  final List<Widget> children;

  const Rows({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}

import 'package:flutter/widgets.dart';

class Label extends StatelessWidget {
  final String text;
  final String align;
  final double size;

  const Label(
      {Key? key, required this.text, this.align = "left", this.size = 20.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: size),
      ),
    );
  }
}

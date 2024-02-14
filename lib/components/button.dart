import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? text;
  final Function? onClick;

  const Button({Key? key, this.text, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: onClick != null ? () => onClick!("button") : null,
        child: Text(text ?? " "),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? text;

  const Button({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () {
          print("on press");
        },
        child: Text(text ?? " "),
      ),
    );
  }
}

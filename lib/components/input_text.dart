import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  final String text;
  final void Function(String)? onChanged;
  const InputText({Key? key, required this.text, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    controller.text = text;
    return Flexible(
      child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 9),
            isDense: true,
            border: OutlineInputBorder(),
          )),
    );
  }
}

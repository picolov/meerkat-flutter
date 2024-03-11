import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:highlight/languages/xml.dart';

class CodeEditor extends StatelessWidget {
  final String text;
  final void Function(String)? onChanged;
  const CodeEditor({Key? key, required this.text, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = CodeController(
      text: '''
<column>
  <row>
    <label>Page Pertama</label>
    <button onClick="input.toUpperCase() + 'X'; ==> /text.addX">add a to text</button>
  </row>
  <column>
      <label onEvent="/text.addX ==> props.text = props.text + input">Will Changes</label>
    </column>
</column>
''',
      language: xml,
    );
    return Flexible(
      child: CodeTheme(
        data: CodeThemeData(styles: androidstudioTheme),
        child: SingleChildScrollView(
          child: CodeField(
            controller: controller,
          ),
        ),
      ),
    );
  }
}

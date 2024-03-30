import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:highlight/languages/xml.dart';

class CodeEditor extends StatefulWidget {
  final String text;
  final void Function(String)? onSaved;
  const CodeEditor({Key? key, required this.text, required this.onSaved})
      : super(key: key);

  @override
  _CodeEditorState createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late CodeController controller;
  late bool isDirty = false;

  @override
  void initState() {
    controller = CodeController(
      text:
          '''
<tabBar titles="Preview, Script, Setting">
  <componentLoader id="001"></componentLoader>
  <column>
    <codeEditor onSaved="editor.updated">content of code editor</codeEditor>
  </column>
  <column>
    <label>Setting</label>
  </column>
</tabBar>
''',
      language: xml,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Row(
            children: [
              OutlinedButton(
                  onPressed: isDirty
                      ? () {
                          if (widget.onSaved != null) {
                            widget.onSaved!(controller.fullText);
                          }
                        }
                      : null,
                  child: Text("Save")),
            ],
          ),
          CodeTheme(
            data: CodeThemeData(styles: androidstudioTheme),
            child: SingleChildScrollView(
              child: CodeField(
                controller: controller,
                onChanged: (event) {
                  setState(() {
                    isDirty = true;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'label.dart';
import 'button.dart';
import 'input_text.dart';
import 'rows.dart';

final Map<String, Function> widgetMaps = {
  "label": (Map<String, dynamic> attr) => Label(
        text: attr["text"],
      ),
  "button": (Map<String, dynamic> attr) => Button(
        text: attr["text"],
      ),
  "inputText": (Map<String, dynamic> attr) => InputText(
        text: attr["text"],
        onChanged: (value) {
          print('onchanged : $value');
        },
      ),
  "rows": (Map<String, dynamic> attr) => Rows(
        children: attr["children"],
      ),
};

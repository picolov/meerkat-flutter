import 'package:meerkat_flutter/event.dart';

import '../event_bus.dart';
import 'label.dart';
import 'button.dart';
import 'input_text.dart';
import 'row.dart';
import 'column.dart';

final Map<String, Function> widgetMaps = {
  "label": (Map<String, dynamic> attr) => Label(
        text: attr["text"],
      ),
  "button": (Map<String, dynamic> attr) => Button(
        text: attr["text"],
        onClick: (args) =>
            eventBus.fire(LocalEvent(attr["onclick"], {"args": args})),
      ),
  "inputText": (Map<String, dynamic> attr) => InputText(
        text: attr["text"],
        onChanged: (value) {
          print('onchanged : $value');
        },
      ),
  "row": (Map<String, dynamic> attr) => RowContainer(
        children: attr["children"],
      ),
  "column": (Map<String, dynamic> attr) => ColumnContainer(
        children: attr["children"],
      ),
};

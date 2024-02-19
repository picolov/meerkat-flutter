import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:meerkat_flutter/event.dart';

import '../event_bus.dart';
import 'label.dart';
import 'button.dart';
import 'input_text.dart';
import 'row.dart';
import 'column.dart';

Function runScriptThenSendEvent =
    (dynamic args, String scriptAndEventNameStr, JavascriptRuntime jsRuntime) {
  List<String> scriptAndEventNameArr =
      scriptAndEventNameStr.split("==>").map((datum) => datum.trim()).toList();
  if (scriptAndEventNameArr.length == 1) {
    print('scripts: NONE - so send whole args');
    eventBus.fire(Event(scriptAndEventNameArr[0], {"payload": args}));
  } else if (scriptAndEventNameArr.length == 2) {
    String jsonArgs = json.encode(args);
    String script =
        '{\nconst input = $jsonArgs;\n${scriptAndEventNameArr[0]};\n}';
    print('scripts: $script');
    JsEvalResult jsResult = jsRuntime.evaluate(script);

    eventBus
        .fire(Event(scriptAndEventNameArr[1], {"payload": jsResult.rawResult}));
  }
};

final Map<String, Function> widgetMaps = {
  "label": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime) =>
      Label(
        text: attr["text"],
      ),
  "button": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime) =>
      Button(
        text: attr["text"],
        onClick: (args) =>
            runScriptThenSendEvent(args, attr["onclick"], jsRuntime),
      ),
  "inputText": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime) =>
      InputText(
        text: attr["text"],
        onChanged: (value) {
          print('onchanged : $value');
        },
      ),
  "row": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime) =>
      RowContainer(
        children: children,
      ),
  "column": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime) =>
      ColumnContainer(
        children: children,
      ),
};

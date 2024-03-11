import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:meerkat_flutter/event.dart';
import 'package:sqflite/sqflite.dart';

import '../event_bus.dart';
import 'code_editor.dart';
import 'component_loader.dart';
import 'label.dart';
import 'button.dart';
import 'input_text.dart';
import 'row.dart';
import 'column.dart';
import 'tab_bar.dart';

Function runScriptThenSendEvent =
    (dynamic args, String scriptAndEventNameStr, JavascriptRuntime jsRuntime) {
  List<String> scriptAndEventNameArr =
      scriptAndEventNameStr.split("==>").map((datum) => datum.trim()).toList();
  if (scriptAndEventNameArr.length == 1) {
    // print('scripts: NONE - so send whole args');
    eventBus.fire(Event(scriptAndEventNameArr[0], {"payload": args}));
  } else if (scriptAndEventNameArr.length == 2) {
    String jsonArgs = json.encode(args);
    String script =
        '{\nconst input = $jsonArgs;\n${scriptAndEventNameArr[0]};\n}';
    // print('scripts: $script');
    JsEvalResult jsResult = jsRuntime.evaluate(script);

    eventBus
        .fire(Event(scriptAndEventNameArr[1], {"payload": jsResult.rawResult}));
  }
};

final Map<String, Function> widgetMaps = {
  "codeeditor": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      CodeEditor(
        text: attr["text"],
        onChanged: (value) {
          print('onchanged : $value');
        },
      ),
  "componentloader": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      ComponentLoader(
        componentId: attr["id"],
        jsRuntime: jsRuntime,
        database: database,
      ),
  "label": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      Label(
        text: attr["text"],
      ),
  "button": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      Button(
        text: attr["text"],
        onClick: (args) =>
            runScriptThenSendEvent(args, attr["onclick"], jsRuntime),
      ),
  "inputtext": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      InputText(
        text: attr["text"],
        onChanged: (value) {
          print('onchanged : $value');
        },
      ),
  "row": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      RowContainer(
        children: children,
      ),
  "column": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      ColumnContainer(
        children: children,
      ),
  "tabbar": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      TabBarContainer(
        titles:
            attr["titles"] != null ? (attr["titles"] as String).split(",") : [],
        children: children,
      ),
};

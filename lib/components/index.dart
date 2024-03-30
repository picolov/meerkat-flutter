import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:meerkat_flutter/event.dart';
import 'package:sqflite/sqflite.dart';

import '../event_bus.dart';
import 'code_editor.dart';
import 'ui_loader.dart';
import 'label.dart';
import 'button.dart';
import 'input_text.dart';
import 'row.dart';
import 'column.dart';
import 'tab_bar.dart';
import 'dropdown.dart';

Function runScriptThenSendEvent =
    (dynamic args, String scriptAndEventNameStr, JavascriptRuntime jsRuntime) {
  if (scriptAndEventNameStr.isNotEmpty) {
    List<String> scriptAndEventNameArr =
        scriptAndEventNameStr.split("->").map((datum) => datum.trim()).toList();
    if (scriptAndEventNameArr.length == 1) {
      // print('scripts: NONE - so send whole args');
      eventBus.fire(Event(scriptAndEventNameArr[0], {"payload": args}));
    } else if (scriptAndEventNameArr.length == 2) {
      String jsonArgs = json.encode(args);
      String script =
          '{\nconst input = $jsonArgs;\n${scriptAndEventNameArr[0]};\n}';
      // print('scripts: $script');
      JsEvalResult jsResult = jsRuntime.evaluate(script);

      eventBus.fire(
          Event(scriptAndEventNameArr[1], {"payload": jsResult.rawResult}));
    }
  } else {
    print("empty scripts");
  }
};

Function parseAttributeValue = (String value) {
  dynamic parsedValue;
  if (value.startsWith("[") && value.endsWith("]")) {
    parsedValue = value
        .substring(1, value.length - 1)
        .split(",")
        .map((datum) => datum.trim())
        .toList();
  }
  return parsedValue;
};

final Map<String, Function> widgetMaps = {
  "dropdown": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      Dropdown(
        options: parseAttributeValue(attr["options"]),
        onSelect: (args) {
          if (attr.containsKey("onselect")) {
            runScriptThenSendEvent(args, attr["onselect"], jsRuntime);
          }
        },
      ),
  "codeeditor": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      CodeEditor(
        text: attr["text"],
        onSaved: (args) {
          if (attr.containsKey("onsaved")) {
            runScriptThenSendEvent(args, attr["onsaved"], jsRuntime);
          }
        },
      ),
  "uiLoader": (Map<String, dynamic> attr, List<Widget> children,
          JavascriptRuntime jsRuntime, Database database) =>
      UILoader(
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
        onClick: (args) {
          if (attr.containsKey("onclick")) {
            runScriptThenSendEvent(args, attr["onclick"], jsRuntime);
          }
        },
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

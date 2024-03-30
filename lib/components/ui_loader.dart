import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:meerkat_flutter/component.dart';
import 'package:sqflite/sqflite.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

class UILoader extends StatelessWidget {
  final String componentId;
  final JavascriptRuntime jsRuntime;
  final Database database;

  const UILoader(
      {Key? key,
      required this.componentId,
      required this.jsRuntime,
      required this.database})
      : super(key: key);

  Future<Widget> getComponentFromDb() async {
    List<Map> componentPage = await database
        .rawQuery('SELECT * FROM Pages where id=?', [componentId]);
    String componentPageHtml =
        (componentPage.first['content'] as String).trim();
    dom.Document componentHtmlDoc = parse(componentPageHtml);
    dom.Element? componentElement = componentHtmlDoc.body?.children
        .firstWhere((element) => element.localName == "ui");
    if (componentElement != null) {
      return Component(
          pageEl: componentElement.children.first,
          jsRuntime: jsRuntime,
          database: database);
    } else {
      return Text("Error parsing $componentId");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (BuildContext ctx, AsyncSnapshot<Widget> snapshot) {
        if (ConnectionState.done == snapshot.connectionState) {
          return snapshot.data ?? Text("Comp ID:$componentId Not Found");
        } else {
          return const CircularProgressIndicator();
        }
      },
      future: getComponentFromDb(),
    );
  }
}

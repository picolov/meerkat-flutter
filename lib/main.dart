import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:sqflite/sqflite.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

import 'component.dart';
import 'event_bus.dart';
import 'event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a location using getDatabasesPath
// var databasesPath = await getDatabasesPath();
// String path = join(databasesPath, 'demo.db');

// Delete the database
  await deleteDatabase('data.db');

// open the database
  Database database = await openDatabase('data.db', version: 1,
      onCreate: (Database db, int version) async {
    await db.execute(
        'CREATE TABLE Pages (id TEXT PRIMARY KEY, name TEXT, desc TEXT, flags INTEGER, content TEXT)');
  });

// Insert some records in a transaction
  await database.transaction((txn) async {
    int id1 = await txn.rawInsert(
        'INSERT INTO Pages(id, name, desc, flags, content) VALUES(?,?,?,?,?)', [
      '001',
      'test01',
      'test page pertama',
      1,
      '''
<column>
    <row>
      <label>label01</label>
      <button onClick="label04.addA:return 'A';">add A to label04</button>
    </row>
    <column>
      <label>label02</label>
      <label>label03</label>
      <label onEvent="label04.addA:setProp('text', param.value);">label04</label>
    </column>
</column>
'''
    ]);
  });

  List<Map> defaultPage =
      await database.rawQuery('SELECT * FROM Pages where flags=?', [1]);
  String defaultPageHtml = (defaultPage.first['content'] as String).trim();
  dom.Document defaultHtmlDoc = parse(defaultPageHtml);
  dom.Element? rootElement = defaultHtmlDoc.body?.children.first;
  eventBus.on<Event>().listen((event) {
    // Print the runtime type. Such a set up could be used for logging.
    print('event [${event.uri}] - ${event.content}');
  });
  JavascriptRuntime jsRuntime = getJavascriptRuntime();
  jsRuntime.onMessage('methodChannel', (dynamic args) {
    var methodName = args['method'];
    var message = args['msg'];
    // print('method : ${methodName}');
    // print('msg    : ${message.runtimeType} - ${message}');
    switch (methodName) {
      case 'print':
        print(message);
        break;
      default:
    }
  });
  if (rootElement != null) {
    runApp(App(
      pageEl: rootElement,
      jsRuntime: jsRuntime,
    ));
  }
}

class App extends StatelessWidget {
  final dom.Element pageEl;
  final JavascriptRuntime jsRuntime;
  const App({super.key, required this.pageEl, required this.jsRuntime});

  @override
  Widget build(BuildContext context) {
    JsEvalResult jsResult = jsRuntime.evaluate(
        "function print(msg) { sendMessage(\"methodChannel\", JSON.stringify({method: \"print\", msg: msg})); return;} print(\"halooo\"); ");
    print(jsResult.stringResult);
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Component(pageEl: pageEl),
        ),
      ),
    );
  }
}

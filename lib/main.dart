import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:shake/shake.dart';
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
/* Flags :
  show as main page : 00,10,01,11
  is deleted        : 00,01,10,11
*/
  await database.transaction((txn) async {
    await txn.rawInsert(
        'INSERT INTO Pages(id, name, desc, flags, content) VALUES(?,?,?,?,?)', [
      'DEFAULT',
      'Default Page',
      'Generic Page Editor',
      1,
      '''
<tabBar titles="Preview, Script, Setting">
  <componentLoader id="001"></componentLoader>
  <column>
    <row>
      <label onEvent="/text.addX2 ==> props.text = props.text + 'B'">Script</label>
      <button onClick="input.toUpperCase() + 'X'; ==> /text.addX2">add a to text</button>
    </row>
    <column>
        <label>label02</label>
        <label>label03</label>
        <label onEvent="/text.addX2 ==> props.text = props.text + input">label04</label>
      </column>
  </column>
  <column>
    <label>Setting</label>
  </column>
</tabBar>
'''
    ]);
    await txn.rawInsert(
        'INSERT INTO Pages(id, name, desc, flags, content) VALUES(?,?,?,?,?)', [
      '001',
      'test01',
      'test page pertama',
      0,
      '''
<column>
  <row>
    <label>Page Pertama</label>
    <button onClick="input.toUpperCase() + 'X'; ==> /text.addX">add a to text</button>
  </row>
  <column>
      <label onEvent="/text.addX ==> props.text = props.text + input">Will Changes</label>
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
    print('method : ${methodName}');
    print('msg    : ${message.runtimeType} - ${message}');
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
      database: database,
    ));
  }
}

class App extends StatelessWidget {
  final dom.Element pageEl;
  final JavascriptRuntime jsRuntime;
  final Database database;
  const App(
      {super.key,
      required this.pageEl,
      required this.jsRuntime,
      required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Main(
            pageEl: pageEl,
            jsRuntime: jsRuntime,
            database: database,
          ),
        ),
      ),
    );
  }
}

class Main extends StatelessWidget {
  final dom.Element pageEl;
  final JavascriptRuntime jsRuntime;
  final Database database;
  const Main(
      {super.key,
      required this.pageEl,
      required this.jsRuntime,
      required this.database});

  @override
  Widget build(BuildContext context) {
    ShakeDetector.autoStart(
      onPhoneShake: () {
        print("SHAKEEEENNN TO THE GROUND");
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    title: Text('Back to editor view'),
                    content: Text('Show editor view'),
                    actions: [
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                          print("click Yes");
                        },
                      ),
                      TextButton(
                        child: Text("No"),
                        onPressed: () {
                          print("click No");
                        },
                      ),
                    ]));
      },
      minimumShakeCount: 1,
    );

    JsEvalResult jsResult = jsRuntime.evaluate('''
    function print(msg) { sendMessage("methodChannel", JSON.stringify({method: "print", msg: msg})); return;} print("halooo"); 
    function mapToObj(inputMap) {
        let obj = {};
        inputMap.forEach(function(value, key){
            obj[key] = value
        });
        return obj;
    }
    ''');
    print(jsResult.stringResult);
    return Component(
      pageEl: pageEl,
      jsRuntime: jsRuntime,
      database: database,
    );
  }
}

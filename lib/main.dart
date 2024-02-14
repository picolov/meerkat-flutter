import 'package:flutter/material.dart';
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
<rows>
    <label>The time is?</label>
    <button onClick="button01.onClick">click here</button>
</rows>
'''
    ]);
    print('inserted: $id1');
  });

  List<Map> defaultPage =
      await database.rawQuery('SELECT * FROM Pages where flags=?', [1]);
  print(defaultPage.first['id']);
  String defaultPageHtml = (defaultPage.first['content'] as String).trim();
  dom.Document defaultHtmlDoc = parse(defaultPageHtml);
  dom.Element? rootElement = defaultHtmlDoc.body?.children.first;
  eventBus.on<Event>().listen((event) {
    // Print the runtime type. Such a set up could be used for logging.
    print('event [${event.uri}] - ${event.content}');
  });
  if (rootElement != null) {
    runApp(App(pageEl: rootElement));
  }
}

class App extends StatelessWidget {
  final dom.Element pageEl;
  const App({super.key, required this.pageEl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Component(pageEl: pageEl),
        ),
      ),
    );
  }
}

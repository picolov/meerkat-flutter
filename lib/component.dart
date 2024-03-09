import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:html/dom.dart' as dom;
import 'package:meerkat_flutter/components/index.dart';

import 'event.dart';
import 'event_bus.dart';

class Component extends StatefulWidget {
  final dom.Element pageEl;
  final JavascriptRuntime jsRuntime;
  const Component({Key? key, required this.pageEl, required this.jsRuntime})
      : super(key: key);

  @override
  State<Component> createState() => _ComponentState();
}

class _ComponentState extends State<Component> {
  late Map<String, dynamic> attrs;
  StreamSubscription? subs;

  @override
  void initState() {
    attrs = widget.pageEl.attributes
        .map((key, value) => MapEntry(key.toString(), value));
    if (attrs.containsKey('onevent')) {
      var eventAndScriptArr = attrs['onevent']
          .toString()
          .split("==>")
          .map((datum) => datum.trim())
          .toList();
      subs = eventBus.on<Event>().listen((event) {
        if (event.uri == eventAndScriptArr[0]) {
          // print(
          //     'event processed by ${widget.pageEl.localName} : [${event.uri}] - ${event.content} - ${eventAndScriptArr[1]}');
          String jsonContent = json.encode(event.content['payload']);
          String jsonProps = json.encode(attrs);
          String script = '''
            () => {
              let isDirty = false;
              const input = $jsonContent;
              var propsMap = $jsonProps;
              var props = new Proxy(propsMap, {
                set: function (target, key, value) {
                    target[key] = value;
                    isDirty = true;
                    return true;
                }
              });
              ${eventAndScriptArr[1]};
              var changedProps = {};
              if (isDirty) {
                changedProps=propsMap;
              }
              return changedProps;
            }();''';
          JsEvalResult jsResult = widget.jsRuntime.evaluate(script);
          var changedProps = jsResult.rawResult as Map;
          if (changedProps.isNotEmpty) {
            setState(() {
              for (MapEntry changedProp in changedProps.entries) {
                attrs[changedProp.key] = changedProp.value;
              }
            });
          }
        }
      });
    } else {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('${widget.pageEl.localName} - REBUILD!!!!');
    Widget component;
    if (widgetMaps.containsKey(widget.pageEl.localName)) {
      if (!attrs.containsKey('text') && widget.pageEl.text.isNotEmpty) {
        attrs['text'] = widget.pageEl.text;
      }
      List<Widget> children = [];
      if (widget.pageEl.children.isNotEmpty) {
        for (dom.Element child in widget.pageEl.children) {
          children.add(Component(pageEl: child, jsRuntime: widget.jsRuntime));
        }
      }
      // get widget by tag and attrs
      component = widgetMaps[widget.pageEl.localName]!(
          attrs, children, widget.jsRuntime);
    } else {
      component = Text('widget type:${widget.pageEl.localName} not found');
    }
    return component;
  }

  @override
  void dispose() {
    subs?.cancel();
    super.dispose();
  }
}

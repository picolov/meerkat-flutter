import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;
import 'package:meerkat_flutter/components/index.dart';

class Component extends StatefulWidget {
  final dom.Element pageEl;
  const Component({Key? key, required this.pageEl}) : super(key: key);

  @override
  State<Component> createState() => _ComponentState();
}

class _ComponentState extends State<Component> {
  @override
  Widget build(BuildContext context) {
    Widget component;
    if (widgetMaps.containsKey(widget.pageEl.localName)) {
      Map<String, dynamic> attrs = widget.pageEl.attributes
          .map((key, value) => MapEntry(key.toString(), value));
      if (widget.pageEl.text.isNotEmpty) {
        attrs['text'] = widget.pageEl.text;
      }
      if (widget.pageEl.children.isNotEmpty) {
        List<Widget> children = [];
        for (dom.Element child in widget.pageEl.children) {
          children.add(Component(pageEl: child));
        }
        attrs['children'] = children;
      }
      component = widgetMaps[widget.pageEl.localName]!(attrs);
    } else {
      component = Text('widget type:${widget.pageEl.localName} not found');
    }
    return Container(
      child: component,
    );
  }
}

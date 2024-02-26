import 'package:flutter/material.dart';
import 'package:tabbed_view/tabbed_view.dart';

class TabBarContainer extends StatelessWidget {
  final List<Widget> children;
  final List<String> titles;

  const TabBarContainer(
      {Key? key, required this.children, required this.titles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TabData> tabs = [];
    for (var i = 0; i < children.length; i++) {
      tabs.add(TabData(text: titles[i], content: children[i], closable: false));
    }
    return TabbedView(controller: TabbedViewController(tabs));
  }
}

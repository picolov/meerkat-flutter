class Event {
  String uri;
  Map<String, dynamic> content;

  Event(this.uri, this.content);
}

// class LocalEvent extends Event {
//   LocalEvent(String identifier, Map<String, dynamic> content)
//       : super(
//             identifier.startsWith('/')
//                 ? 'local$identifier'
//                 : 'local/$identifier',
//             content);
// }

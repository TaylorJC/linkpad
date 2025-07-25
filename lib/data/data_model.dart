import 'dart:convert';
import 'dart:core';

import 'datetime_parse.dart';

class Document {
  // String path;
  int id;
  String title;
  int lastModified;
  List<String> links;

  Document(this.id, this.title, this.lastModified, this.links,);

  factory Document.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    List<dynamic> jsonTags = jsonDecode(data['tags']);

    List<String> links = jsonTags.isNotEmpty ? List.from(jsonTags.cast(), growable: true) : List.empty(growable: true);

    return Document(
      data['id'],
      data['title'],
      data['lastModified'],
      links,
    );
  }

  String toJson() {
    return jsonEncode( {
      'id': id,
      'title': title,
      'lastModified': lastModified,
      'links': jsonEncode(links),
    });
  }

  static Document titled(String title) {
    return Document(
      DateTime.now().millisecondsSinceEpoch, // Use current time as ID
      title,
      dateTimeNowToInt(),
      List<String>.empty(growable: true),
    );
  }

}
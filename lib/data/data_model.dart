import 'dart:convert';
import 'dart:core';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';

import 'datetime_parse.dart';

enum DocumentDisplayType {
  List,
  Grid,
}

class Document {
  // String path;
  int id;
  String title;
  int lastModified;
  List<String> links;

  Document(this.id, this.title, this.lastModified, this.links,);

  factory Document.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    List<dynamic> jsonTags = jsonDecode(data['links']);

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

  Future<bool> saveDocument(TextEditingController titleController, FleatherController editorController, DataController dataController) async {
    if (titleController.text.trim().isEmpty && editorController.plainTextEditingValue.text.trim().isEmpty) {
      return false; // Do not save if both title and content are empty
    }

    title = titleController.text.trim();
    lastModified = dateTimeNowToInt();
    await dataController.updateItem(this);

    dataController.saveDocumentToFile(
      this,
      jsonEncode(editorController.document.toJson()),
    );

    return true; // Document saved successfully
  }

}
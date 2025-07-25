import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/linkpad_appbar.dart' show FilterType;
import 'datetime_parse.dart';

import 'data_model.dart';

// Data Controller class that manages your application state
class DataController extends ChangeNotifier {
  late SharedPreferences prefs;
  // Data fields
  final Map<int, Document> _items = <int, Document>{};
  // Settings fields
  late bool _firstTimeStart;
  late double _fontSize;
  late ThemeMode _themeMode;
  late Color _themeColor;
  late Directory _saveDirectory;

  // Call on startup
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    if (kDebugMode) {
      await prefs.clear();
    }

    loadUserSettings();
    loadUserData();
  }

  void loadUserSettings() async {
    _firstTimeStart = prefs.getBool('firstTimeStart') ?? true;

    _fontSize = prefs.getDouble('fontSize') ?? 18.0;

    var defDir = await getApplicationDocumentsDirectory();
    var savedDir = prefs.getString('saveDirectory');

    if (savedDir != null) {
      _saveDirectory = Directory(savedDir);
    } else {
      _saveDirectory = defDir;
    }

    int? themeMode = prefs.getInt('themeMode');
    _themeMode = themeMode != null ? ThemeMode.values[themeMode] : ThemeMode.system;

    List<String>? themeColor = prefs.getStringList('themeColor');
    _themeColor = themeColor != null ? 
      Color.from(
        alpha: double.parse(themeColor[0]), 
        red: double.parse(themeColor[1]),
        green: double.parse(themeColor[2]),
        blue: double.parse(themeColor[3])) : 
      Colors.indigo;
  }

  void loadUserData() {
    var docs = prefs.getStringList('Documents');

    if (docs != null) {
      for (var docJson in docs) {
        Document doc = Document.fromJson(docJson);

        _items.putIfAbsent(doc.id, () => doc);
      }
    }

    if (_firstTimeStart) {
      updateFirstTimeStart(false);
    }
  }

  String filePath(Document doc) {
    if (!_saveDirectory.existsSync()) {
      _saveDirectory.createSync(recursive: true);
    }

    if (doc.title.isEmpty) {
      doc.title = 'Untitled';
    }

    final saveTitle = doc.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'); // Replace invalid characters in file name

    return '${_saveDirectory.path}${Platform.pathSeparator}$saveTitle.txt';
  }

  String loadDocumentFromDoc(Document doc) {
    return loadDocumentFromPath(filePath(doc));
  }

  String loadDocumentFromPath(String path) {
    try {
      return File(path).readAsStringSync();
    } catch (e) {
      return "";
    }
  }

  void saveDocumentToFile(Document doc, String text) {
    final saveFile = File(filePath(doc));

    // Write data to file
    saveFile.writeAsStringSync(text);
  }

  // Getters
  List<Document> get items { 
    List<Document> ret = List.from(_items.values);

    return ret;
  }

  List<Document> searchItems(String query, FilterType filterType) {
    if (query.isEmpty) return items;

    switch (filterType) {
      case FilterType.Titles:
        return items.where((doc) => doc.title.toLowerCase().contains(query.toLowerCase())).toSet().toList();
      case FilterType.Links:
        return items.where((doc) => doc.links.any((link) => link.toLowerCase().contains(query.toLowerCase()))).toSet().toList();
      case FilterType.All:
        return items.where((doc) => doc.title.toLowerCase().contains(query.toLowerCase()) || 
                                    doc.links.any((link) => link.toLowerCase().contains(query.toLowerCase()))).toSet().toList();
    }
  }

  List<String> get links {
    List<String> links = List.empty(growable: true);

    for (var doc in items) {
      links.addAll(doc.links);
    }

    return links.toSet().toList(); // Remove duplicates
  }

  bool get firstTimeStart => _firstTimeStart;
  double get fontSize => _fontSize;
  ThemeMode get themeMode => _themeMode;
  Color get themeColor => _themeColor;
  Directory get saveDirectory => _saveDirectory;

  // Methods to update data
  Future<Document> addItemByTitle (String title) async {
    final doc = Document.titled(title);

    return addItem(doc);
  }

  Future<Document> addItem(Document doc) async {
    if (_items.containsKey(doc.id)) {
      return _items[doc.id]!;
    }

    _items.putIfAbsent(doc.id, () => doc);

    await _updatePrefsList('Documents', doc, true);
    notifyListeners();

    return doc;
  }

  Future<void> removeItem(Document item) async {
    if (!_items.containsKey(item.id)) return;

    _items.remove(item.id);
    if (File(filePath(item)).existsSync()) {
      // Delete the file if it exists 
      await File(filePath(item)).delete();
    }

    await _updatePrefsList('Documents', item, false);
    notifyListeners();
  }

  Future<void> updateItem(Document item) async {
    if (!_items.containsKey(item.id)) {
      addItem(item);
      return;
    }

    _items.update(item.id, (val) => item);

    await _updatePrefsList('Documents', item, false);
    await _updatePrefsList('Documents', item, true);
    notifyListeners();
  }

  Future<void> updateFirstTimeStart(bool val) async {
    _firstTimeStart = val;
    await prefs.setBool('firstTimeStart', val);
    notifyListeners();
  }

  Future<void> updateFontSize(double val) async {
    _fontSize = val;
    await prefs.setDouble('fontSize', val);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode val) async {
    _themeMode = val;
    await prefs.setInt('themeMode', val.index);
    notifyListeners();
  }

  Future<void> updateSaveDirectory(String path) async {
    _saveDirectory = Directory(path);
    await prefs.setString('saveDirectory', path);
    notifyListeners();
  }

  Future<void> updateThemeColor(Color val) async {
    _themeColor = val;
    List<String> color = [
      val.a.toStringAsFixed(5),
      val.r.toStringAsFixed(5),
      val.g.toStringAsFixed(5),
      val.b.toStringAsFixed(5),
    ];

    await prefs.setStringList('themeColor', color);
    notifyListeners();
  }

  Future<void> _updatePrefsList(String listKey, Document doc, bool add) async {
    List<String>? docs = prefs.getStringList(listKey);
    String docJson = doc.toJson();

    if (docs == null) {
      if (add) {
        docs = {docJson}.toList();
      } else {
        return;
      }
    } else {
      if (add && !docs.contains(docJson)) {
        docs.add(docJson);
      } else if (!add) {
        docs.remove(docJson);
      }
    }

    await prefs.setStringList(listKey, docs);
  }
}

// InheritedWidget that provides the DataController to the widget tree
class DataProvider extends InheritedNotifier<DataController> {
  const DataProvider({
    super.key,
    required DataController dataController,
    required super.child,
  }) : super(notifier: dataController);

  // Static method to access the DataController from anywhere in the widget tree
  static DataController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataProvider>()?.notifier;
  }

  // Alternative method that throws if DataProvider is not found (useful for required access)
  static DataController require(BuildContext context) {
    final controller = of(context);
    if (controller == null) {
      throw FlutterError('DataProvider not found in widget tree');
    }
    return controller;
  }
}

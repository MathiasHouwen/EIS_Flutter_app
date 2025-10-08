import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class TodoItem {
  String title;
  bool isDone;
  bool isFavourite;
  String description;

  TodoItem({
    required this.title,
    this.isDone = false,
    this.isFavourite = false,
    this.description = "",
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
    'isFavourite': isFavourite,
    'description': description,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    title: json['title'],
    isDone: json['isDone'] ?? false,
    isFavourite: json['isFavourite'] ?? false,
    description: json['description'] ?? "",
  );
}

class TodoList {
  String name;
  List<TodoItem> items;

  TodoList({required this.name, List<TodoItem>? items})
      : items = items ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory TodoList.fromJson(Map<String, dynamic> json) => TodoList(
    name: json['name'],
    items: (json['items'] as List<dynamic>)
        .map((e) => TodoItem.fromJson(e))
        .toList(),
  );
}

class Storage{
  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/todos.json');
  }

  Future<void> saveData(List<TodoList> todoLists) async {
    final file = await _localFile;
    final jsonData =
    jsonEncode(todoLists.map((list) => list.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  // Load data
  Future<List<TodoList>> loadData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      final List<dynamic> data = jsonDecode(contents);

      return data.map((e) => TodoList.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error loading data: $e");
      return [];
    }
  }
}

class HomeModel extends ChangeNotifier{
  final Storage _storage = Storage();
  final List<TodoList> _todoLists = [];

  List<TodoList> get todoLists => _todoLists;

  // --- Storage helpers
  Future<void> loadTodos() async {
    final loaded = await _storage.loadData();
    _todoLists
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveData(_todoLists);
  }

  Future<void> save() async {
    await _save();
  }
  // ---

  void addList(String name) {
    if (_todoLists.any((list) => list.name == name)) return;
    _todoLists.add(TodoList(name: name));
    _save();
    notifyListeners();
  }

  bool noList(){
    return _todoLists.isEmpty;
  }

  void removeList(int index) {
    _todoLists.removeAt(index);
    _save();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _todoLists.removeAt(oldIndex);
    _todoLists.insert(newIndex, item);
    _save();
    notifyListeners();
  }

  void addItem(int listIndex, String title) {
    if (listIndex < 0 || listIndex >= _todoLists.length) return;
    if (_todoLists[listIndex].items.any((item) => item.title == title)) return;

    _todoLists[listIndex].items.add(TodoItem(title: title));
    _sortItems(listIndex);
    _save();
    notifyListeners();
  }

  void removeItem(int listIndex, int itemIndex) {
    _todoLists[listIndex].items.removeAt(itemIndex);
    _save();
    notifyListeners();
  }

  void reorderItems(int listIndex, int oldIndex, int newIndex) {
    final items = _todoLists[listIndex].items;
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    _save();
    notifyListeners();
  }

  void toggleItemDone(int listIndex, int itemIndex, bool? value) {
    _todoLists[listIndex].items[itemIndex].isDone = value ?? false;
    _save();
    notifyListeners();
  }

  void _sortItems(int listIndex) {
    _todoLists[listIndex].items.sort((a, b) {
      if (a.isFavourite == b.isFavourite) return 0;
      return a.isFavourite ? -1 : 1;
    });
  }

  void toggleFavourite(int listIndex, int itemIndex) {
    final item = _todoLists[listIndex].items[itemIndex];
    item.isFavourite = !item.isFavourite;

    _sortItems(listIndex);
    _save();
    notifyListeners();
  }

}
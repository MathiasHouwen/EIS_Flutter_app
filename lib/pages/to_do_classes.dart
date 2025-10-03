import 'package:flutter/cupertino.dart';

class TodoItem {
  String title;
  bool isDone;

  TodoItem({required this.title, this.isDone = false});
}

class TodoList {
  String name;
  List<TodoItem> items;

  TodoList({required this.name, List<TodoItem>? items})
      : items = items ?? [];
}

class HomeModel extends ChangeNotifier{
  final List<TodoList> _todoLists = [];

  List<TodoList> get todoLists => _todoLists;

  void addList(String name) {
    _todoLists.add(TodoList(name: name));
    notifyListeners();
  }

  bool noList(){
    return _todoLists.isEmpty;
  }

  void removeList(int index) {
    _todoLists.removeAt(index);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _todoLists.removeAt(oldIndex);
    _todoLists.insert(newIndex, item);
    notifyListeners();
  }

  void addItem(int listIndex, String title) {
    if (listIndex < 0 || listIndex >= _todoLists.length) return;
    _todoLists[listIndex].items.add(TodoItem(title: title));
    notifyListeners();
  }

  void removeItem(int listIndex, int itemIndex) {
    _todoLists[listIndex].items.removeAt(itemIndex);
    notifyListeners();
  }

  void reorderItems(int listIndex, int oldIndex, int newIndex) {
    final items = _todoLists[listIndex].items;
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    notifyListeners();
  }

  void toggleItemDone(int listIndex, int itemIndex, bool? value) {
    _todoLists[listIndex].items[itemIndex].isDone = value ?? false;
    notifyListeners();
  }
}
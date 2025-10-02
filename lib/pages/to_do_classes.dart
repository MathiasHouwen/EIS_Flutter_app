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

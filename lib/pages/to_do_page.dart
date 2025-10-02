import 'package:flutter/material.dart';
import 'to_do_classes.dart';

class toDoPage extends StatefulWidget {
  final TodoList todoList;

  const toDoPage({super.key, required this.todoList});

  @override
  State<toDoPage> createState() => _toDoPageState();
}

class _toDoPageState extends State<toDoPage> {
  late final _todoItems = widget.todoList.items;
  final TextEditingController _listNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(widget.todoList.name,),
      floatingActionButton: buildFloatingAddButton(context),
      body: buildBody(),
    );
  }

  FloatingActionButton buildFloatingAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        popUp(context);
      },
      child: const Icon(Icons.add),
    );
  }

  void popUp(BuildContext context) {
    _listNameController.clear();
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Naam van de todo lijst"),
            content: TextField(
              controller: _listNameController,
              decoration: const InputDecoration(hintText: "Enter list name"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Voeg toe'),
                onPressed: () {
                  final name = _listNameController.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      _todoItems.add(TodoItem(title: name, isDone: false));
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title,),
      centerTitle: true,
      elevation: 1,
    );
  }

  Widget buildBody() {
    if (_todoItems.isEmpty) {
      return Center(child: Text("Items in ${widget.todoList.name} komen hier"));
    }

    return ReorderableListView.builder(
      itemCount: _todoItems.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _todoItems.removeAt(oldIndex);
          _todoItems.insert(newIndex, item);
        });
      },
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final list = _todoItems[index];
        return ListTile(
          key: ValueKey(list.title),
          leading: const Icon(Icons.list),
          title: Text(
            list.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _todoItems.removeAt(index);
                  });
                },
              ),
              Checkbox(
                value: list.isDone,
                onChanged: (value) {
                  setState(() {
                    list.isDone = value ?? false;
                  });
                },
              ),
              const SizedBox(width: 24),
            ],
          ),
          onTap: () {
            // Discription
          },
        );
      },
    );
  }
}

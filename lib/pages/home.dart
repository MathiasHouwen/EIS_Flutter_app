import 'package:flutter/material.dart';
import 'package:to_do/pages/to_do_page.dart';
import 'to_do_classes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TodoList> _todoLists = [];
  final TextEditingController _listNameController = TextEditingController();

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
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
                      _todoLists.add(TodoList(name: name));
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("ToDo's",),
      centerTitle: true,
      elevation: 1,
    );
  }

  Widget buildBody() {
    if (_todoLists.isEmpty) {
      return const Center(child: Text("No todo lists yet!"));
    }

    return ReorderableListView.builder(
      itemCount: _todoLists.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _todoLists.removeAt(oldIndex);
          _todoLists.insert(newIndex, item);
        });
      },
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final list = _todoLists[index];
        return ListTile(
          key: ValueKey(list.name),
          leading: const Icon(Icons.list),
          title: Text(
            list.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _todoLists.removeAt(index);
                  });
                },
              ),
              const SizedBox(width: 24),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => toDoPage(todoList: list),
              ),
            );
          },
        );
      },
    );
  }
}
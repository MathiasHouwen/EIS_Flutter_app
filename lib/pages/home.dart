import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do/pages/to_do_page.dart';
import 'to_do_classes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _listNameController = TextEditingController();

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context);

    return Scaffold(
      appBar: buildAppBar(),
      floatingActionButton: buildFloatingAddButton(context, model),
      body: buildBody(model),
    );
  }

  FloatingActionButton buildFloatingAddButton(BuildContext context, HomeModel model) {
    return FloatingActionButton(
      onPressed: () {
        popUp(context, model);
      },
      child: const Icon(Icons.add),
    );
  }

  void popUp(BuildContext context, HomeModel model) {
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
                    model.addList(name);
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

  Widget buildBody(HomeModel model) {
    if (model.noList()) {
      return const Center(child: Text("No todo lists yet!"));
    }

    return ReorderableListView.builder(
      itemCount: model.todoLists.length,
      onReorder: (oldIndex, newIndex) {
        model.reorder(oldIndex, newIndex);
      },
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final list = model.todoLists[index];
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
                onPressed: () => model.removeList(index),
              ),
              const SizedBox(width: 24),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => toDoPage(
                  todoList: model.todoLists[index],
                  model: model,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
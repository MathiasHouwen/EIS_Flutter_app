import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';

class toDoPage extends StatefulWidget {
  final TodoList todoList;
  final HomeModel model;

  const toDoPage({super.key, required this.todoList, required this.model});

  @override
  State<toDoPage> createState() => _toDoPageState();
}

class _toDoPageState extends State<toDoPage> {
  late final _todoItems = widget.todoList.items;
  final TextEditingController _listNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context);
    return Scaffold(
      appBar: buildAppBar(widget.todoList.name,),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _focusNode.requestFocus();
        });

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Naam van de todo lijst",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _listNameController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: "Enter list name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    child: const Text('Voeg toe'),
                    onPressed: () {
                      final name = _listNameController.text.trim();
                      if (name.isNotEmpty) {
                        final listIndex = model.todoLists.indexOf(widget.todoList);
                        if (listIndex != -1) {
                          model.addItem(listIndex, name);
                        }
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }



  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title,),
      centerTitle: true,
      elevation: 1,
    );
  }

  Widget buildBody(HomeModel model) {
    if (_todoItems.isEmpty) {
      return Center(child: Text("Items in ${widget.todoList.name} komen hier"));
    }

    final listIndex = model.todoLists.indexOf(widget.todoList);

    return ReorderableListView.builder(
      itemCount: _todoItems.length,
      onReorder: (oldIndex, newIndex) {
        model.reorderItems(listIndex, oldIndex, newIndex);
      },
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final item = _todoItems[index];
        return ListTile(
          key: ValueKey(item.title),
          leading: IconButton(
            icon: Icon(
              item.isFavourite ? Icons.star : Icons.star_border,
              color: item.isFavourite ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              model.toggleFavourite(listIndex, index);
            },
          ),

          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  model.removeItem(listIndex, index);
                },
              ),
              Checkbox(
                value: item.isDone,
                onChanged: (value) {
                  model.toggleItemDone(listIndex, index, value);
                },
              ),
              const SizedBox(width: 24),
            ],
          ),
          onTap: () {
            // Discription
            showDescriptionDialog(index);
          },
        );
      },
    );
  }

  void showDescriptionDialog(int itemIndex) {
    final item = _todoItems[itemIndex];
    final TextEditingController _descController = TextEditingController(text: item.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Beschrijving voor '${item.title}'"),
          content: TextField(
            controller: _descController,
            decoration: const InputDecoration(
              hintText: "Voeg een beschrijving toe",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuleer"),
            ),
            ElevatedButton(
              onPressed: () {
                item.description = _descController.text.trim();
                widget.model.save(); // save changes
                setState(() {});     // refresh UI
                Navigator.of(context).pop();
              },
              child: const Text("Opslaan"),
            ),
          ],
        );
      },
    );
  }
}

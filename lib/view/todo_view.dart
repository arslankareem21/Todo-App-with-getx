import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/todo_controller.dart';
import '../model/todo_model.dart';

class TodoView extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login'); // navigate back to login screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Todos
          Expanded(
            flex: 1,
            child: Obx(() {
              final activeTodos = todoController.todos
                  .where((t) => !t.isDone)
                  .toList();
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Active Todos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: activeTodos.isEmpty
                        ? const Center(child: Text("No Active Todos"))
                        : ListView.builder(
                            itemCount: activeTodos.length,
                            itemBuilder: (_, i) {
                              final todo = activeTodos[i];
                              return Card(
                                child: ListTile(
                                  leading: Checkbox(
                                    value: todo.isDone,
                                    onChanged: (_) =>
                                        todoController.toggleDone(todo),
                                  ),
                                  title: Text(todo.title),
                                  subtitle: Text(todo.description),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          titleController.text = todo.title;
                                          descController.text =
                                              todo.description;
                                          _showEditDialog(todo);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            todoController.deleteTodo(todo.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }),
          ),

          // Completed Todos
          Expanded(
            flex: 1,
            child: Obx(() {
              final completedTodos = todoController.todos
                  .where((t) => t.isDone)
                  .toList();
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Completed Todos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: completedTodos.isEmpty
                        ? const Center(child: Text("No Completed Todos"))
                        : ListView.builder(
                            itemCount: completedTodos.length,
                            itemBuilder: (_, i) {
                              final todo = completedTodos[i];
                              return Card(
                                child: ListTile(
                                  leading: Checkbox(
                                    value: todo.isDone,
                                    onChanged: (_) =>
                                        todoController.toggleDone(todo),
                                  ),
                                  title: Text(
                                    todo.title,
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  subtitle: Text(todo.description),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        todoController.deleteTodo(todo.id),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(),
      ),
    );
  }

  // Add Todo Dialog
  void _showAddDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Add Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                todoController.addTodo(
                  titleController.text.trim(),
                  descController.text.trim(),
                );
                titleController.clear();
                descController.clear();
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  // Edit Todo Dialog
  void _showEditDialog(TodoModel todo) {
    Get.dialog(
      AlertDialog(
        title: const Text("Edit Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
                todoController.updateTodo(
                  TodoModel(
                    id: todo.id,
                    userId: uid, // ✅ preserve userId
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    isDone: todo.isDone,
                    createdAt: todo.createdAt,
                  ),
                );
                titleController.clear();
                descController.clear();
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }
}

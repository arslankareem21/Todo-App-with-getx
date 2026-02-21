import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/todo_model.dart';

class TodoController extends GetxController {
  var todos = <TodoModel>[].obs;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  void fetchTodos() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            todos.value = snapshot.docs.map((doc) {
              return TodoModel.fromMap(doc.data());
            }).toList();
          },
          onError: (e) {
            Get.snackbar("Error", "Failed to fetch todos: $e");
          },
        );
  }

  void addTodo(String title, String description) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final id = _db.collection('users').doc(uid).collection('todos').doc().id;
    final todo = TodoModel(
      id: id,
      userId: uid, // optional now, but kept for consistency
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    // Optimistic update
    todos.insert(0, todo);

    _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(id)
        .set(todo.toMap())
        .catchError((e) {
          todos.removeWhere((t) => t.id == id);
          Get.snackbar("Error", "Failed to add todo: $e");
        });
  }

  void toggleDone(TodoModel todo) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updated = TodoModel(
      id: todo.id,
      userId: uid,
      title: todo.title,
      description: todo.description,
      isDone: !todo.isDone,
      createdAt: todo.createdAt,
    );

    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) todos[index] = updated;

    _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(todo.id)
        .update({'isDone': updated.isDone})
        .catchError((e) {
          todos[index] = todo;
          Get.snackbar("Error", "Failed to update todo: $e");
        });
  }

  void updateTodo(TodoModel todo) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) todos[index] = todo;

    _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(todo.id)
        .update(todo.toMap())
        .catchError((e) {
          Get.snackbar("Error", "Failed to update todo: $e");
        });
  }

  void deleteTodo(String id) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final removed = todos.firstWhereOrNull((t) => t.id == id);
    todos.removeWhere((t) => t.id == id);

    _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(id)
        .delete()
        .catchError((e) {
          if (removed != null) todos.add(removed);
          Get.snackbar("Error", "Failed to delete todo: $e");
        });
  }
}

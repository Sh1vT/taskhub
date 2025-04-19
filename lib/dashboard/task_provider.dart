import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'task_model.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;
  final SupabaseClient supabase;
  List<Task> _tasks = [];

  TaskProvider(this.supabase);

  List<Task> get tasks => _tasks;

  bool get isLoading => _isLoading;

  Future<void> fetchTasks({bool showCompleted = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final query = supabase.from('tasks').select().eq('user_id', userId);

      if (!showCompleted) {
        query.eq('is_completed', false);
      }

      final response = await query;
      _tasks = response.map<Task>((task) => Task.fromMap(task)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    final userId = supabase.auth.currentUser?.id;
    if (title.isEmpty || userId == null) return;

    await supabase.from('tasks').insert({
      'title': title,
      'user_id': userId,
      'is_completed': false,
    });
    await fetchTasks();
  }

  Future<void> toggleCompleted(int id) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final currentTask = _tasks[taskIndex];
    final newStatus = !currentTask.isCompleted;

    await supabase
        .from('tasks')
        .update({'is_completed': newStatus})
        .eq('id', id);
    await fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await supabase.from('tasks').delete().eq('id', id);
    await fetchTasks();
  }
}

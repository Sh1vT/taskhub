import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'task_model.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;
  final SupabaseClient supabase;
  List<Task> _tasks = [];
  bool _isInitialized = false;

  int _xp = 0;
  int _level = 1;

  TaskProvider(this.supabase);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  int get xp => _xp;
  int get level => _level;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchTasks();
    await fetchXP();
    _isInitialized = true;
  }

  Future<void> fetchTasks({bool showCompleted = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final query = supabase.from('tasks').select().eq('user_id', userId);
      if (!showCompleted) query.eq('is_completed', false);

      final response = await query;
      _tasks = response.map<Task>((task) => Task.fromMap(task)).toList();
    } catch (e) {
      debugPrint('TaskProvider Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchXP() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('stats')
          .select('xp')
          .eq('user_id', userId)
          .maybeSingle(); 

      if (response != null && response['xp'] != null) {
        _xp = response['xp'] as int;
      } else {
        
        await initializeUserStats();
        _xp = 0;
      }

      _level = _calculateLevel(_xp);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching XP: $e');
    }
  }

  Future<void> addXP(int amount) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      _xp += amount;
      _level = _calculateLevel(_xp);

      
      final response = await supabase
          .from('stats')
          .update({'xp': _xp})
          .eq('user_id', userId);

      if (response.error != null) {
        debugPrint('Error updating XP in stats table: ${response.error!.message}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding XP: $e');
    }
  }

  int _calculateLevel(int xp) {
    return (xp / 100).floor() + 1; 
  }

  Future<void> initializeUserStats() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('stats')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        
        await supabase.from('stats').insert({'user_id': userId, 'xp': 0});
      }
    } catch (e) {
      debugPrint('Error initializing user stats: $e');
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

    if (newStatus) {
      
      await addXP(10); 
    }

    await fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await supabase.from('tasks').delete().eq('id', id);
    await fetchTasks();
  }

  Future<void> editTask(int id, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    await supabase
        .from('tasks')
        .update({'title': newTitle.trim()})
        .eq('id', id);

    await fetchTasks();
  }

  bool get mounted => _isInitialized;
}

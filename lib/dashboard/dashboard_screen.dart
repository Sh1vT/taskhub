import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskhub/app/theme.dart';
import 'package:taskhub/auth/login_screen.dart';
import 'task_tile.dart';
import 'commit_calender.dart';
import 'task_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchTasks();
  }

  Future<void> _checkAuthAndFetchTasks() async {
    final session = Supabase.instance.client.auth.currentSession;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    } else {
      await taskProvider.fetchTasks(showCompleted: false);
    }
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final taskController = TextEditingController();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add New Task"),
            content: TextField(
              controller: taskController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Enter task name",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (taskController.text.trim().isNotEmpty) {
                    await taskProvider.addTask(taskController.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.surface, 
        elevation: 0, 
        scrolledUnderElevation: 0, 
        surfaceTintColor: Colors.transparent, 
        forceMaterialTransparency: true,
        title: Text(
          "TaskHub",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed:
                () => themeProvider.toggleTheme(
                  themeProvider.themeMode != ThemeMode.dark,
                ),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          const CommitCalendar(),
          Expanded(
            child:
                taskProvider.isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                    : taskProvider.tasks.isEmpty
                    ? Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No tasks yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the + button to add your first task',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[index];
                        return TaskTile(
                          task: task,
                          onDelete: () => taskProvider.deleteTask(task.id),
                          onToggleComplete:
                              () => taskProvider.toggleCompleted(task.id),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

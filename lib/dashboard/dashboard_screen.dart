import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taskhub/app/theme.dart';
import 'package:taskhub/auth/login_screen.dart';
import 'package:taskhub/dashboard/widgets/level_widget.dart';
import 'package:taskhub/dashboard/task_model.dart';
import 'task_tile.dart';
import 'widgets/commit_calender.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetchTasks();
    });
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
      builder: (context) => AlertDialog(
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

  void _showEditDialog(BuildContext context, Task task) async {
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                await Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).editTask(task.id, newTitle);
              }
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    
    final incompleteTasks = taskProvider.tasks.where((task) => !task.isCompleted).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            
            SliverAppBar(
              expandedHeight: 200,
              
              snap: false,
              stretch: false,
              elevation: 0, 
              backgroundColor: theme.colorScheme.surface, 
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: theme.colorScheme.surface,
                ),
                title: const Text(
                  "TaskHub",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Expanded(
                      flex: 2,
                      child: const CommitCalendar(),
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Material(
                                elevation: 2,
                                shape: const CircleBorder(),
                                color: theme.colorScheme.primary,
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: IconButton(
                                    onPressed: () => themeProvider.toggleTheme(
                                      themeProvider.themeMode != ThemeMode.dark,
                                    ),
                                    icon: Icon(
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                    ),
                                    color: theme.colorScheme.onPrimary,
                                    tooltip: 'Toggle theme',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                elevation: 2,
                                shape: const CircleBorder(),
                                color: theme.colorScheme.primary,
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: IconButton(
                                    onPressed: _logout,
                                    icon: const Icon(Icons.logout),
                                    color: theme.colorScheme.onPrimary,
                                    tooltip: 'Logout',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AspectRatio(
                            aspectRatio: 1,
                            child: const LevelWidget(),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddTaskDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text("Add Task"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            taskProvider.isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : incompleteTasks.isEmpty
                    ? SliverFillRemaining(
                        child: Container(
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
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap the + button to add your first task',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final task = incompleteTasks[index];
                              return TaskTile(
                                task: task,
                                onDelete: () => taskProvider.deleteTask(task.id),
                                onToggleComplete: () =>
                                    taskProvider.toggleCompleted(task.id),
                                onEdit: () => _showEditDialog(context, task),
                              );
                            },
                            childCount: incompleteTasks.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

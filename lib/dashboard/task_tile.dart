import 'package:flutter/material.dart';
import 'task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onToggleComplete,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      task.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        task.isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child:
                    task.isCompleted
                        ? Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        )
                        : null,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color:
                            task.isCompleted
                                ? theme.colorScheme.onSurface.withOpacity(0.6)
                                : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${_formatDate(task.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: onEdit,
                splashRadius: 20,
                tooltip: 'Delete task',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: onDelete,
                splashRadius: 20,
                tooltip: 'Delete task',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../task_provider.dart';

class CommitCalendar extends StatefulWidget {
  const CommitCalendar({super.key});

  @override
  State<CommitCalendar> createState() => _CommitCalendarState();
}

class _CommitCalendarState extends State<CommitCalendar> {
  final supabase = Supabase.instance.client;
  Map<DateTime, int> _completionCounts = {};
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _fetchCompletionCounts();
    _setupRealtimeUpdates();
  }

  Future<void> _fetchCompletionCounts() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    final response = await supabase
        .from('tasks')
        .select('created_at')
        .eq('user_id', userId)
        .eq('is_completed', true)
        .gte('created_at', firstDay.toIso8601String())
        .lte('created_at', lastDay.toIso8601String());

    final counts = <DateTime, int>{};
    for (final task in response) {
      final date = DateTime.parse(task['created_at'] as String).toLocal();
      final dateOnly = DateTime(date.year, date.month, date.day);
      counts.update(dateOnly, (count) => count + 1, ifAbsent: () => 1);
    }

    if (mounted) setState(() => _completionCounts = counts);
  }

  void refresh() async {
    await _fetchCompletionCounts();
  }

  void _setupRealtimeUpdates() {
    supabase
        .channel('tasks')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          callback: (_) => _fetchCompletionCounts(),
        )
        .subscribe();
  }

  @override
  void dispose() {
    supabase.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, size: 18),
                  onPressed: () => taskProvider.fetchTasks(showCompleted: true),
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildCalendarGrid(),
            const SizedBox(height: 4),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      padding: EdgeInsets.zero,
      childAspectRatio: 1.1,
      children: List.generate(42, (index) {
        if (index < firstWeekday - 1 ||
            index >= firstWeekday - 1 + daysInMonth) {
          return const SizedBox.shrink();
        }
        final day = index - firstWeekday + 2;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        return _buildDaySquare(date);
      }),
    );
  }

  Widget _buildDaySquare(DateTime date) {
    final completedCount = _completionCounts[date] ?? 0;
    final isToday = date.isSameDate(DateTime.now());

    Color color;
    if (completedCount == 0) {
      color = Theme.of(context).colorScheme.primary.withOpacity(0.2);
    } else if (completedCount == 1) {
      color = Theme.of(context).colorScheme.primary.withOpacity(0.4);
    } else if (completedCount == 2) {
      color = Theme.of(context).colorScheme.primary.withOpacity(0.6);
    } else {
      color = Theme.of(context).colorScheme.primary;
    }

    return Tooltip(
      message:
          completedCount == 0
              ? 'No completed tasks'
              : '$completedCount completed task${completedCount > 1 ? "s" : ""}',
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border:
              isToday
                  ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  )
                  : null,
        ),
        child: Center(
          child: Text(
            "",
            style: TextStyle(
              fontSize: 11,
              color: completedCount > 0 ? Colors.white : Colors.grey[600],
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Less', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          Row(
            children: [
              _LegendSquare(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.8),
              ),
              _LegendSquare(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              _LegendSquare(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              _LegendSquare(color: Theme.of(context).colorScheme.primary),
            ],
          ),
          Text('More', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _LegendSquare extends StatelessWidget {
  final Color color;

  const _LegendSquare({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

extension DateUtils on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

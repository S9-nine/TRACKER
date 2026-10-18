import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../main.dart';
import '../theme/tally_colors.dart';
import 'task_sheet.dart';
import 'widgets.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Row(
              children: [
                Expanded(child: Text('Goals', style: Theme.of(context).textTheme.headlineLarge)),
                FilledButton.icon(
                  onPressed: () => _showGoalSheet(context),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New goal'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (store.goals.isEmpty)
              const EmptyState(
                icon: Icons.flag_outlined,
                title: 'No goals yet',
                body: 'A goal groups the daily tasks that move you toward it — like "Run a 5K".',
              )
            else
              for (final g in store.goals) ...[
                _GoalCard(goal: g),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = store.doneByGoal[goal.id] ?? 0;
    final tasks = store.tasksForGoal(goal.id!);
    final nexts = tasks.map(store.nextDue).whereType<DateTime>().toList()..sort();
    final target = goal.target;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showGoalDetail(context, goal),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(12)),
                    child: Text(goal.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title, style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
                          style: TextStyle(color: c.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (target != null)
                    Text('${(done * 100 / target).clamp(0, 100).round()}%',
                        style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              if (target != null) ...[
                ThinProgress(done / target),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Text(
                    target != null ? '$done / $target sessions' : '$done sessions done',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (nexts.isNotEmpty)
                    Text('Next ${_when(nexts.first)}', style: TextStyle(color: c.textMuted, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _when(DateTime d) {
    final today = store.today;
    final day = dateOnly(d);
    final time = DateFormat.jm().format(d);
    if (day == today) return 'today $time';
    if (day == today.add(const Duration(days: 1))) return 'tomorrow $time';
    return '${DateFormat('EEE').format(d)} $time';
  }
}

Future<void> _showGoalDetail(BuildContext context, Goal goal) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final c = context.colors;
          final tasks = store.tasksForGoal(goal.id!);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(goal.title, style: Theme.of(context).textTheme.headlineSmall)),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: c.danger),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete goal?'),
                            content: const Text('Its tasks stay on your Today list, without a goal.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (ok != true) return;
                        await store.deleteGoal(goal.id!);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SectionLabel('Tasks'),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('No tasks yet.', style: TextStyle(color: c.textMuted)),
                  ),
                for (final t in tasks)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(t.intensity == Intensity.alarm ? Icons.alarm : Icons.notifications_none,
                        color: c.textMuted),
                    title: Text(t.title),
                    subtitle: Text('${formatMinute(t.minuteOfDay)} · ${formatDays(t.days)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showTaskSheet(context, task: t),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => showTaskSheet(context, goalId: goal.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add task to this goal'),
                ),
              ],
            ),
          );
        },
      ),
    );

Future<void> _showGoalSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _GoalSheet(),
    );

class _GoalSheet extends StatefulWidget {
  const _GoalSheet();

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  static const _emojis = ['🎯', '🏃', '📚', '💻', '🧘', '💪', '🎨', '🌱', '💧', '🎵'];

  final _title = TextEditingController();
  final _target = TextEditingController();
  String _emoji = _emojis.first;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    final target = int.tryParse(_target.text.trim());
    await store.addGoal(Goal(
      title: _title.text.trim(),
      emoji: _emoji,
      target: target != null && target > 0 ? target : null,
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('New goal', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. Run a 5K'),
              onChanged: (_) => setState(() {}),
            ),
            const SectionLabel('Icon'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in _emojis)
                  InkWell(
                    onTap: () => setState(() => _emoji = e),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: e == _emoji ? c.accentSoft : c.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: e == _emoji ? Border.all(color: c.accent, width: 1.5) : null,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
              ],
            ),
            const SectionLabel('Target (optional)'),
            TextField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Sessions to complete, e.g. 30'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _title.text.trim().isEmpty || _saving ? null : _save,
              child: const Text('Create goal'),
            ),
          ],
        ),
      ),
    );
  }
}

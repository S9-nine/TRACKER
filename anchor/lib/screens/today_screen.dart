import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../main.dart';
import '../theme/anchor_colors.dart';
import 'settings_screen.dart';
import 'setup_screen.dart';
import 'task_sheet.dart';
import 'widgets.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final today = store.today;
            final tasks = store.tasksOn(today);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              children: [
                _Header(today: today),
                const _SetupBanner(),
                if (store.awaitingToday().isNotEmpty) _CheckIn(tasks: store.awaitingToday()),
                const SizedBox(height: 20),
                _ProgressCard(tasks: tasks),
                const SizedBox(height: 12),
                const _WeekStrip(),
                SectionLabel('Today · ${tasks.length} scheduled'),
                if (tasks.isEmpty)
                  const EmptyState(
                    icon: Icons.alarm_add_outlined,
                    title: 'Nothing scheduled',
                    body: 'Tap + to add a task. Alarm tasks ring at their time, even with the app closed.',
                  )
                else
                  for (final t in tasks) ...[
                    _TaskTile(task: t, day: today),
                    const SizedBox(height: 8),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('EEEE, d MMMM').format(today), style: TextStyle(color: c.textMuted)),
              const SizedBox(height: 2),
              Text('Today', style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          icon: Icon(Icons.settings_outlined, color: c.textMuted),
        ),
      ],
    );
  }
}

/// Shown when a permission alarms can't work without has been turned off.
class _SetupBanner extends StatefulWidget {
  const _SetupBanner();

  @override
  State<_SetupBanner> createState() => _SetupBannerState();
}

class _SetupBannerState extends State<_SetupBanner> {
  late final AppLifecycleListener _lifecycle;
  bool _ok = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    _check();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final ok = await PermissionHealth.essentialsOk();
    if (mounted && ok != _ok) setState(() => _ok = ok);
  }

  @override
  Widget build(BuildContext context) {
    if (_ok) return const SizedBox.shrink();
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SetupScreen()));
            _check();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: c.accent),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Alarms may not ring — a permission is off.',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text('Fix', style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks about today's tasks whose time passed without an answer — for example
/// an alarm stopped from its notification instead of the ring screen.
class _CheckIn extends StatelessWidget {
  const _CheckIn({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final day = dayKey(store.today);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Did you do it?', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('These went off without an answer.', style: TextStyle(color: c.textMuted, fontSize: 13)),
              const SizedBox(height: 8),
              for (final t in tasks)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: '  ${formatMinute(t.minuteOfDay)}', style: TextStyle(color: c.textMuted)),
                          ]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => store.log(t.id!, day, LogStatus.skipped),
                        style: TextButton.styleFrom(foregroundColor: c.textMuted),
                        child: const Text('Skip'),
                      ),
                      FilledButton(
                        onPressed: () => store.log(t.id!, day, LogStatus.done),
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 38)),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final today = store.today;
    final done = tasks.where((t) => store.statusOf(t, today) == LogStatus.done).length;
    final next = store.nextToday();
    final total = tasks.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$done', style: Theme.of(context).textTheme.headlineLarge),
                Text(' / $total done', style: TextStyle(color: c.textMuted, fontSize: 16)),
                const Spacer(),
                if (total > 0)
                  Text('${(done * 100 / total).round()}%',
                      style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
            ThinProgress(total == 0 ? 0 : done / total),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.alarm, size: 16, color: next == null ? c.textMuted : c.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    next == null
                        ? (total == 0 ? 'No tasks yet' : 'Nothing else today')
                        : 'Next: ${next.title} · ${formatMinute(next.minuteOfDay)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: next == null ? c.textMuted : c.text, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final today = store.today;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final d in store.week())
              Column(
                children: [
                  Text(
                    DateFormat('E').format(d.day).substring(0, 1),
                    style: TextStyle(
                      fontSize: 12,
                      color: d.day == today ? c.text : c.textMuted,
                      fontWeight: d.day == today ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DayDot(summary: d, isToday: d.day == today, isPast: d.day.isBefore(today)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.summary, required this.isToday, required this.isPast});

  final DaySummary summary;
  final bool isToday;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final complete = summary.scheduled > 0 && summary.done == summary.scheduled;
    final partial = summary.done > 0 && !complete;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: complete ? c.done : (partial ? c.doneSoft : c.surfaceMuted),
        border: isToday ? Border.all(color: c.accent, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: complete
          ? Icon(Icons.check, size: 16, color: c.surface)
          : Text('${summary.day.day}',
              style: TextStyle(fontSize: 11, color: isPast || isToday ? c.text : c.textMuted)),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.day});

  final Task task;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = store.statusOf(task, day);
    final goal = store.goalById(task.goalId);
    final due = task.dueOn(day);
    final now = DateTime.now();
    final isNext = store.nextToday()?.id == task.id;
    final snoozes = store.snoozesOf(task, day);

    final key = dayKey(day);
    final Widget trailing = switch (status) {
      LogStatus.done => Pill('Done', color: c.done, background: c.doneSoft),
      LogStatus.skipped => Pill('Skipped', color: c.skipped, background: c.surfaceMuted),
      _ when isNext => Pill(formatUntil(due.difference(now)), color: c.accent, background: c.accentSoft),
      _ when store.isAwaiting(task, day) => Pill('No answer', color: c.textMuted, background: c.surfaceMuted),
      _ => const SizedBox.shrink(),
    };

    final subtitle = [
      formatMinute(task.minuteOfDay),
      ?goal?.title,
      if (snoozes > 0) 'snoozed ${snoozes}x',
    ].join(' · ');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isNext ? c.accent : c.border, width: isNext ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showTaskSheet(context, task: task),
        onLongPress: () => _menu(context, status, key),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => status == null
                    ? store.log(task.id!, key, LogStatus.done)
                    : store.undo(task.id!, key),
                icon: Icon(
                  switch (status) {
                    LogStatus.done => Icons.check_circle,
                    LogStatus.skipped => Icons.remove_circle_outline,
                    _ => Icons.radio_button_unchecked,
                  },
                  color: switch (status) {
                    LogStatus.done => c.done,
                    LogStatus.skipped => c.skipped,
                    _ => c.textMuted,
                  },
                  size: 28,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: status == null ? c.text : c.textMuted,
                        decoration: status == LogStatus.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (task.intensity == Intensity.alarm) ...[
                          Icon(Icons.alarm, size: 13, color: c.textMuted),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(subtitle,
                              overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textMuted, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _menu(BuildContext context, LogStatus? status, String key) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == null) ...[
              ListTile(
                  leading: const Icon(Icons.check), title: const Text('Mark done'),
                  onTap: () => Navigator.pop(context, 'done')),
              ListTile(
                  leading: const Icon(Icons.block), title: const Text('Skip today'),
                  onTap: () => Navigator.pop(context, 'skip')),
            ] else
              ListTile(
                  leading: const Icon(Icons.undo), title: const Text('Undo'),
                  onTap: () => Navigator.pop(context, 'undo')),
            ListTile(
                leading: const Icon(Icons.edit_outlined), title: const Text('Edit task'),
                onTap: () => Navigator.pop(context, 'edit')),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'done':
        await store.log(task.id!, key, LogStatus.done);
      case 'skip':
        await store.log(task.id!, key, LogStatus.skipped);
      case 'undo':
        await store.undo(task.id!, key);
      case 'edit':
        await showTaskSheet(context, task: task);
    }
  }
}

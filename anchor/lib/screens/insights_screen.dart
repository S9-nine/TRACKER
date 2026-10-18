import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/store.dart';
import '../main.dart';
import '../theme/anchor_colors.dart';
import 'widgets.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final hasTasks = store.tasks.isNotEmpty;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Text('Insights', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 20),
              if (!hasTasks)
                const EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'Nothing to show yet',
                  body: 'Add a task and answer a few alarms — streaks and trends build up here.',
                )
              else ...[
                const _Stats(),
                const SectionLabel('Last 4 weeks'),
                const _Grid(),
                if (store.goals.isNotEmpty) ...[
                  const SectionLabel('Goals'),
                  for (final g in store.goals) ...[
                    _GoalRow(goalId: g.id!),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final thisWeek = store.weekRate(store.weekStart);
    final lastWeek = store.weekRate(store.weekStart.subtract(const Duration(days: 7)));
    String pct(double? v) => v == null ? '—' : '${(v * 100).round()}%';

    String? trend;
    if (thisWeek != null && lastWeek != null) {
      final diff = ((thisWeek - lastWeek) * 100).round();
      trend = diff == 0 ? 'same as last week' : '${diff > 0 ? '+' : ''}$diff% vs last week';
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _Stat(value: '${store.currentStreak()}', label: 'day streak')),
            const SizedBox(width: 12),
            Expanded(child: _Stat(value: '${store.bestStreak()}', label: 'best streak')),
          ],
        ),
        const SizedBox(height: 12),
        _Stat(
          value: pct(thisWeek),
          label: 'done this week',
          footer: trend == null ? null : Text(trend, style: TextStyle(color: c.textMuted, fontSize: 13)),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.footer});

  final String value;
  final String label;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineLarge),
            Text(label, style: TextStyle(color: c.textMuted)),
            if (footer != null) ...[const SizedBox(height: 6), footer!],
          ],
        ),
      ),
    );
  }
}

/// Four rows of seven days, Monday first, ending with the current week.
class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final start = store.weekStart.subtract(const Duration(days: 21));
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 44),
                for (final l in letters)
                  Expanded(
                    child: Center(child: Text(l, style: TextStyle(color: c.textMuted, fontSize: 12))),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (var w = 0; w < 4; w++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        DateFormat('d MMM').format(start.add(Duration(days: w * 7))),
                        style: TextStyle(color: c.textMuted, fontSize: 11),
                      ),
                    ),
                    for (final d in store.week(start.add(Duration(days: w * 7))))
                      Expanded(child: Center(child: _Cell(summary: d))),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: c.done, label: 'All done'),
                _Legend(color: c.doneSoft, label: 'Some'),
                _Legend(color: c.surfaceMuted, label: 'None'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.summary});

  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final future = summary.day.isAfter(store.today);
    final Color color;
    if (future || summary.scheduled == 0) {
      color = Colors.transparent;
    } else if (summary.complete) {
      color = c.done;
    } else if (summary.done > 0) {
      color = c.doneSoft;
    } else {
      color = c.surfaceMuted;
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: summary.day == store.today
            ? Border.all(color: c.accent, width: 2)
            : (future || summary.scheduled == 0 ? Border.all(color: c.border) : null),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: c.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goalId});

  final int goalId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final goal = store.goalById(goalId)!;
    final done = store.doneByGoal[goalId] ?? 0;
    final target = goal.target;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                Text(target == null ? '$done done' : '$done / $target',
                    style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500)),
              ],
            ),
            if (target != null) ...[
              const SizedBox(height: 10),
              ThinProgress(done / target),
            ],
          ],
        ),
      ),
    );
  }
}

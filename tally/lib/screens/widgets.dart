import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/tally_colors.dart';

String formatMinute(int minuteOfDay) =>
    DateFormat.jm().format(DateTime(2000, 1, 1, minuteOfDay ~/ 60, minuteOfDay % 60));

String formatDays(int days) {
  if (days == 0x7F) return 'Every day';
  if (days == 0x1F) return 'Weekdays';
  if (days == 0x60) return 'Weekends';
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return [for (var i = 0; i < 7; i++) if (days & (1 << i) != 0) names[i]].join(', ');
}

String formatUntil(Duration d) {
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return 'in ${d.inMinutes} min';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return m == 0 ? 'in ${h}h' : 'in ${h}h ${m}m';
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Row(
        children: [
          Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class ThinProgress extends StatelessWidget {
  const ThinProgress(this.value, {super.key, this.color});

  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 6,
        backgroundColor: c.surfaceMuted,
        color: color ?? c.accent,
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.color, required this.background});

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(99)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 36, color: c.textMuted),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body, textAlign: TextAlign.center, style: TextStyle(color: c.textMuted)),
        ],
      ),
    );
  }
}

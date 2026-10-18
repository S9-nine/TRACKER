import 'package:flutter/material.dart';

import '../data/models.dart';
import '../main.dart';
import '../theme/anchor_colors.dart';
import 'widgets.dart';

Future<void> showTaskSheet(BuildContext context, {Task? task, int? goalId}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TaskSheet(task: task, goalId: goalId),
    );

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({this.task, this.goalId});

  final Task? task;
  final int? goalId;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  late final _title = TextEditingController(text: widget.task?.title);
  late int? _goalId = widget.task?.goalId ?? widget.goalId;
  late int _minute = widget.task?.minuteOfDay ?? _defaultMinute();
  late int _days = widget.task?.days ?? everyDay;
  late Intensity _intensity = widget.task?.intensity ?? Intensity.alarm;
  bool _saving = false;

  static int _defaultMinute() {
    final t = DateTime.now().add(const Duration(minutes: 2));
    return t.hour * 60 + t.minute;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _valid => _title.text.trim().isNotEmpty && _days != 0;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _minute ~/ 60, minute: _minute % 60),
    );
    if (picked != null) setState(() => _minute = picked.hour * 60 + picked.minute);
  }

  Future<void> _save() async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    final base = widget.task ?? Task(title: '', minuteOfDay: 0);
    await store.saveTask(base.copyWith(
      title: _title.text.trim(),
      goalId: _goalId,
      clearGoal: _goalId == null,
      minuteOfDay: _minute,
      days: _days,
      intensity: _intensity,
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('Its alarms and history will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await store.deleteTask(widget.task!.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final editing = widget.task != null;
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(editing ? 'Edit task' : 'New task', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                if (editing)
                  IconButton(onPressed: _delete, icon: Icon(Icons.delete_outline, color: c.danger)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: !editing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. Run 20 min'),
              onChanged: (_) => setState(() {}),
            ),
            const SectionLabel('Time'),
            Material(
              color: c.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickTime,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: c.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Text(formatMinute(_minute), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('Change', style: TextStyle(color: c.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            SectionLabel('Repeat', trailing: Text(formatDays(_days), style: TextStyle(color: c.textMuted, fontSize: 12))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  _DayToggle(
                    label: dayLetters[i],
                    selected: _days & (1 << i) != 0,
                    onTap: () => setState(() => _days ^= 1 << i),
                  ),
              ],
            ),
            if (store.goals.isNotEmpty) ...[
              const SectionLabel('Goal'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('None'),
                    selected: _goalId == null,
                    onSelected: (_) => setState(() => _goalId = null),
                  ),
                  for (final g in store.goals)
                    ChoiceChip(
                      label: Text('${g.emoji} ${g.title}'),
                      selected: _goalId == g.id,
                      onSelected: (_) => setState(() => _goalId = g.id),
                    ),
                ],
              ),
            ],
            const SectionLabel('Alert'),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<Intensity>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: Intensity.nudge, label: Text('Nudge')),
                  ButtonSegment(value: Intensity.reminder, label: Text('Reminder')),
                  ButtonSegment(value: Intensity.alarm, label: Text('Alarm'), icon: Icon(Icons.alarm, size: 18)),
                ],
                selected: {_intensity},
                onSelectionChanged: (s) => setState(() => _intensity = s.first),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              switch (_intensity) {
                Intensity.alarm => 'Rings full-screen, even on silent, until you answer it.',
                Intensity.reminder => 'A notification with sound, and Done / Skip buttons.',
                Intensity.nudge => 'A quiet notification — no sound.',
              },
              style: TextStyle(color: c.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _valid && !_saving ? _save : null,
              child: Text(editing ? 'Save changes' : 'Add task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? c.accent : c.surfaceMuted),
        child: Text(
          label,
          style: TextStyle(color: selected ? c.onAccent : c.text, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

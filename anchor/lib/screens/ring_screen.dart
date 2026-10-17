import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../alarms/alarm_scheduler.dart';
import '../data/models.dart';
import '../main.dart';
import '../theme/anchor_colors.dart';

/// Full-screen ring UI. Done / Snooze / Skip each write a log for the occurrence.
class RingScreen extends StatefulWidget {
  const RingScreen({required this.alarm, super.key});

  final AlarmSettings alarm;

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> {
  StreamSubscription<AlarmSet>? _ringing;
  late final AlarmTarget? _target = AlarmTarget.of(widget.alarm);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Stopped elsewhere (e.g. the notification's Stop button) — close.
    _ringing = Alarm.ringing.listen((set) {
      if (set.containsId(widget.alarm.id) || _busy) return;
      _close();
    });
  }

  @override
  void dispose() {
    _ringing?.cancel();
    super.dispose();
  }

  void _close() {
    _ringing?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _answer(LogStatus status) async {
    if (_busy) return;
    setState(() => _busy = true);
    if (status == LogStatus.snoozed) {
      await AlarmScheduler.snooze(widget.alarm);
    } else {
      await Alarm.stop(widget.alarm.id);
    }
    final t = _target;
    if (t != null) await store.log(t.taskId, t.day, status);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final task = _target == null ? null : store.taskById(_target.taskId);
    final goal = store.goalById(task?.goalId);
    final title = task?.title ?? widget.alarm.notificationSettings.title;
    final now = DateTime.now();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: c.ringBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMM').format(now).toUpperCase(),
                  style: TextStyle(color: c.ringText.withValues(alpha: 0.6), letterSpacing: 1.2, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat.jm().format(now),
                  style: TextStyle(color: c.ringText, fontSize: 64, fontWeight: FontWeight.w300, letterSpacing: -2),
                ),
                const Spacer(),
                if (goal != null)
                  Text(
                    '${goal.emoji}  ${goal.title}',
                    style: TextStyle(color: c.ringText.withValues(alpha: 0.6), fontSize: 16),
                  ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(color: c.ringText, fontSize: 36, fontWeight: FontWeight.w700, height: 1.1),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _busy ? null : () => _answer(LogStatus.done),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                  child: const Text('Done'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GhostButton(
                        label: 'Snooze ${AlarmScheduler.snoozeDuration.inMinutes} min',
                        onPressed: _busy ? null : () => _answer(LogStatus.snoozed),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GhostButton(
                        label: 'Skip',
                        onPressed: _busy ? null : () => _answer(LogStatus.skipped),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ringText,
        minimumSize: const Size.fromHeight(56),
        side: BorderSide(color: c.ringText.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

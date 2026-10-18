import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../alarms/alarm_scheduler.dart';
import '../data/models.dart';
import '../main.dart';
import '../theme/tally_colors.dart';
import 'effects.dart';

/// Full-screen ring UI: pulsing rings in the mood colour, a big clock, the task
/// with its goal and cue, and slide-to-tally. Done / Snooze / Skip are logged.
class RingScreen extends StatefulWidget {
  const RingScreen({required this.alarm, super.key});

  final AlarmSettings alarm;

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<AlarmSet>? _ringing;
  Timer? _clock;
  late final AlarmTarget? _target = AlarmTarget.of(widget.alarm);
  late final AnimationController _finish =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  bool _busy = false;
  bool _completed = false;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Stopped elsewhere (e.g. the notification's Stop button) — close.
    _ringing = Alarm.ringing.listen((set) {
      if (set.containsId(widget.alarm.id) || _busy) return;
      _close();
    });
    _clock = Timer.periodic(const Duration(seconds: 5), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _ringing?.cancel();
    _clock?.cancel();
    _finish.dispose();
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
      HapticFeedback.lightImpact();
      await AlarmScheduler.snooze(widget.alarm, store.settings.snooze);
    } else {
      await Alarm.stop(widget.alarm.id);
    }
    final t = _target;
    if (t != null) await store.log(t.taskId, t.day, status);
    if (status == LogStatus.done) {
      setState(() => _completed = true);
      await _finish.forward();
      await Future<void>.delayed(const Duration(milliseconds: 1100));
    }
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final task = _target == null ? null : store.taskById(_target.taskId);
    final goal = store.goalById(task?.goalId);
    final title = task?.title ?? widget.alarm.notificationSettings.title;
    final snoozes = task == null ? 0 : store.snoozesOf(task, DateTime.parse(_target!.day));
    // Read before the Done log lands, so it names the session this Done completes.
    final session = task == null ? null : store.nextSession(task) - (_completed ? 1 : 0);
    final accent = c.ringAccent;

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: c.ringBackground,
          body: Stack(
            children: [
              Positioned.fill(child: PulseRings(color: accent, calm: _completed)),
              if (store.mood == Mood.thriving)
                Positioned.fill(child: Embers(color: accent, count: 14, opacity: 0.32)),
              SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _completed
                      ? _Finished(
                          key: const ValueKey('done'),
                          anim: _finish,
                          accent: accent,
                          text: c.ringText,
                          muted: c.ringTextMuted,
                          headline: goal != null && session != null
                              ? 'Nice. ${goal.target != null ? '$session of ${goal.target}' : 'Session $session'}'
                              : 'Nice. Tallied.',
                          sub: goal?.target != null && session != null
                              ? '${goal!.title} is ${(session * 100 / goal.target!).clamp(0, 100).round()}% there'
                              : (store.currentStreak() > 0 ? '${store.currentStreak()} day streak' : 'One more mark'),
                        )
                      : Padding(
                          key: const ValueKey('ring'),
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEEE, d MMMM').format(_now),
                                style: TextStyle(color: c.ringTextMuted, fontSize: 14, letterSpacing: 0.4),
                              ),
                              Text(
                                DateFormat('h:mm').format(_now),
                                style: TextStyle(
                                  color: c.ringText,
                                  fontSize: 92,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -4,
                                  height: 1.05,
                                ),
                              ),
                              const Spacer(flex: 3),
                              if (goal != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: c.ringAccentSoft,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    goal.target != null
                                        ? '${goal.emoji}  ${goal.title} · session $session of ${goal.target}'
                                        : '${goal.emoji}  ${goal.title}',
                                    style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: c.ringText,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                              ),
                              if (task?.cue != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  task!.cue!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: c.ringTextMuted, fontSize: 16),
                                ),
                              ],
                              const Spacer(flex: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: _Pill(
                                      icon: Icons.snooze,
                                      label: snoozes >= 2
                                          ? 'Snooze again (${snoozes}x)'
                                          : 'Snooze ${store.settings.snoozeMinutes} min',
                                      background: c.ringSurface,
                                      color: c.ringText,
                                      onTap: _busy ? null : () => _answer(LogStatus.snoozed),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _Pill(
                                      label: 'Skip today',
                                      color: c.ringTextMuted,
                                      onTap: _busy ? null : () => _answer(LogStatus.skipped),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SlideToTally(
                                onComplete: () => _answer(LogStatus.done),
                                accent: accent,
                                track: c.ringSurface,
                                label: 'Slide to tally',
                                labelColor: c.ringTextMuted,
                                knobIcon: c.ringBackground,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished({
    super.key,
    required this.anim,
    required this.accent,
    required this.text,
    required this.muted,
    required this.headline,
    required this.sub,
  });

  final Animation<double> anim;
  final Color accent;
  final Color text;
  final Color muted;
  final String headline;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: anim,
            builder: (context, _) {
              final stroke = Curves.easeInOutCubic.transform(((anim.value - 0.15) / 0.6).clamp(0.0, 1.0));
              final pop = Curves.easeOutBack.transform((anim.value / 0.4).clamp(0.0, 1.0));
              return Transform.scale(
                scale: 0.7 + 0.3 * pop,
                child: SizedBox(
                  width: 180,
                  height: 140,
                  child: CustomPaint(
                    painter: TallyMarkPainter(progress: stroke, barColor: text, strokeColor: accent),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(headline, style: TextStyle(color: text, fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(sub, style: TextStyle(color: muted, fontSize: 15)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({this.icon, required this.label, this.background, required this.color, required this.onTap});

  final IconData? icon;
  final String label;
  final Color? background;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, color: color, size: 18), const SizedBox(width: 8)],
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../main.dart';
import '../theme/tally_colors.dart';
import 'effects.dart';
import 'settings_screen.dart';
import 'setup_screen.dart';
import 'task_sheet.dart';
import 'widgets.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    store.addListener(_maybeCelebrate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCelebrate());
  }

  @override
  void dispose() {
    store.removeListener(_maybeCelebrate);
    super.dispose();
  }

  /// Plays the day-complete or "you're on fire" moment once, when the store flags it.
  Future<void> _maybeCelebrate() async {
    if (_celebrating || !mounted) return;
    final today = dayKey(store.today);
    final thriving = store.celebrateThriving && store.settings.moodCelebratedDay != today;
    if (!store.celebrateDay && !thriving) return;
    _celebrating = true;
    store.celebrateDay = false;
    store.celebrateThriving = false;
    // Let the tally stroke on the tile finish first.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, a, _, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)), child: child),
      ),
      pageBuilder: (context, _, _) => _Celebration(thriving: thriving),
    );
    if (thriving) await store.saveSettings(store.settings.copyWith(moodCelebratedDay: today));
    _celebrating = false;
  }

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
            final awaiting = store.awaiting();
            final next = store.nextToday();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              children: [
                _Header(today: today),
                const _SetupBanner(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: awaiting.isEmpty ? const SizedBox(width: double.infinity) : _CheckIn(items: awaiting),
                ),
                const SizedBox(height: 20),
                _Entrance(index: 0, child: _MoodCard(tasks: tasks)),
                const SizedBox(height: 12),
                const _Entrance(index: 1, child: _WeekStrip()),
                SectionLabel('Today · ${tasks.length} scheduled'),
                if (tasks.isEmpty)
                  const EmptyState(
                    icon: Icons.alarm_add_outlined,
                    title: 'Start your first tally',
                    body: 'Add a small task with a time. It rings like an alarm, even with the app closed.',
                  )
                else ...[
                  for (final (i, t) in tasks.indexed) ...[
                    _Entrance(
                      key: ValueKey('in-${t.id}'),
                      index: i + 2,
                      child: _TaskTile(key: ValueKey(t.id), task: t, day: today, isNext: next?.id == t.id),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Swipe right to tally, left to rest. Tasks open an hour before their time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textMuted, fontSize: 12),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Celebration extends StatelessWidget {
  const _Celebration({required this.thriving});

  final bool thriving;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final streak = store.currentStreak();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Material(
          color: c.ringBackground,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (thriving) Positioned.fill(child: Embers(color: c.ringAccent, count: 24, opacity: 0.55)),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeInOutCubic,
                      builder: (context, t, _) => SizedBox(
                        width: 150,
                        height: 116,
                        child: CustomPaint(
                          painter: TallyMarkPainter(
                            progress: ((t - 0.2) / 0.8).clamp(0, 1),
                            barColor: c.ringText,
                            strokeColor: c.ringAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      thriving ? 'You\'re on fire' : 'Day complete',
                      style: TextStyle(color: c.ringText, fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      thriving
                          ? '$streak days strong. Keep the flame going.'
                          : (streak > 1 ? 'Every task tallied. $streak day streak.' : 'Every task tallied. That\'s how habits stick.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.ringTextMuted, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: c.ringAccent,
                        foregroundColor: c.ringBackground,
                      ),
                      child: const Text('Nice'),
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

/// Asks about tasks whose time passed without an answer — today's, plus
/// yesterday's during its one grace day (e.g. an alarm stopped from its notification).
class _CheckIn extends StatelessWidget {
  const _CheckIn({required this.items});

  final List<(Task, DateTime)> items;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
              Text("These went off without an answer. Yesterday's stay open until midnight.",
                  style: TextStyle(color: c.textMuted, fontSize: 13)),
              const SizedBox(height: 8),
              for (final (t, d) in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: d == store.today
                                    ? '  ${formatMinute(t.minuteOfDay)}'
                                    : '  yesterday ${formatMinute(t.minuteOfDay)}',
                                style: TextStyle(color: c.textMuted)),
                          ]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          store.log(t.id!, dayKey(d), LogStatus.skipped);
                        },
                        style: TextButton.styleFrom(foregroundColor: c.textMuted),
                        child: const Text('Skip'),
                      ),
                      FilledButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          store.log(t.id!, dayKey(d), LogStatus.done);
                        },
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

/// Today's progress, tinted by the mood — with faint embers when Thriving.
class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final today = store.today;
    final done = tasks.where((t) => store.statusOf(t, today) == LogStatus.done).length;
    final next = store.nextToday();
    final total = tasks.length;
    final mood = store.mood;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (mood == Mood.thriving) Positioned.fill(child: Embers(color: c.accent)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _WeekTally(days: store.lastDays(7), color: c.accent, track: c.surfaceMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Row(
                              key: ValueKey(mood),
                              children: [
                                if (mood == Mood.thriving) ...[
                                  _Flicker(child: Icon(Icons.local_fire_department_outlined, size: 16, color: c.accent)),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                              mood.label,
                              style: TextStyle(
                                color: c.accent,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                              ],
                            ),
                          ),
                          Text('last 7 days', style: TextStyle(color: c.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (total > 0)
                      Text('${(done * 100 / total).round()}%',
                          style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: done.toDouble()),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, v, _) => Text('${v.round()}',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text(' / $total tallied', style: TextStyle(color: c.textMuted, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(store.moodLine(), style: TextStyle(color: c.textMuted, fontSize: 13)),
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: total == 0 ? 0 : done / total),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => ThinProgress(v),
                ),
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
        ],
      ),
    );
  }
}

/// The last seven days as seven tally strokes, each as tall as that day's completion.
/// Today's stroke is outlined until it's earned; days with nothing scheduled are a dot.
class _WeekTally extends StatelessWidget {
  const _WeekTally({required this.days, required this.color, required this.track});

  final List<DaySummary> days;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, d) in days.indexed) ...[
            if (i > 0) const SizedBox(width: 5),
            TweenAnimationBuilder<double>(
              tween: Tween(end: d.scheduled == 0 ? 0 : d.rate),
              duration: Duration(milliseconds: 500 + 50 * i),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => SizedBox(
                width: 5,
                height: 34,
                child: CustomPaint(painter: _StrokePainter(v, d.scheduled == 0, i == days.length - 1, color, track)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.value, this.empty, this.isToday, this.color, this.track);

  final double value;
  final bool empty;
  final bool isToday;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final full = RRect.fromLTRBR(0, 0, w, size.height, Radius.circular(w / 2));
    if (empty) {
      canvas.drawCircle(Offset(w / 2, size.height - w / 2), w / 2, Paint()..color = track);
      return;
    }
    canvas.drawRRect(full, Paint()..color = track);
    final h = (size.height * value).clamp(value > 0 ? w : 0.0, size.height);
    if (h > 0) {
      canvas.drawRRect(
        RRect.fromLTRBR(0, size.height - h, w, size.height, Radius.circular(w / 2)),
        Paint()..color = color,
      );
    }
    if (isToday) {
      canvas.drawRRect(
        full.deflate(0.6),
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.value != value || old.empty != empty || old.color != color || old.track != track;
}

/// A gentle waver for the Thriving flame.
class _Flicker extends StatefulWidget {
  const _Flicker({required this.child});

  final Widget child;

  @override
  State<_Flicker> createState() => _FlickerState();
}

class _FlickerState extends State<_Flicker> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Opacity(
        opacity: 0.75 + 0.25 * Curves.easeInOut.transform(_c.value),
        child: Transform.scale(scale: 0.95 + 0.07 * _c.value, child: child),
      ),
      child: widget.child,
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
                  _DayDot(day: d.day, state: store.dayState(d.day), isToday: d.day == today),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day, required this.state, required this.isToday});

  final DateTime day;
  final DayState state;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final kept = state == DayState.kept;
    final rest = state == DayState.rest;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kept ? c.accent : (rest ? Colors.transparent : c.surfaceMuted),
        border: isToday && !kept
            ? Border.all(color: c.accent, width: 2)
            : (rest ? Border.all(color: c.accent, width: 1.5) : null),
      ),
      alignment: Alignment.center,
      child: kept
          ? SizedBox.square(dimension: 32, child: CustomPaint(painter: _MiniSlash(c.onAccent)))
          : rest
              ? Icon(Icons.bedtime_outlined, size: 14, color: c.accent)
              : Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 11,
                    color: state == DayState.broken ? c.skipped : (day.isAfter(store.today) ? c.textMuted : c.text),
                  ),
                ),
    );
  }
}

class _MiniSlash extends CustomPainter {
  _MiniSlash(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawLine(
      c.translate(-size.width * 0.18, size.height * 0.12),
      c.translate(size.width * 0.18, -size.height * 0.12),
      Paint()
        ..color = color
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniSlash old) => old.color != color;
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({super.key, required this.task, required this.day, required this.isNext});

  final Task task;
  final DateTime day;
  final bool isNext;

  void _toast(BuildContext context, String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        // Without this, a snackbar with an action stays until dismissed.
        persist: false,
        content: Text(text),
        action: action,
      ));
  }

  Future<void> _answer(BuildContext context, LogStatus status) async {
    final key = dayKey(day);
    if (status == LogStatus.done) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    _toast(
      context,
      status == LogStatus.done ? '${task.title} tallied' : '${task.title} skipped for today',
      action: SnackBarAction(label: 'Undo', onPressed: () => store.undo(task.id!, key)),
    );
    await store.log(task.id!, key, status);
  }

  void _tooEarly(BuildContext context) {
    HapticFeedback.lightImpact();
    final opens = task.dueOn(day).subtract(TallyStore.earlyWindow);
    _toast(context, 'Opens at ${DateFormat.jm().format(opens)} — you can tally up to an hour early.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = store.statusOf(task, day);
    final goal = store.goalById(task.goalId);
    final due = task.dueOn(day);
    final now = DateTime.now();
    final snoozes = store.snoozesOf(task, day);
    final window = store.windowOf(task, day);
    final early = status == null && window == TallyWindow.early;

    final Widget trailing = switch (status) {
      LogStatus.done => const SizedBox.shrink(),
      LogStatus.skipped => Pill('Rest', color: c.textMuted, background: c.surfaceMuted),
      _ when isNext => Pill(formatUntil(due.difference(now)), color: c.accent, background: c.accentSoft),
      _ when store.isAwaiting(task, day) => Pill('No answer', color: c.textMuted, background: c.surfaceMuted),
      _ => const SizedBox.shrink(),
    };

    final subtitle = [
      formatMinute(task.minuteOfDay),
      ?goal?.title,
      if (snoozes > 0) 'snoozed ${snoozes}x',
    ].join(' · ');

    final tile = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isNext ? c.accent : c.border, width: isNext ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showTaskSheet(context, task: task),
        onLongPress: () => _menu(context, status),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 16, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (status != null) {
                    // Answers aren't toggled by tapping — undo lives in the snackbar and long-press menu.
                    HapticFeedback.selectionClick();
                    _toast(
                      context,
                      status == LogStatus.done ? 'Already tallied' : 'Resting today',
                      action: store.canUndo(task, day)
                          ? SnackBarAction(label: 'Undo', onPressed: () => store.undo(task.id!, dayKey(day)))
                          : null,
                    );
                  } else if (early) {
                    _tooEarly(context);
                  } else {
                    _answer(context, LogStatus.done);
                  }
                },
                icon: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: early ? 0.45 : 1,
                  child: TallyCheck(
                    done: status == LogStatus.done,
                    skipped: status == LogStatus.skipped,
                    color: c.accent,
                    onColor: c.onAccent,
                    idleColor: c.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: status == null ? c.text : c.textMuted,
                          ),
                      child: Text(task.title),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          switch (task.intensity) {
                            Intensity.alarm => Icons.alarm,
                            Intensity.reminder => Icons.notifications_none,
                            Intensity.nudge => Icons.notifications_paused_outlined,
                          },
                          size: 13,
                          color: c.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(subtitle,
                              overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textMuted, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: trailing),
            ],
          ),
        ),
      ),
    );

    final pressable = _Pressable(child: tile);
    if (status != null) return pressable;
    return Dismissible(
      key: ValueKey('swipe-${task.id}-${dayKey(day)}'),
      // Not tallyable yet: only the skip direction works.
      direction: early ? DismissDirection.endToStart : DismissDirection.horizontal,
      dismissThresholds: const {DismissDirection.startToEnd: 0.3, DismissDirection.endToStart: 0.3},
      // The tile stays; the swipe is only a gesture for Done / Skip.
      confirmDismiss: (direction) async {
        _answer(context, direction == DismissDirection.startToEnd ? LogStatus.done : LogStatus.skipped);
        return false;
      },
      background: _SwipeBg(color: c.accent, onColor: c.onAccent, label: 'Tally', alignLeft: true),
      secondaryBackground: _SwipeBg(color: c.surfaceMuted, onColor: c.textMuted, label: 'Rest today', alignLeft: false),
      child: pressable,
    );
  }

  Future<void> _menu(BuildContext context, LogStatus? status) async {
    HapticFeedback.selectionClick();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == null) ...[
              if (store.canTally(task, day))
                ListTile(
                    leading: const Icon(Icons.check), title: const Text('Tally it'),
                    onTap: () => Navigator.pop(context, 'done')),
              ListTile(
                  leading: const Icon(Icons.bedtime_outlined), title: const Text('Rest today'),
                  subtitle: const Text('One rest day a week keeps your streak'),
                  onTap: () => Navigator.pop(context, 'skip')),
            ] else if (store.canUndo(task, day))
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
        await _answer(context, LogStatus.done);
      case 'skip':
        await _answer(context, LogStatus.skipped);
      case 'undo':
        await store.undo(task.id!, dayKey(day));
      case 'edit':
        await showTaskSheet(context, task: task);
    }
  }
}

/// Shrinks a touch while pressed, so cards feel physical.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child});

  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Fades and lifts a list item in once, staggered by [index], the first time it appears.
class _Entrance extends StatelessWidget {
  const _Entrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + 60 * index.clamp(0, 8)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        // Hold each item back a little so they arrive one after another.
        final delay = (0.15 * index.clamp(0, 8)) / (1 + 0.15 * index.clamp(0, 8));
        final v = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
        );
      },
      child: child,
    );
  }
}

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({required this.color, required this.onColor, required this.label, required this.alignLeft});

  final Color color;
  final Color onColor;
  final String label;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(label, style: TextStyle(color: onColor, fontWeight: FontWeight.w700, fontSize: 15)),
    );
  }
}
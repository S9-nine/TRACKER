import 'dart:async';

import 'package:flutter/foundation.dart';

import '../alarms/alarm_scheduler.dart';
import '../alarms/notification_scheduler.dart';
import 'database.dart';
import 'models.dart';

enum DayState { empty, open, kept, rest, broken }

class DaySummary {
  const DaySummary(this.day, this.scheduled, this.done, this.skipped);

  final DateTime day;
  final int scheduled;
  final int done;
  final int skipped;

  bool get complete => scheduled > 0 && done == scheduled;

  double get rate => scheduled == 0 ? 0 : done / scheduled;
}

/// When an occurrence can be answered. Rules in docs/PRODUCT.md ("Tally rules").
enum TallyWindow {
  /// Later today, more than [TallyStore.earlyWindow] away — can be skipped, not tallied yet.
  early,

  /// Within the early window, or its time has passed today.
  open,

  /// Yesterday's unanswered occurrence — can still be answered today, via check-in.
  grace,

  /// Any other day: read-only.
  closed,
}

/// App state: reads from SQLite, keeps alarms and notifications in step after every change.
///
/// Answers (Done / Skip / Undo) update memory first and notify at once, then
/// write to the database and re-sync alarms in the background, so taps feel instant.
class TallyStore extends ChangeNotifier {
  TallyStore(this.db);

  final TallyDb db;

  /// How far back history is loaded, for streaks and the Insights grid.
  static const historyDays = 84;

  /// How early before its time a task can be tallied.
  static const earlyWindow = Duration(minutes: 60);

  List<Goal> goals = [];
  List<Task> tasks = [];
  Map<int, int> doneByGoal = {};
  AppSettings settings = const AppSettings();

  /// `taskId|day` → final answer (done or skipped) for that occurrence.
  Map<String, LogStatus> _resolution = {};

  /// `taskId|day` → how many times it was snoozed.
  Map<String, int> _snoozes = {};

  // Derived values, computed on demand and cleared whenever the data changes.
  final _tasksOn = <String, List<Task>>{};
  final _summaries = <String, DaySummary>{};
  final _states = <String, DayState>{};
  int? _streak;
  int? _best;

  void _invalidate() {
    _tasksOn.clear();
    _summaries.clear();
    _states.clear();
    _streak = null;
    _best = null;
  }

  DateTime get today => dateOnly(DateTime.now());

  DateTime get yesterday => today.subtract(const Duration(days: 1));

  DateTime get weekStart => today.subtract(Duration(days: today.weekday - 1));

  Future<void> load() async {
    settings = await db.settings();
    goals = await db.goals();
    tasks = await db.tasks();
    doneByGoal = await db.doneCountByGoal();

    final logs = await db.logsBetween(
      today.subtract(const Duration(days: historyDays)),
      today.add(const Duration(days: AlarmScheduler.horizonDays)),
    );
    final resolution = <String, LogStatus>{};
    final snoozes = <String, int>{};
    for (final l in logs) {
      final key = '${l.taskId}|${l.day}';
      if (l.status == LogStatus.snoozed) {
        snoozes[key] = (snoozes[key] ?? 0) + 1;
      } else {
        resolution[key] = l.status; // logs are oldest first, so the latest wins
      }
    }
    _resolution = resolution;
    _snoozes = snoozes;
    _invalidate();
    await _refreshMood();
    notifyListeners();
  }

  /// Reloads and re-syncs alarms; called on start and whenever the app resumes.
  Future<void> refresh() async {
    await load();
    final stale = settings.alarmFormat != AlarmScheduler.format;
    await _sync(force: stale);
    if (stale) {
      settings = settings.copyWith(alarmFormat: AlarmScheduler.format);
      await db.saveSettings(settings);
    }
  }

  Future<void>? _syncing;
  bool _syncAgain = false;

  /// Re-syncs alarms and notifications. Calls made while one is running fold into a single follow-up.
  Future<void> _sync({bool force = false}) async {
    if (_syncing != null && !force) {
      _syncAgain = true;
      return _syncing;
    }
    final run = () async {
      do {
        _syncAgain = false;
        final resolved = _resolution.keys.toSet();
        try {
          await AlarmScheduler.sync(tasks: tasks, resolved: resolved, settings: settings, force: force);
        } catch (e, s) {
          debugPrint('Alarm sync failed: $e\n$s');
        }
        try {
          await NotificationScheduler.sync(tasks: tasks, resolved: resolved);
        } catch (e, s) {
          debugPrint('Notification sync failed: $e\n$s');
        }
        force = false;
      } while (_syncAgain);
    }();
    _syncing = run;
    try {
      await run;
    } finally {
      _syncing = null;
    }
  }

  Future<void> _changed() async {
    await load();
    await _sync();
  }

  Goal? goalById(int? id) => id == null ? null : goals.where((g) => g.id == id).firstOrNull;

  Task? taskById(int id) => tasks.where((t) => t.id == id).firstOrNull;

  List<Task> tasksOn(DateTime day) => _tasksOn.putIfAbsent(
        dayKey(day),
        () => tasks.where((t) => t.occursOn(day)).toList()..sort((a, b) => a.minuteOfDay.compareTo(b.minuteOfDay)),
      );

  List<Task> tasksForGoal(int goalId) => tasks.where((t) => t.goalId == goalId).toList();

  LogStatus? statusOf(Task t, DateTime day) => _resolution['${t.id}|${dayKey(day)}'];

  int snoozesOf(Task t, DateTime day) => _snoozes['${t.id}|${dayKey(day)}'] ?? 0;

  TallyWindow windowOf(Task t, DateTime day) {
    final d = dateOnly(day);
    if (d == today) {
      return DateTime.now().isBefore(t.dueOn(d).subtract(earlyWindow)) ? TallyWindow.early : TallyWindow.open;
    }
    if (d == yesterday) return TallyWindow.grace;
    return TallyWindow.closed;
  }

  bool canTally(Task t, DateTime day) {
    final w = windowOf(t, day);
    return w == TallyWindow.open || w == TallyWindow.grace;
  }

  /// Skipping can be planned ahead for today, or used to answer yesterday.
  bool canSkip(Task t, DateTime day) => windowOf(t, day) != TallyWindow.closed;

  /// Answers can be taken back on the day they belong to, or yesterday's during its grace day.
  bool canUndo(Task t, DateTime day) => windowOf(t, day) != TallyWindow.closed;

  /// Whether this occurrence's time has passed (after the task was created) with no answer.
  bool isAwaiting(Task t, DateTime day) {
    final due = t.dueOn(day);
    return statusOf(t, day) == null &&
        due.isBefore(DateTime.now()) &&
        (t.createdAt == null || due.isAfter(t.createdAt!));
  }

  /// Unanswered occurrences that can still be answered: today's that went off,
  /// and yesterday's during its grace day. Each with the day it belongs to.
  List<(Task, DateTime)> awaiting() => [
        for (final t in tasksOn(yesterday))
          if (isAwaiting(t, yesterday)) (t, yesterday),
        for (final t in tasksOn(today))
          if (isAwaiting(t, today)) (t, today),
      ];

  /// The next unanswered task still to come today.
  Task? nextToday() {
    final now = DateTime.now();
    for (final t in tasksOn(today)) {
      if (statusOf(t, today) == null && t.dueOn(today).isAfter(now)) return t;
    }
    return null;
  }

  DaySummary summaryOf(DateTime day) => _summaries.putIfAbsent(dayKey(day), () {
        final scheduled = tasksOn(day);
        var done = 0;
        var skipped = 0;
        for (final t in scheduled) {
          switch (statusOf(t, day)) {
            case LogStatus.done:
              done++;
            case LogStatus.skipped:
              skipped++;
            default:
          }
        }
        return DaySummary(dateOnly(day), scheduled.length, done, skipped);
      });

  List<DaySummary> week([DateTime? start]) =>
      List.generate(7, (i) => summaryOf((start ?? weekStart).add(Duration(days: i))));

  /// The last [n] days ending today, oldest first.
  List<DaySummary> lastDays(int n) => List.generate(n, (i) => summaryOf(today.subtract(Duration(days: n - 1 - i))));

  /// Share of scheduled tasks done in the week starting [start], counting only days so far.
  double? weekRate(DateTime start) {
    var scheduled = 0;
    var done = 0;
    for (final d in week(start)) {
      if (d.day.isAfter(today)) continue;
      scheduled += d.scheduled;
      done += d.done;
    }
    return scheduled == 0 ? null : done / scheduled;
  }

  bool _isRestShaped(DaySummary s) => s.scheduled > 0 && !s.complete && s.done + s.skipped == s.scheduled;

  /// How a day counts toward the streak. Rules in docs/PRODUCT.md.
  DayState dayState(DateTime day) => _states.putIfAbsent(dayKey(day), () {
        final s = summaryOf(day);
        if (s.scheduled == 0) return DayState.empty;
        if (s.complete) return DayState.kept;
        final answered = s.done + s.skipped == s.scheduled;
        // Today, and yesterday during its grace day, aren't final yet.
        if (!answered && (s.day == today || s.day == yesterday)) return DayState.open;
        if (!answered) return DayState.broken;
        // All answered with at least one skip: only the week's first such day is a rest day.
        final monday = s.day.subtract(Duration(days: s.day.weekday - 1));
        for (var d = monday; d.isBefore(s.day); d = d.add(const Duration(days: 1))) {
          if (_isRestShaped(summaryOf(d))) return DayState.broken;
        }
        return DayState.rest;
      });

  /// Kept days in a row, ending today (or earlier while recent days are still open).
  /// Rest days, open days and empty days neither break nor extend it.
  int currentStreak() => _streak ??= () {
        var streak = 0;
        for (var k = 0; k <= historyDays; k++) {
          switch (dayState(today.subtract(Duration(days: k)))) {
            case DayState.kept:
              streak++;
            case DayState.broken:
              return streak;
            case DayState.rest || DayState.empty || DayState.open:
              break;
          }
        }
        return streak;
      }();

  int bestStreak() => _best ??= () {
        var best = 0;
        var run = 0;
        for (var k = historyDays; k >= 0; k--) {
          switch (dayState(today.subtract(Duration(days: k)))) {
            case DayState.kept:
              run++;
              if (run > best) best = run;
            case DayState.broken:
              run = 0;
            case DayState.rest || DayState.empty || DayState.open:
              break;
          }
        }
        return best;
      }();

  /// Done share over the 7 days ending the day before [end]; null if fewer than [minDays] had tasks.
  double? rateBefore(DateTime end, {int minDays = 1}) {
    var scheduled = 0;
    var done = 0;
    var days = 0;
    for (var k = 1; k <= 7; k++) {
      final s = summaryOf(end.subtract(Duration(days: k)));
      if (s.scheduled == 0) continue;
      days++;
      scheduled += s.scheduled;
      done += s.done;
    }
    return days < minDays || scheduled == 0 ? null : done / scheduled;
  }

  /// Mood from the last full week vs the one before. Rules in docs/PRODUCT.md.
  Mood computeMood() {
    final rate = rateBefore(today, minDays: 3);
    if (rate == null) return Mood.steady;
    final previous = rateBefore(today.subtract(const Duration(days: 7)), minDays: 3);
    if (rate >= 0.85 && currentStreak() >= 3) return Mood.thriving;
    if (rate < 0.5 || (previous != null && previous - rate >= 0.2)) return Mood.slipping;
    return Mood.steady;
  }

  Mood get mood => settings.mood;

  /// One honest line about the week, for the Today card.
  String moodLine() {
    final rate = rateBefore(today, minDays: 1);
    final previous = rateBefore(today.subtract(const Duration(days: 7)), minDays: 1);
    final streak = currentStreak();
    switch (mood) {
      case Mood.thriving:
        return '$streak day streak — keep the flame going';
      case Mood.slipping:
        if (rate != null && previous != null && previous > rate) {
          return 'Down from ${(previous * 100).round()}% — today is the one that counts';
        }
        return 'One good day turns it around';
      case Mood.steady:
        if (rate == null) return 'Every tally is a vote for who you\'re becoming';
        return streak > 0 ? '$streak day streak' : '${(rate * 100).round()}% last week';
    }
  }

  /// Recomputes the mood once per day; flags [celebrateThriving] the day you first turn Thriving.
  Future<void> _refreshMood() async {
    final key = dayKey(today);
    if (settings.moodDay == key) return;
    final next = computeMood();
    final s = settings.copyWith(mood: next, moodDay: key);
    final becameThriving = next == Mood.thriving && settings.mood != Mood.thriving;
    settings = s;
    if (becameThriving) celebrateThriving = true;
    await db.saveSettings(s);
  }

  /// Set when today flips the mood to Thriving; Today shows the moment once and clears it.
  bool celebrateThriving = false;

  /// Set when the last task of today gets done; Today plays the day-complete moment and clears it.
  bool celebrateDay = false;

  /// Next time this task is due from now.
  DateTime? nextDue(Task t) {
    final now = DateTime.now();
    for (var k = 0; k < 8; k++) {
      final day = today.add(Duration(days: k));
      if (!t.occursOn(day) || statusOf(t, day) != null) continue;
      final due = t.dueOn(day);
      if (due.isAfter(now)) return due;
    }
    return null;
  }

  Future<void> addGoal(Goal g) async {
    await db.insertGoal(g);
    await _changed();
  }

  Future<void> deleteGoal(int id) async {
    await db.deleteGoal(id);
    await _changed();
  }

  Future<void> saveTask(Task t) async {
    if (t.id == null) {
      await db.insertTask(t);
    } else {
      await db.updateTask(t);
    }
    await _changed();
  }

  Future<void> deleteTask(int id) async {
    await db.deleteTask(id);
    await _changed();
  }

  void _countDone(int taskId, int delta) {
    final goalId = taskById(taskId)?.goalId;
    if (goalId == null) return;
    doneByGoal[goalId] = ((doneByGoal[goalId] ?? 0) + delta).clamp(0, 1 << 30);
  }

  /// Records an answer. Memory and UI update immediately; storage and alarms follow.
  Future<void> log(int taskId, String day, LogStatus status) async {
    final key = '$taskId|$day';
    final wasComplete = summaryOf(today).complete;
    if (status == LogStatus.snoozed) {
      _snoozes[key] = (_snoozes[key] ?? 0) + 1;
    } else {
      final previous = _resolution[key];
      _resolution[key] = status;
      if (previous != LogStatus.done && status == LogStatus.done) _countDone(taskId, 1);
      if (previous == LogStatus.done && status != LogStatus.done) _countDone(taskId, -1);
    }
    _invalidate();
    if (!wasComplete && summaryOf(today).complete && day == dayKey(today)) celebrateDay = true;
    notifyListeners();
    await db.insertLog(TaskLog(taskId: taskId, day: day, status: status, at: DateTime.now()));
    unawaited(_sync());
  }

  /// Session number this Done would be for the task's goal, e.g. 19 of 30.
  int nextSession(Task t) => (t.goalId == null ? 0 : doneByGoal[t.goalId] ?? 0) + 1;

  Future<void> undo(int taskId, String day) async {
    final key = '$taskId|$day';
    if (_resolution.remove(key) == LogStatus.done) _countDone(taskId, -1);
    _invalidate();
    notifyListeners();
    await db.clearResolution(taskId, day);
    unawaited(_sync());
  }

  Future<void> saveSettings(AppSettings s) async {
    final soundChanged =
        s.volume != settings.volume || s.vibrate != settings.vibrate || s.snoozeMinutes != settings.snoozeMinutes;
    settings = s;
    notifyListeners();
    await db.saveSettings(s);
    if (soundChanged) await _sync(force: true);
  }
}

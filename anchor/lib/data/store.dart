import 'package:flutter/foundation.dart';

import '../alarms/alarm_scheduler.dart';
import '../alarms/notification_scheduler.dart';
import 'database.dart';
import 'models.dart';

class DaySummary {
  const DaySummary(this.day, this.scheduled, this.done, this.skipped);

  final DateTime day;
  final int scheduled;
  final int done;
  final int skipped;

  bool get complete => scheduled > 0 && done == scheduled;
}

/// App state: reads from SQLite, keeps alarms and notifications in step after every change.
class AnchorStore extends ChangeNotifier {
  AnchorStore(this.db);

  final AnchorDb db;

  /// How far back history is loaded, for streaks and the Insights grid.
  static const historyDays = 84;

  List<Goal> goals = [];
  List<Task> tasks = [];
  Map<int, int> doneByGoal = {};
  AppSettings settings = const AppSettings();

  /// `taskId|day` → final answer (done or skipped) for that occurrence.
  Map<String, LogStatus> _resolution = {};

  /// `taskId|day` → how many times it was snoozed.
  Map<String, int> _snoozes = {};

  DateTime get today => dateOnly(DateTime.now());

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
    notifyListeners();
  }

  /// Reloads and re-syncs alarms; called on start and whenever the app resumes.
  Future<void> refresh() async {
    await load();
    await _sync();
  }

  Future<void> _sync({bool force = false}) async {
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
  }

  Future<void> _changed() async {
    await load();
    await _sync();
  }

  Goal? goalById(int? id) => id == null ? null : goals.where((g) => g.id == id).firstOrNull;

  Task? taskById(int id) => tasks.where((t) => t.id == id).firstOrNull;

  List<Task> tasksOn(DateTime day) => tasks.where((t) => t.occursOn(day)).toList()
    ..sort((a, b) => a.minuteOfDay.compareTo(b.minuteOfDay));

  List<Task> tasksForGoal(int goalId) => tasks.where((t) => t.goalId == goalId).toList();

  LogStatus? statusOf(Task t, DateTime day) => _resolution['${t.id}|${dayKey(day)}'];

  int snoozesOf(Task t, DateTime day) => _snoozes['${t.id}|${dayKey(day)}'] ?? 0;

  /// Whether this occurrence's time has passed (after the task was created) with no answer.
  bool isAwaiting(Task t, DateTime day) {
    final due = t.dueOn(day);
    return statusOf(t, day) == null &&
        due.isBefore(DateTime.now()) &&
        (t.createdAt == null || due.isAfter(t.createdAt!));
  }

  /// Today's tasks whose time has passed without Done or Skip — e.g. an alarm
  /// stopped from its notification, or one that was ignored.
  List<Task> awaitingToday() => tasksOn(today).where((t) => isAwaiting(t, today)).toList();

  /// The next unanswered task still to come today.
  Task? nextToday() {
    final now = DateTime.now();
    for (final t in tasksOn(today)) {
      if (statusOf(t, today) == null && t.dueOn(today).isAfter(now)) return t;
    }
    return null;
  }

  DaySummary summaryOf(DateTime day) {
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
    return DaySummary(day, scheduled.length, done, skipped);
  }

  List<DaySummary> week([DateTime? start]) =>
      List.generate(7, (i) => summaryOf((start ?? weekStart).add(Duration(days: i))));

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

  /// Consecutive fully-done days ending today (or yesterday, while today is still open).
  /// Days with nothing scheduled don't break a streak.
  int currentStreak() {
    var streak = 0;
    for (var k = 0; k <= historyDays; k++) {
      final s = summaryOf(today.subtract(Duration(days: k)));
      if (s.scheduled == 0) continue;
      if (s.complete) {
        streak++;
      } else if (k > 0) {
        break;
      }
    }
    return streak;
  }

  int bestStreak() {
    var best = 0;
    var run = 0;
    for (var k = historyDays; k >= 0; k--) {
      final s = summaryOf(today.subtract(Duration(days: k)));
      if (s.scheduled == 0) continue;
      if (s.complete) {
        run++;
        if (run > best) best = run;
      } else if (k > 0) {
        run = 0;
      }
    }
    return best;
  }

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

  Future<void> log(int taskId, String day, LogStatus status) async {
    await db.insertLog(TaskLog(taskId: taskId, day: day, status: status, at: DateTime.now()));
    await _changed();
  }

  Future<void> undo(int taskId, String day) async {
    await db.clearResolution(taskId, day);
    await _changed();
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

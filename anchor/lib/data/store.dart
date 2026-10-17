import 'package:flutter/foundation.dart';

import '../alarms/alarm_scheduler.dart';
import 'database.dart';
import 'models.dart';

class DaySummary {
  const DaySummary(this.day, this.scheduled, this.done);

  final DateTime day;
  final int scheduled;
  final int done;
}

/// App state: reads from SQLite, keeps alarms in step after every change.
class AnchorStore extends ChangeNotifier {
  AnchorStore(this._db);

  final AnchorDb _db;

  List<Goal> goals = [];
  List<Task> tasks = [];
  Map<int, int> doneByGoal = {};

  /// `taskId|day` → final answer (done or skipped) for that occurrence.
  Map<String, LogStatus> _resolution = {};

  /// `taskId|day` → how many times it was snoozed.
  Map<String, int> _snoozes = {};

  bool loaded = false;

  DateTime get today => dateOnly(DateTime.now());

  DateTime get weekStart => today.subtract(Duration(days: today.weekday - 1));

  Future<void> load() async {
    goals = await _db.goals();
    tasks = await _db.tasks();
    doneByGoal = await _db.doneCountByGoal();

    final logs = await _db.logsBetween(weekStart, today.add(const Duration(days: AlarmScheduler.horizonDays)));
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
    loaded = true;
    notifyListeners();
  }

  /// Reloads and re-syncs alarms; called on start and whenever the app resumes.
  Future<void> refresh() async {
    await load();
    await _syncAlarms();
  }

  Future<void> _syncAlarms() async {
    try {
      await AlarmScheduler.sync(tasks: tasks, resolved: _resolution.keys.toSet());
    } catch (e, s) {
      debugPrint('Alarm sync failed: $e\n$s');
    }
  }

  Future<void> _changed() async {
    await load();
    await _syncAlarms();
  }

  Goal? goalById(int? id) => id == null ? null : goals.where((g) => g.id == id).firstOrNull;

  Task? taskById(int id) => tasks.where((t) => t.id == id).firstOrNull;

  List<Task> tasksOn(DateTime day) => tasks.where((t) => t.occursOn(day)).toList()
    ..sort((a, b) => a.minuteOfDay.compareTo(b.minuteOfDay));

  List<Task> tasksForGoal(int goalId) => tasks.where((t) => t.goalId == goalId).toList();

  LogStatus? statusOf(Task t, DateTime day) => _resolution['${t.id}|${dayKey(day)}'];

  int snoozesOf(Task t, DateTime day) => _snoozes['${t.id}|${dayKey(day)}'] ?? 0;

  /// The next unanswered task still to come today.
  Task? nextToday() {
    final now = DateTime.now();
    for (final t in tasksOn(today)) {
      if (statusOf(t, today) == null && t.dueOn(today).isAfter(now)) return t;
    }
    return null;
  }

  List<DaySummary> week() => List.generate(7, (i) {
        final day = weekStart.add(Duration(days: i));
        final scheduled = tasksOn(day);
        final done = scheduled.where((t) => statusOf(t, day) == LogStatus.done).length;
        return DaySummary(day, scheduled.length, done);
      });

  /// Next time this task is due from now, if it repeats at all.
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
    await _db.insertGoal(g);
    await _changed();
  }

  Future<void> deleteGoal(int id) async {
    await _db.deleteGoal(id);
    await _changed();
  }

  Future<void> saveTask(Task t) async {
    if (t.id == null) {
      await _db.insertTask(t);
    } else {
      await _db.updateTask(t);
    }
    await _changed();
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    await _changed();
  }

  Future<void> log(int taskId, String day, LogStatus status) async {
    await _db.insertLog(TaskLog(taskId: taskId, day: day, status: status, at: DateTime.now()));
    await _changed();
  }

  Future<void> undo(int taskId, String day) async {
    await _db.clearResolution(taskId, day);
    await _changed();
  }
}

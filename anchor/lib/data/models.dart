/// How loudly a task asks for attention. Only [alarm] rings in this version.
enum Intensity { nudge, reminder, alarm }

enum LogStatus { done, skipped, snoozed }

/// `yyyy-mm-dd` key for a calendar day.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Bit for [d]'s weekday in [Task.days] (Monday = bit 0).
int weekdayBit(DateTime d) => 1 << (d.weekday - 1);

const everyDay = 0x7F;

class Goal {
  const Goal({this.id, required this.title, required this.emoji, this.target, required this.createdAt});

  final int? id;
  final String title;
  final String emoji;

  /// Number of completed task sessions that counts as reaching the goal.
  final int? target;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'target': target,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Goal.fromMap(Map<String, Object?> m) => Goal(
        id: m['id'] as int,
        title: m['title'] as String,
        emoji: m['emoji'] as String,
        target: m['target'] as int?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}

class Task {
  const Task({
    this.id,
    this.goalId,
    required this.title,
    required this.minuteOfDay,
    this.days = everyDay,
    this.intensity = Intensity.alarm,
  });

  final int? id;
  final int? goalId;
  final String title;

  /// Minutes after midnight the task is due, e.g. 18:30 → 1110.
  final int minuteOfDay;

  /// Weekday bitmask, Monday = bit 0.
  final int days;
  final Intensity intensity;

  bool occursOn(DateTime day) => days & weekdayBit(day) != 0;

  DateTime dueOn(DateTime day) => DateTime(day.year, day.month, day.day, minuteOfDay ~/ 60, minuteOfDay % 60);

  Task copyWith({int? goalId, bool clearGoal = false, String? title, int? minuteOfDay, int? days, Intensity? intensity}) =>
      Task(
        id: id,
        goalId: clearGoal ? null : goalId ?? this.goalId,
        title: title ?? this.title,
        minuteOfDay: minuteOfDay ?? this.minuteOfDay,
        days: days ?? this.days,
        intensity: intensity ?? this.intensity,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'goal_id': goalId,
        'title': title,
        'minute_of_day': minuteOfDay,
        'days': days,
        'intensity': intensity.index,
      };

  factory Task.fromMap(Map<String, Object?> m) => Task(
        id: m['id'] as int,
        goalId: m['goal_id'] as int?,
        title: m['title'] as String,
        minuteOfDay: m['minute_of_day'] as int,
        days: m['days'] as int,
        intensity: Intensity.values[m['intensity'] as int],
      );
}

class TaskLog {
  const TaskLog({this.id, required this.taskId, required this.day, required this.status, required this.at});

  final int? id;
  final int taskId;

  /// [dayKey] of the occurrence this log answers (not necessarily the day it was written).
  final String day;
  final LogStatus status;
  final DateTime at;

  Map<String, Object?> toMap() => {
        'id': id,
        'task_id': taskId,
        'day': day,
        'status': status.name,
        'at': at.millisecondsSinceEpoch,
      };

  factory TaskLog.fromMap(Map<String, Object?> m) => TaskLog(
        id: m['id'] as int,
        taskId: m['task_id'] as int,
        day: m['day'] as String,
        status: LogStatus.values.byName(m['status'] as String),
        at: DateTime.fromMillisecondsSinceEpoch(m['at'] as int),
      );
}

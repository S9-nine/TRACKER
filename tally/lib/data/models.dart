/// How loudly a task asks for attention: a quiet notification, one with sound, or a full-screen alarm.
enum Intensity { nudge, reminder, alarm }

enum LogStatus { done, skipped, snoozed }

enum AppThemeMode { system, light, dark }

/// How the last week went; tints the whole app. Rules in docs/PRODUCT.md.
enum Mood {
  slipping('Slipping'),
  steady('Steady'),
  thriving('Thriving');

  const Mood(this.label);
  final String label;
}

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
    this.createdAt,
    this.cue,
  });

  final int? id;
  final int? goalId;
  final String title;

  /// Minutes after midnight the task is due, e.g. 18:30 → 1110.
  final int minuteOfDay;

  /// Weekday bitmask, Monday = bit 0.
  final int days;
  final Intensity intensity;

  /// Null only for a task not yet saved.
  final DateTime? createdAt;

  /// Optional if-then cue, e.g. "After my morning coffee". Shown on the ring screen.
  final String? cue;

  /// Whether the task is scheduled on [day] (and already existed then).
  bool occursOn(DateTime day) =>
      days & weekdayBit(day) != 0 && (createdAt == null || !dateOnly(day).isBefore(dateOnly(createdAt!)));

  DateTime dueOn(DateTime day) => DateTime(day.year, day.month, day.day, minuteOfDay ~/ 60, minuteOfDay % 60);

  Task copyWith({
    int? goalId,
    bool clearGoal = false,
    String? title,
    int? minuteOfDay,
    int? days,
    Intensity? intensity,
    String? cue,
  }) =>
      Task(
        id: id,
        goalId: clearGoal ? null : goalId ?? this.goalId,
        title: title ?? this.title,
        minuteOfDay: minuteOfDay ?? this.minuteOfDay,
        days: days ?? this.days,
        intensity: intensity ?? this.intensity,
        createdAt: createdAt,
        cue: cue == null ? this.cue : (cue.trim().isEmpty ? null : cue.trim()),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'goal_id': goalId,
        'title': title,
        'minute_of_day': minuteOfDay,
        'days': days,
        'intensity': intensity.index,
        'created_at': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
        'cue': cue,
      };

  factory Task.fromMap(Map<String, Object?> m) => Task(
        id: m['id'] as int,
        goalId: m['goal_id'] as int?,
        title: m['title'] as String,
        minuteOfDay: m['minute_of_day'] as int,
        days: m['days'] as int,
        intensity: Intensity.values[m['intensity'] as int],
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        cue: m['cue'] as String?,
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

/// User preferences, stored as key/value rows in the `settings` table.
class AppSettings {
  const AppSettings({
    this.snoozeMinutes = 5,
    this.volume = 1.0,
    this.vibrate = true,
    this.themeMode = AppThemeMode.system,
    this.setupDone = false,
    this.mood = Mood.steady,
    this.moodDay,
    this.moodCelebratedDay,
    this.alarmFormat = 0,
  });

  final int snoozeMinutes;
  final double volume;
  final bool vibrate;
  final AppThemeMode themeMode;
  final bool setupDone;

  /// Today's mood, recomputed once per day ([moodDay] is its [dayKey]).
  final Mood mood;
  final String? moodDay;

  /// [dayKey] the "you're on fire" moment was last shown, so it shows once.
  final String? moodCelebratedDay;

  /// [AlarmScheduler.format] the pending alarms were last built with.
  final int alarmFormat;

  Duration get snooze => Duration(minutes: snoozeMinutes);

  AppSettings copyWith({
    int? snoozeMinutes,
    double? volume,
    bool? vibrate,
    AppThemeMode? themeMode,
    bool? setupDone,
    Mood? mood,
    String? moodDay,
    String? moodCelebratedDay,
    int? alarmFormat,
  }) =>
      AppSettings(
        snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
        volume: volume ?? this.volume,
        vibrate: vibrate ?? this.vibrate,
        themeMode: themeMode ?? this.themeMode,
        setupDone: setupDone ?? this.setupDone,
        mood: mood ?? this.mood,
        moodDay: moodDay ?? this.moodDay,
        moodCelebratedDay: moodCelebratedDay ?? this.moodCelebratedDay,
        alarmFormat: alarmFormat ?? this.alarmFormat,
      );

  Map<String, String> toRows() => {
        'snooze_minutes': '$snoozeMinutes',
        'volume': '$volume',
        'vibrate': '$vibrate',
        'theme_mode': themeMode.name,
        'setup_done': '$setupDone',
        'mood': mood.name,
        'mood_day': ?moodDay,
        'mood_celebrated_day': ?moodCelebratedDay,
        'alarm_format': '$alarmFormat',
      };

  factory AppSettings.fromRows(Map<String, String> r) => AppSettings(
        snoozeMinutes: int.tryParse(r['snooze_minutes'] ?? '') ?? 5,
        volume: double.tryParse(r['volume'] ?? '') ?? 1.0,
        vibrate: r['vibrate'] != 'false',
        themeMode: AppThemeMode.values.asNameMap()[r['theme_mode']] ?? AppThemeMode.system,
        setupDone: r['setup_done'] == 'true',
        mood: Mood.values.asNameMap()[r['mood']] ?? Mood.steady,
        moodDay: r['mood_day'],
        moodCelebratedDay: r['mood_celebrated_day'],
        alarmFormat: int.tryParse(r['alarm_format'] ?? '') ?? 0,
      );
}

import 'dart:convert';

import 'package:alarm/alarm.dart';

import '../data/models.dart';

/// Which task occurrence a scheduled alarm belongs to, carried in its payload.
class AlarmTarget {
  const AlarmTarget(this.taskId, this.day, this.minuteOfDay);

  final int taskId;
  final String day;
  final int minuteOfDay;

  String get key => '$taskId|$day';

  String encode() => jsonEncode({'taskId': taskId, 'day': day, 'minute': minuteOfDay});

  static AlarmTarget? of(AlarmSettings a) => decode(a.payload);

  static AlarmTarget? decode(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return AlarmTarget(m['taskId'] as int, m['day'] as String, m['minute'] as int);
    } catch (_) {
      return null;
    }
  }
}

/// Keeps one OS alarm per upcoming occurrence of every Alarm-intensity task.
///
/// Occurrences are scheduled [horizonDays] ahead so repeating tasks keep
/// ringing even if the app isn't opened for a few days; every app start and
/// resume tops the window back up.
class AlarmScheduler {
  static const horizonDays = 7;

  /// The "Test alarm" button's alarm; never belongs to a task.
  static const testAlarmId = 1;

  /// Bump when [_settings] changes shape so already-scheduled alarms get re-created once.
  static const format = 2;

  /// Sound fades in instead of starting at full blast (better wake-up mood, same reliability).
  static const fadeIn = Duration(seconds: 10);

  /// Stable id per (task, day). Unique within any 100-day window.
  static int alarmId(int taskId, DateTime day) {
    final n = DateTime.utc(day.year, day.month, day.day).difference(DateTime.utc(2020)).inDays;
    return taskId * 100 + n % 100;
  }

  /// [resolved] holds [AlarmTarget.key]s already answered with Done or Skip.
  ///
  /// [force] re-creates every pending alarm, e.g. after the sound settings change.
  static Future<void> sync({
    required List<Task> tasks,
    required Set<String> resolved,
    required AppSettings settings,
    bool force = false,
  }) async {
    final now = DateTime.now();
    final today = dateOnly(now);
    final byId = {for (final t in tasks) t.id!: t};

    final desired = <int, AlarmSettings>{};
    for (final task in tasks) {
      if (task.intensity != Intensity.alarm) continue;
      for (var k = 0; k < horizonDays; k++) {
        final day = DateTime(today.year, today.month, today.day + k);
        if (!task.occursOn(day)) continue;
        final due = task.dueOn(day);
        if (!due.isAfter(now)) continue;
        final target = AlarmTarget(task.id!, dayKey(day), task.minuteOfDay);
        if (resolved.contains(target.key)) continue;
        desired[alarmId(task.id!, day)] = _settings(alarmId(task.id!, day), task, due, target, settings);
      }
    }

    for (final existing in await Alarm.getAlarms()) {
      if (existing.id == testAlarmId || await Alarm.isRinging(existing.id)) {
        desired.remove(existing.id);
        continue;
      }
      final target = AlarmTarget.of(existing);
      final task = target == null ? null : byId[target.taskId];
      // A pending alarm for an unanswered occurrence whose task is unchanged
      // stays as it is — that's how a snooze survives a sync.
      final snoozed = target != null && task != null &&
          !existing.dateTime.isAtSameMomentAs(task.dueOn(DateTime.parse(target.day)));
      // [force] re-creates alarms at their regular time but never drops a snooze.
      final keep = (!force || snoozed) &&
          target != null &&
          task != null &&
          task.intensity == Intensity.alarm &&
          task.minuteOfDay == target.minuteOfDay &&
          !resolved.contains(target.key) &&
          existing.dateTime.isAfter(now) &&
          existing.notificationSettings.title == task.title &&
          task.occursOn(DateTime.parse(target.day));
      if (keep) {
        desired.remove(existing.id);
      } else {
        await Alarm.stop(existing.id);
      }
    }

    for (final a in desired.values) {
      await Alarm.set(alarmSettings: a);
    }
  }

  static Future<void> setTestAlarm(AppSettings s) => Alarm.set(
        alarmSettings: AlarmSettings(
          id: testAlarmId,
          dateTime: DateTime.now().add(const Duration(seconds: 10)),
          assetAudioPath: 'assets/alarm.wav',
          vibrate: s.vibrate,
          allowSameSecondScheduling: true,
          volumeSettings: VolumeSettings.fixed(volume: s.volume, volumeEnforced: true),
          notificationSettings: const NotificationSettings(
            title: 'Test alarm',
            body: 'If you can hear this, alarms work.',
            stopButton: 'Stop',
          ),
        ),
      );

  static Future<void> snooze(AlarmSettings ringing, Duration by) => Alarm.set(
        alarmSettings: ringing.copyWith(dateTime: DateTime.now().add(by)),
      );

  static AlarmSettings _settings(int id, Task task, DateTime due, AlarmTarget target, AppSettings s) => AlarmSettings(
        id: id,
        dateTime: due,
        assetAudioPath: 'assets/alarm.wav',
        loopAudio: true,
        vibrate: s.vibrate,
        androidFullScreenIntent: true,
        allowSameSecondScheduling: true,
        androidSnoozeDuration: s.snooze,
        volumeSettings: VolumeSettings.fade(fadeDuration: fadeIn, volume: s.volume, volumeEnforced: true),
        notificationSettings: NotificationSettings(
          title: task.title,
          body: 'Tap to open Tally',
          stopButton: 'Stop',
          androidSnoozeButton: 'Snooze',
        ),
        payload: target.encode(),
      );
}

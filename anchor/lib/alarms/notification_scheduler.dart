import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../data/models.dart';
import 'alarm_scheduler.dart';

const _doneAction = 'done';
const _skipAction = 'skip';

/// Runs in a background isolate when Done/Skip is tapped on a notification
/// while the app isn't in the foreground.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationAction(NotificationResponse r) async {
  DartPluginRegistrant.ensureInitialized();
  await NotificationScheduler.logAction(await AnchorDb.open(), r);
}

/// Scheduled notifications for Nudge (silent) and Reminder (sound) tasks, each
/// with Done / Skip buttons. Alarm tasks go through [AlarmScheduler] instead.
class NotificationScheduler {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Keeps notification ids clear of the alarm plugin's ids.
  static const _idOffset = 1000000000;

  static AndroidFlutterLocalNotificationsPlugin? get android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  static Future<void> init({required Future<void> Function() onLogged, required AnchorDb db}) async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (r) async {
        if (await logAction(db, r)) await onLogged();
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationAction,
    );
  }

  /// Writes the log for a Done/Skip tap. Returns whether anything was logged.
  static Future<bool> logAction(AnchorDb db, NotificationResponse r) async {
    final status = switch (r.actionId) {
      _doneAction => LogStatus.done,
      _skipAction => LogStatus.skipped,
      _ => null,
    };
    final target = AlarmTarget.decode(r.payload);
    if (status == null || target == null) return false;
    await db.insertLog(TaskLog(taskId: target.taskId, day: target.day, status: status, at: DateTime.now()));
    return true;
  }

  static Future<void> sync({required List<Task> tasks, required Set<String> resolved}) async {
    final now = DateTime.now();
    final today = dateOnly(now);
    final desired = <int>{};

    for (final task in tasks) {
      if (task.intensity == Intensity.alarm) continue;
      for (var k = 0; k < AlarmScheduler.horizonDays; k++) {
        final day = DateTime(today.year, today.month, today.day + k);
        if (!task.occursOn(day)) continue;
        final due = task.dueOn(day);
        if (!due.isAfter(now)) continue;
        final target = AlarmTarget(task.id!, dayKey(day), task.minuteOfDay);
        if (resolved.contains(target.key)) continue;
        final id = _idOffset + AlarmScheduler.alarmId(task.id!, day);
        desired.add(id);
        await _plugin.zonedSchedule(
          id: id,
          scheduledDate: tz.TZDateTime.from(due.toUtc(), tz.UTC),
          notificationDetails: _details(task.intensity),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          title: task.title,
          body: task.intensity == Intensity.reminder ? 'Reminder · tap Done when finished' : 'Gentle nudge',
          payload: target.encode(),
        );
      }
    }

    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (pending.id >= _idOffset && !desired.contains(pending.id)) {
        await _plugin.cancel(id: pending.id);
      }
    }
  }

  static NotificationDetails _details(Intensity intensity) {
    const actions = [
      AndroidNotificationAction(_doneAction, 'Done'),
      AndroidNotificationAction(_skipAction, 'Skip'),
    ];
    final reminder = intensity == Intensity.reminder;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        reminder ? 'anchor_reminders' : 'anchor_nudges',
        reminder ? 'Reminders' : 'Nudges',
        channelDescription: reminder ? 'Task reminders with sound' : 'Quiet task nudges',
        importance: reminder ? Importance.high : Importance.low,
        priority: reminder ? Priority.high : Priority.low,
        playSound: reminder,
        enableVibration: reminder,
        category: AndroidNotificationCategory.reminder,
        actions: actions,
      ),
    );
  }

  static Future<bool> notificationsEnabled() async => await android?.areNotificationsEnabled() ?? false;

  static Future<bool> canScheduleExact() async => await android?.canScheduleExactNotifications() ?? false;

  static Future<bool> requestFullScreen() async {
    try {
      return await android?.requestFullScreenIntentPermission() ?? false;
    } catch (e) {
      debugPrint('Full-screen permission request failed: $e');
      return false;
    }
  }
}

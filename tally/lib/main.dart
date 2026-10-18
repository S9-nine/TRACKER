import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';

import 'alarms/alarm_scheduler.dart';
import 'alarms/notification_scheduler.dart';
import 'data/database.dart';
import 'data/models.dart';
import 'data/store.dart';
import 'screens/home_shell.dart';
import 'screens/ring_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/tally_theme.dart';

late final TallyStore store;
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  final db = await TallyDb.open();
  store = TallyStore(db);
  await NotificationScheduler.init(db: db, onLogged: store.refresh);
  await store.load();
  runApp(const TallyApp());
  unawaited(store.refresh());
}

class TallyApp extends StatefulWidget {
  const TallyApp({super.key});

  @override
  State<TallyApp> createState() => _TallyAppState();
}

class _TallyAppState extends State<TallyApp> {
  StreamSubscription<AlarmSet>? _ringing;
  StreamSubscription<AlarmEvent>? _events;
  late final AppLifecycleListener _lifecycle;
  final _showing = <int>{};

  @override
  void initState() {
    super.initState();
    _ringing = Alarm.ringing.listen(_onRinging);
    _events = Alarm.events.listen(_onAlarmEvent);
    _lifecycle = AppLifecycleListener(onResume: store.refresh);
  }

  @override
  void dispose() {
    _ringing?.cancel();
    _events?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  /// Snooze tapped on the alarm notification (no app UI involved) — log it.
  Future<void> _onAlarmEvent(AlarmEvent event) async {
    if (event is! AlarmMoved || event.cause != AlarmEventCause.snooze) return;
    final alarm = await Alarm.getAlarm(event.id);
    final target = alarm == null ? null : AlarmTarget.of(alarm);
    if (target != null) await store.log(target.taskId, target.day, LogStatus.snoozed);
  }

  Future<void> _onRinging(AlarmSet set) async {
    for (final alarm in set.alarms) {
      if (_showing.contains(alarm.id)) continue;
      final nav = navigatorKey.currentState;
      if (nav == null) return;
      _showing.add(alarm.id);
      await nav.push(MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => RingScreen(alarm: alarm),
      ));
      _showing.remove(alarm.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'Tally',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: tallyTheme(Brightness.light, store.mood),
        darkTheme: tallyTheme(Brightness.dark, store.mood),
        themeAnimationDuration: const Duration(milliseconds: 600),
        themeMode: switch (store.settings.themeMode) {
          AppThemeMode.system => ThemeMode.system,
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.dark => ThemeMode.dark,
        },
        home: store.settings.setupDone ? const HomeShell() : const SetupScreen(firstRun: true),
      ),
    );
  }
}

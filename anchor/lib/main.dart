import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'data/database.dart';
import 'data/store.dart';
import 'screens/home_shell.dart';
import 'screens/ring_screen.dart';
import 'theme/anchor_theme.dart';

late final AnchorStore store;
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  store = AnchorStore(await AnchorDb.open());
  await store.load();
  runApp(const AnchorApp());
  unawaited(store.refresh());
}

class AnchorApp extends StatefulWidget {
  const AnchorApp({super.key});

  @override
  State<AnchorApp> createState() => _AnchorAppState();
}

class _AnchorAppState extends State<AnchorApp> {
  StreamSubscription<AlarmSet>? _ringing;
  late final AppLifecycleListener _lifecycle;
  final _showing = <int>{};

  @override
  void initState() {
    super.initState();
    _ringing = Alarm.ringing.listen(_onRinging);
    _lifecycle = AppLifecycleListener(onResume: store.refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPermissions());
  }

  @override
  void dispose() {
    _ringing?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
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
    return MaterialApp(
      title: 'Anchor',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: anchorTheme(Brightness.light),
      darkTheme: anchorTheme(Brightness.dark),
      home: const HomeShell(),
    );
  }
}

import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ring_screen.dart';

const _testAlarmId = 42;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(const AlarmTestApp());
}

class AlarmTestApp extends StatelessWidget {
  const AlarmTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anchor Alarm Test',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<AlarmSet>? _ringingSubscription;
  DateTime? _scheduledFor;
  String _status = 'No alarm scheduled';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _ringingSubscription = Alarm.ringing.listen(_onRingingChanged);
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  Future<void> _offerAutoStart() async {
    final available = await isAutoStartAvailable;
    if (available != true) return;
    if (!mounted) return;
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allow auto-start?'),
        content: const Text(
          'This device restricts background apps by default. To make sure '
          'the alarm still rings after the app is closed or the phone '
          'restarts, allow auto-start / remove battery optimization for '
          'this app in the settings screen that opens next.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (shouldOpen == true) {
      await getAutoStartPermission();
    }
  }

  Future<void> _onRingingChanged(AlarmSet alarms) async {
    if (alarms.alarms.isEmpty) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RingScreen(alarmSettings: alarms.alarms.first),
      ),
    );
    setState(() {
      _scheduledFor = null;
      _status = 'No alarm scheduled';
    });
  }

  Future<void> _scheduleTestAlarm(Duration delay) async {
    final dateTime = DateTime.now().add(delay);
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: _testAlarmId,
        dateTime: dateTime,
        assetAudioPath: 'assets/alarm.wav',
        loopAudio: true,
        vibrate: true,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fixed(volume: 1.0, volumeEnforced: true),
        notificationSettings: const NotificationSettings(
          title: 'Anchor test alarm',
          body: 'Tap to open the ring screen',
          stopButton: 'Stop',
        ),
      ),
    );
    setState(() {
      _scheduledFor = dateTime;
      _status = 'Scheduled for ${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}:'
          '${dateTime.second.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _cancelTestAlarm() async {
    await Alarm.stop(_testAlarmId);
    setState(() {
      _scheduledFor = null;
      _status = 'No alarm scheduled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anchor — Alarm Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 32),
              const Text(
                'Schedule, then close the app, lock the phone, and '
                'put it on silent. It should still ring full-screen.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => _scheduleTestAlarm(const Duration(seconds: 15)),
                child: const Text('Ring in 15 seconds'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _scheduleTestAlarm(const Duration(minutes: 5)),
                child: const Text('Ring in 5 minutes (for reboot test)'),
              ),
              const SizedBox(height: 12),
              if (_scheduledFor != null)
                TextButton(
                  onPressed: _cancelTestAlarm,
                  child: const Text('Cancel scheduled alarm'),
                ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _offerAutoStart,
                child: const Text('Check auto-start / battery settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

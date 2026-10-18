import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../alarms/alarm_scheduler.dart';
import '../alarms/notification_scheduler.dart';
import '../main.dart';
import '../theme/anchor_colors.dart';

/// The permissions alarms depend on. Without the first two nothing rings at all.
class PermissionHealth {
  static Future<bool> essentialsOk() async =>
      await Permission.notification.isGranted && await Permission.scheduleExactAlarm.isGranted;
}

/// Walks through every setting Anchor needs to ring reliably. Shown on first
/// run, and reachable later from Today's banner and from Settings.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, this.firstRun = false});

  final bool firstRun;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final AppLifecycleListener _lifecycle;
  bool _notifications = false;
  bool _exact = false;
  bool _battery = false;
  bool _fullScreen = false;
  bool _autoStartAvailable = false;
  bool _autoStartOpened = false;
  bool _testSent = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    _check();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final notifications = await Permission.notification.isGranted;
    final exact = await Permission.scheduleExactAlarm.isGranted;
    final battery = await Permission.ignoreBatteryOptimizations.isGranted;
    final autoStart = await isAutoStartAvailable == true;
    if (!mounted) return;
    setState(() {
      _notifications = notifications;
      _exact = exact;
      _battery = battery;
      _autoStartAvailable = autoStart;
    });
  }

  Future<void> _request(Permission p) async {
    final status = await p.request();
    if (status.isPermanentlyDenied) await openAppSettings();
    await _check();
  }

  Future<void> _fixFullScreen() async {
    final granted = await NotificationScheduler.requestFullScreen();
    if (mounted) setState(() => _fullScreen = granted);
  }

  Future<void> _openAutoStart() async {
    await getAutoStartPermission();
    if (mounted) setState(() => _autoStartOpened = true);
  }

  Future<void> _test() async {
    await AlarmScheduler.setTestAlarm(store.settings);
    if (mounted) setState(() => _testSent = true);
  }

  Future<void> _finish() async {
    if (widget.firstRun) {
      await store.saveSettings(store.settings.copyWith(setupDone: true));
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: widget.firstRun ? null : AppBar(title: const Text('Alarm setup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            if (widget.firstRun) ...[
              Text('Welcome to Anchor', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
            ],
            Text(
              'Anchor rings like a real alarm clock. Android needs a few permissions for that — '
              'tap each one that isn\'t ticked yet.',
              style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 24),
            _Row(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              body: 'Needed for alarms and reminders to appear.',
              ok: _notifications,
              onFix: () => _request(Permission.notification),
            ),
            _Row(
              icon: Icons.alarm_on_outlined,
              title: 'Exact alarms',
              body: 'Rings at the exact minute instead of "around then".',
              ok: _exact,
              onFix: () => _request(Permission.scheduleExactAlarm),
            ),
            _Row(
              icon: Icons.fullscreen,
              title: 'Full-screen alarms',
              body: 'Shows the ring screen over the lock screen.',
              ok: _fullScreen,
              fixLabel: 'Check',
              onFix: _fixFullScreen,
            ),
            _Row(
              icon: Icons.battery_charging_full_outlined,
              title: 'Unrestricted battery',
              body: 'Stops Android from putting Anchor to sleep.',
              ok: _battery,
              onFix: () => _request(Permission.ignoreBatteryOptimizations),
            ),
            if (_autoStartAvailable)
              _Row(
                icon: Icons.restart_alt,
                title: 'Auto-start',
                body: 'Your phone needs this so alarms survive a restart. Turn Anchor on in the screen that opens.',
                ok: _autoStartOpened,
                fixLabel: 'Open',
                onFix: _openAutoStart,
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _test,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text(_testSent ? 'Test alarm rings in 10 s — lock your phone' : 'Test alarm (rings in 10 s)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _finish,
              child: Text(widget.firstRun ? (_notifications && _exact ? 'Get started' : 'Skip for now') : 'Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.body,
    required this.ok,
    required this.onFix,
    this.fixLabel = 'Allow',
  });

  final IconData icon;
  final String title;
  final String body;
  final bool ok;
  final VoidCallback onFix;
  final String fixLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Icon(icon, color: c.textMuted),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(body, style: TextStyle(color: c.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ok
                  ? Icon(Icons.check_circle, color: c.done)
                  : TextButton(onPressed: onFix, child: Text(fixLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

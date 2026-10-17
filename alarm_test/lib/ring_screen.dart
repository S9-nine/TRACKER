import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';

class RingScreen extends StatefulWidget {
  const RingScreen({required this.alarmSettings, super.key});

  final AlarmSettings alarmSettings;

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> {
  StreamSubscription<AlarmSet>? _ringingSubscription;
  String? _lastAction;

  @override
  void initState() {
    super.initState();
    // The OS/plugin can stop the alarm out from under us (e.g. snooze
    // elapsed, or Alarm.stopAll called elsewhere) — leave the ring screen
    // when that happens instead of showing a stale "still ringing" UI.
    _ringingSubscription = Alarm.ringing.listen((alarms) {
      if (alarms.containsId(widget.alarmSettings.id)) return;
      _ringingSubscription?.cancel();
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _done() async {
    setState(() => _lastAction = 'Done');
    await Alarm.stop(widget.alarmSettings.id);
  }

  Future<void> _snooze() async {
    setState(() => _lastAction = 'Snoozed 1 min');
    await Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        dateTime: DateTime.now().add(const Duration(minutes: 1)),
      ),
    );
  }

  Future<void> _skip() async {
    setState(() => _lastAction = 'Skipped');
    await Alarm.stop(widget.alarmSettings.id);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox.shrink(),
              const Text(
                'ANCHOR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const Text(
                '⏰',
                style: TextStyle(fontSize: 80),
              ),
              Text(
                'Alarm #${widget.alarmSettings.id} is ringing',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              if (_lastAction != null)
                Text(
                  'Last action: $_lastAction',
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _RingButton(
                      label: 'Done',
                      color: Colors.green,
                      onPressed: _done,
                    ),
                    const SizedBox(height: 16),
                    _RingButton(
                      label: 'Snooze (1 min)',
                      color: Colors.orange,
                      onPressed: _snooze,
                    ),
                    const SizedBox(height: 16),
                    _RingButton(
                      label: 'Skip',
                      color: Colors.grey,
                      onPressed: _skip,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingButton extends StatelessWidget {
  const _RingButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

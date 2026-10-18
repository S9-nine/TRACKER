import 'package:flutter/material.dart';

import '../alarms/alarm_scheduler.dart';
import '../data/models.dart';
import '../main.dart';
import '../theme/tally_colors.dart';
import 'setup_screen.dart';
import 'widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Volume while the slider is being dragged; saved (and alarms re-created) on release.
  double? _dragVolume;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final s = store.settings;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const SectionLabel('Alarms'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Snooze length', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<int>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(value: 5, label: Text('5 min')),
                            ButtonSegment(value: 10, label: Text('10 min')),
                            ButtonSegment(value: 15, label: Text('15 min')),
                          ],
                          selected: {s.snoozeMinutes},
                          onSelectionChanged: (v) => store.saveSettings(s.copyWith(snoozeMinutes: v.first)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('Volume', style: TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('${((_dragVolume ?? s.volume) * 100).round()}%',
                              style: TextStyle(color: c.textMuted)),
                        ],
                      ),
                      Slider(
                        value: _dragVolume ?? s.volume,
                        min: 0.3,
                        max: 1.0,
                        divisions: 7,
                        onChanged: (v) => setState(() => _dragVolume = v),
                        onChangeEnd: (v) async {
                          await store.saveSettings(s.copyWith(volume: v));
                          if (mounted) setState(() => _dragVolume = null);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Vibrate', style: TextStyle(fontWeight: FontWeight.w600)),
                        value: s.vibrate,
                        onChanged: (v) => store.saveSettings(s.copyWith(vibrate: v)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.play_arrow_outlined),
                      title: const Text('Test alarm'),
                      subtitle: const Text('Rings in 10 seconds'),
                      onTap: () async {
                        await AlarmScheduler.setTestAlarm(s);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Test alarm set — lock your phone and wait 10 s.')),
                          );
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: const Text('Alarm setup'),
                      subtitle: const Text('Permissions, battery and auto-start'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute<void>(builder: (_) => const SetupScreen())),
                    ),
                  ],
                ),
              ),
              const SectionLabel('Appearance'),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AppThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: AppThemeMode.system, label: Text('System')),
                    ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) => store.saveSettings(s.copyWith(themeMode: v.first)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tally_colors.dart';
import 'goals_screen.dart';
import 'insights_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with SingleTickerProviderStateMixin {
  static const _pages = [TodayScreen(), InsightsScreen(), GoalsScreen()];

  int _index = 0;
  int _previous = 0;

  /// Fade-through: the old tab fades out completely before the new one fades in,
  /// so two pages are never visible on top of each other.
  late final AnimationController _switch =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300), value: 1)
        ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _switch.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    _previous = _index;
    _index = i;
    _switch.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = _switch.value;
    final outgoing = 1 - const Interval(0, 0.35, curve: Curves.easeIn).transform(t);
    final incoming = const Interval(0.35, 1, curve: Curves.easeOut).transform(t);
    final background = context.colors.background;

    return Scaffold(
      body: Stack(
        children: [
          for (var i = 0; i < _pages.length; i++)
            Offstage(
              // Keep every tab alive (state, scroll position) but only paint the ones involved.
              offstage: !(i == _index || (i == _previous && t < 0.35)),
              child: TickerMode(
                enabled: i == _index,
                child: IgnorePointer(
                  ignoring: i != _index,
                  child: Opacity(
                    opacity: i == _index ? incoming : outgoing,
                    child: Transform.translate(
                      offset: Offset(0, i == _index ? 10 * (1 - incoming) : 0),
                      child: ColoredBox(color: background, child: _pages[i]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        child: NavigationBar(
          selectedIndex: _index,
          animationDuration: const Duration(milliseconds: 400),
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Today'),
            NavigationDestination(
                icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
            NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Goals'),
          ],
        ),
      ),
    );
  }
}

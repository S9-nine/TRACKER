import 'package:flutter/material.dart';

import 'widgets.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('Insights', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          const EmptyState(
            icon: Icons.insights_outlined,
            title: 'Coming soon',
            body: 'Streaks and weekly trends will show up here once you have a few days of history.',
          ),
        ],
      ),
    );
  }
}

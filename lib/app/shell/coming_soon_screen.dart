import 'package:flutter/material.dart';

import '../../core/widgets/state_views.dart';

/// Stand-in for a screen that is built in a later step.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.construction_rounded,
      title: title,
      message: 'This screen is built in a later step.',
    );
  }
}

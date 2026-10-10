import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Frame for screens opened on top of the main shell (forms, details):
/// a back arrow that returns to the previous screen, or to [fallbackRoute] when there is none.
class SubPage extends StatelessWidget {
  const SubPage({
    super.key,
    required this.title,
    required this.fallbackRoute,
    required this.body,
    this.actions = const [],
    this.maxWidth = 560,
  });

  final String title;
  final String fallbackRoute;
  final Widget body;
  final List<Widget> actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go(fallbackRoute),
        ),
        actions: actions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: body),
        ),
      ),
    );
  }
}

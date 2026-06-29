import 'package:flutter/material.dart';

class HalfScreenPage extends StatefulWidget {
  final Widget child;
  const HalfScreenPage({super.key, required this.child});

  @override
  State<HalfScreenPage> createState() => _HalfScreenPageState();
}

class _HalfScreenPageState extends State<HalfScreenPage> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.8,
      builder: (_, controller) => widget.child,
    );
  }
}

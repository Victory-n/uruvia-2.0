import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/application/bootstrap.dart';
import '../application/app_lock.dart';
import 'lock_screen.dart';

/// Wraps the whole app: watches taps and app-lifecycle, and covers everything with
/// the lock screen when the app is locked (3 minutes idle or in the background).
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (ref.read(appStageProvider) == AppStage.ready) {
        ref.read(appLockProvider.notifier).checkIdle();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Android back button: while the lock screen is showing, swallow it so the
  /// app underneath cannot be navigated. Our observer registers before the
  /// router's, so this runs first.
  @override
  Future<bool> didPopRoute() async {
    final locked = ref.read(appLockProvider) && ref.read(appStageProvider) == AppStage.ready;
    return locked;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    if (state == AppLifecycleState.paused) lock.onPaused();
    if (state == AppLifecycleState.resumed) lock.onResumed();
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    final ready = ref.watch(appStageProvider) == AppStage.ready;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(appLockProvider.notifier).touch(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (locked && ready) const Positioned.fill(child: LockScreen()),
        ],
      ),
    );
  }
}

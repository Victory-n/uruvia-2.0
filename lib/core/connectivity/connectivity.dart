import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true when the phone has a network connection (Wi-Fi, mobile data, ethernet).
/// It cannot tell a connection that is up but has no internet; requests still
/// fail with a friendly "No internet connection" message in that case.
bool isOnlineFrom(List<ConnectivityResult> results) =>
    results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);

final onlineProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  yield isOnlineFrom(await c.checkConnectivity());
  yield* c.onConnectivityChanged.map(isOnlineFrom);
});

/// Convenience: treats "not known yet" as online so the banner does not flash at start-up.
final isOnlineProvider = Provider<bool>((ref) => ref.watch(onlineProvider).valueOrNull ?? true);

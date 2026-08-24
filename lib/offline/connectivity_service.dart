import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:uruvia/offline/sync_service.dart';

class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;
  ConnectivityService._internal();

  // Expose the current status as a ValueNotifier
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);
  StreamSubscription<InternetConnectionStatus>? _subscription;

  // Initialize the stream listener
  void initialize() {
    _subscription?.cancel();

    // Check initial connection status
    InternetConnectionChecker.instance.hasConnection.then((hasConnection) {
      final wasOffline = !isConnected.value;
      isConnected.value = hasConnection;

      // If we re-established connection, trigger synchronization
      if (hasConnection && wasOffline) {
        SyncService.instance.processQueue();
      }
    });

    // Listen for periodic updates
    _subscription = InternetConnectionChecker.instance.onStatusChange.listen((
      InternetConnectionStatus status,
    ) {
      final wasOffline = !isConnected.value;
      switch (status) {
        case InternetConnectionStatus.connected:
        case InternetConnectionStatus.slow:
          isConnected.value = true;
          if (wasOffline) {
            SyncService.instance.processQueue();
          }
          break;
        case InternetConnectionStatus.disconnected:
          isConnected.value = false;
          break;
      }
    });
  }

  // Force a manual check if needed
  Future<bool> checkConnection() async {
    final wasOffline = !isConnected.value;
    final hasConnection =
        await InternetConnectionChecker.instance.hasConnection;
    isConnected.value = hasConnection;
    if (hasConnection && wasOffline) {
      SyncService.instance.processQueue();
    }
    return hasConnection;
  }

  // Clean up subscription if service is disposed
  void dispose() {
    _subscription?.cancel();
  }
}

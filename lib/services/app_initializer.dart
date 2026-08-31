import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';
import '../offline/connectivity_service.dart';
import '../offline/database_helper.dart';
import '../offline/sync_service.dart';
import 'currency_service.dart';
import 'notification_service.dart';

/// Defines the outcome of session and data bootstrapping.
enum InitResult {
  authenticated,
  unauthenticated,
  error,
}

/// Enterprise App Initialization Bootstrapper.
/// Manages Core System setup (Phase 1) and User Data/Session Warmup (Phase 2).
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  static AppInitializer get instance => _instance;
  AppInitializer._internal();

  bool _isCoreInitialized = false;

  /// Phase 1: Core System Initialization.
  /// Executed in main() while holding the Native Splash Screen.
  Future<void> initializeCore() async {
    if (_isCoreInitialized) return;

    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    
    // Preserve Native Splash Screen until Flutter Splash takes over
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    try {
      // 1. Backend Engine (Supabase SDK)
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );

      // 2. Offline SQLite Local Database Warmup
      await DatabaseHelper.instance.database;

      // 3. Connectivity Service
      ConnectivityService.instance.initialize();

      // 4. Notification Service
      await NotificationService.instance.initialize();

      _isCoreInitialized = true;
      if (kDebugMode) {
        print('[AppInitializer] Core services successfully initialized.');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('[AppInitializer] Core initialization error: $e\n$stack');
      }
    }
  }

  /// Phase 2: User Session & Data Bootstrapping.
  /// Runs during the in-app Flutter Splash transition with progress feedback.
  Future<InitResult> bootstrapSessionAndData({
    required Function(String statusMessage) onProgress,
  }) async {
    try {
      onProgress('Verifying security session...');
      await Future.delayed(const Duration(milliseconds: 300));

      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;

      if (session == null || user == null) {
        onProgress('No active session found.');
        return InitResult.unauthenticated;
      }

      // Check token expiration and refresh if necessary
      if (session.isExpired) {
        onProgress('Refreshing authentication token...');
        try {
          await Supabase.instance.client.auth.refreshSession();
        } catch (_) {
          return InitResult.unauthenticated;
        }
      }

      onProgress('Checking network connection...');
      final isOnline = ConnectivityService.instance.isOnline;

      if (isOnline) {
        onProgress('Synchronizing offline records...');
        try {
          await SyncService.instance.processQueue();
        } catch (e) {
          if (kDebugMode) {
            print('[AppInitializer] Sync non-fatal error: $e');
          }
        }
      } else {
        onProgress('Offline mode active. Loading cached data...');
      }

      onProgress('Preparing dashboard...');
      await CurrencyService.instance.init();
      await Future.delayed(const Duration(milliseconds: 400));

      return InitResult.authenticated;
    } catch (e, stack) {
      if (kDebugMode) {
        print('[AppInitializer] Bootstrapping failed: $e\n$stack');
      }
      return InitResult.error;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Metadata definition for supported currencies.
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

/// Reactive Currency Management Engine.
/// Handles active currency state, symbol lookups, historical transaction stamping, and formatting.
class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  static CurrencyService get instance => _instance;
  CurrencyService._internal();

  /// 8 Globally supported currencies in Uruvia
  static const Map<String, CurrencyInfo> supportedCurrencies = {
    'NGN': CurrencyInfo(code: 'NGN', name: 'Nigerian Naira', symbol: '₦'),
    'USD': CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$'),
    'AUD': CurrencyInfo(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    'GBP': CurrencyInfo(code: 'GBP', name: 'British Pound', symbol: '£'),
    'EUR': CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€'),
    'CAD': CurrencyInfo(code: 'CAD', name: 'Canadian Dollar', symbol: 'CA\$'),
    'GHS': CurrencyInfo(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵'),
    'KES': CurrencyInfo(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh'),
  };

  /// Reactive notifier for the user's currently active currency
  final ValueNotifier<String> activeCurrencyNotifier = ValueNotifier<String>('NGN');

  /// Convenience getter for active currency code
  String get activeCurrency => activeCurrencyNotifier.value;

  /// Convenience getter for active currency symbol
  String get activeSymbol => getSymbol(activeCurrency);

  /// Initializes currency state from Supabase Auth session or local SQLite cache
  Future<void> init() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final metaCurrency = user.userMetadata?['currency'] as String?;
        if (metaCurrency != null && supportedCurrencies.containsKey(metaCurrency)) {
          activeCurrencyNotifier.value = metaCurrency;
          return;
        }

        final profile = await AuthService.instance.getUserProfile(user.id);
        if (profile != null && supportedCurrencies.containsKey(profile.currency)) {
          activeCurrencyNotifier.value = profile.currency;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CurrencyService] Initialization note: $e');
      }
    }
  }

  /// Changes the active currency and persists it to backend & local SQLite cache
  Future<void> setCurrency(String newCurrency, {bool syncBackend = true}) async {
    final cleanCode = newCurrency.trim().toUpperCase();
    if (!supportedCurrencies.containsKey(cleanCode)) return;

    // 1. Reactive immediate UI update (60/120 FPS)
    activeCurrencyNotifier.value = cleanCode;

    if (!syncBackend) return;

    // 2. Persist to Supabase Auth metadata & profiles table
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'currency': cleanCode,
            },
          ),
        ).timeout(const Duration(seconds: 4));

        await Supabase.instance.client.from('profiles').update({
          'currency': cleanCode,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id).timeout(const Duration(seconds: 4));

        final profile = await AuthService.instance.getUserProfile(user.id);
        if (profile != null) {
          await AuthService.instance.cacheUserProfileLocally(
            profile.copyWith(currency: cleanCode),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CurrencyService] Backend sync note: $e');
      }
    }
  }

  /// Returns the currency symbol for a given currency code (or fallback)
  static String getSymbol(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) return '₦';
    final code = currencyCode.trim().toUpperCase();
    return supportedCurrencies[code]?.symbol ?? code;
  }

  /// Formats any amount with specified (or active) currency symbol and commas.
  /// Example: format(250000) -> "₦250,000.00" or format(250000, currency: 'AUD') -> "A$250,000.00"
  static String format(
    num amount, {
    String? currency,
    int decimalDigits = 2,
    bool showSign = false,
  }) {
    final selectedCurrency = currency ?? CurrencyService.instance.activeCurrency;
    final symbol = getSymbol(selectedCurrency);

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );

    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = formatter.format(absAmount);

    if (showSign) {
      if (isNegative) return '-$formatted';
      return '+$formatted';
    }

    return isNegative ? '-$formatted' : formatted;
  }

  /// Formats an amount with compact notation (e.g. ₦180k, A$500k, $1.2M)
  static String formatCompact(num amount, {String? currency}) {
    final selectedCurrency = currency ?? CurrencyService.instance.activeCurrency;
    final symbol = getSymbol(selectedCurrency);

    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

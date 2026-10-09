import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
}

/// Global Supabase client. Use it only inside repositories
/// (`features/<name>/data/`), never directly in widgets.
SupabaseClient get supabase => Supabase.instance.client;

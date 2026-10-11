/// Build-time configuration. Override with
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`
/// (for example to point a build at a staging project).
///
/// The publishable key is safe to ship in the app: it is protected by
/// Row Level Security. Never put a service-role / secret key here.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mvisrdmdxbenuqezprdn.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_5n0XY_6HBYN-xQwp5XV7eg_o7RqUQVp',
  );

  /// The "Web application" OAuth client ID from Google Cloud (not the Android one).
  /// Pass it with `--dart-define=GOOGLE_WEB_CLIENT_ID=...`. Google sign-in stays off until it is set.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
}

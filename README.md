# Uruvia

Money management for individuals and small businesses. Flutter and Supabase.

- Architecture and folder rules: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Database: `schema.sql` (to be replaced by migrations under `supabase/`)

## Run

```
flutter pub get
flutter run
```

Point a build at another Supabase project with
`--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`.

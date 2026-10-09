# Uruvia architecture

Feature-first Flutter app on Supabase. State: Riverpod. Routing: go_router.

```
lib/
  main.dart                 start-up only: init Supabase, run the app
  app/
    app.dart                MaterialApp.router, picks the theme from the active account
    router/                 routes.dart (all paths) and app_router.dart (redirects: session, KYC, app lock)
    theme/                  AppPalette (Individual and Business colours) and buildTheme()
  core/
    config/                 Env: Supabase URL and publishable key (override with --dart-define)
    services/               Supabase client, later: secure storage, biometrics, notifications
    utils/                  money (integer kobo), dates, validators
    widgets/                shared components: buttons, fields, keypad, bottom sheets, status tags
    errors/ constants/
  features/<name>/
    data/                   repositories and Supabase calls (only place that touches the database)
    domain/                 models and rules (plain Dart, no Flutter)
    presentation/           screens, widgets and Riverpod controllers for that feature
```

Features: auth, onboarding, kyc, home, notifications, account (type and switcher),
settings, support, subscription, wallet, savings, budget, expenses, and the Business-only
inventory, invoices, customers, sales, reports, hub, health (Business Health and loans), alerts.

## Rules

1. Widgets never call Supabase directly. They use a controller, which uses a repository.
2. A feature may import `core/` and `app/theme`, but not another feature's `data/`.
   Shared models go in the feature that owns them and are imported from its `domain/`.
3. Money is an integer number of kobo everywhere. Format only at the edge with `formatNaira`.
4. All colours come from `AppPalette` or `StatusColors`. No hex values in screens.
5. Business-only features are hidden and blocked (in the router and by RLS) for Individual accounts.
6. Never put a service-role key in the app. Security lives in Row Level Security.

## Naming

Files are `snake_case`. Screens end in `_screen.dart`, repositories in `_repository.dart`,
controllers in `_controller.dart`. Route paths live in `AppRoutes`.

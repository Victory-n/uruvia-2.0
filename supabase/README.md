# Supabase

Hosted project ref: `mvisrdmdxbenuqezprdn`. Migrations in `migrations/` are the single source of truth.

## One-time setup (on your computer)

```bash
npm i -g supabase            # or: brew install supabase/tap/supabase
supabase login               # opens the browser
supabase link --project-ref mvisrdmdxbenuqezprdn   # asks for the database password
```

## Apply migrations to the hosted project

```bash
supabase db push             # shows what will run, asks to confirm
supabase db advisors         # security and performance warnings; fix any that appear
```

## Rules
- Create new migrations with `supabase migration new <name>`. Never hand-name a file.
- Never edit a migration that has already been pushed; add a new one.
- The service-role key never goes in the app.
- Wallet and payment-partner migrations are on hold (see `docs/SUPABASE_PLAN.md`).

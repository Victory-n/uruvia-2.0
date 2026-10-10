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

## No Node.js on your computer? Two options

**A. Install the CLI (recommended, 5 minutes).** In PowerShell:
```powershell
winget install OpenJS.NodeJS.LTS      # then close and reopen PowerShell
npx supabase login
npx supabase link --project-ref mvisrdmdxbenuqezprdn
npx supabase db push
```
`npx supabase ...` works without a global install.

**B. Paste into the dashboard (no installs).** Open the project, go to SQL Editor, paste the whole of
`supabase/manual/apply_all.sql`, click Run. Run it once, on an empty project.
Later, to switch to the CLI, mark these as already applied so `db push` does not run them again:
```powershell
npx supabase migration repair --status applied 20261009181228 20261009181230 20261009181232 20261010003954 20261010003956 20261010003958 20261010004000
```

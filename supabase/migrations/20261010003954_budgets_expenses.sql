-- Uruvia 0004: expense categories, budgets, expenses. Available to both account types.
-- Wallet link is on hold: expenses.wallet_transaction_id is a plain nullable uuid for now.

create type public.budget_period as enum ('monthly', 'yearly');
create type public.expense_source as enum ('wallet', 'manual', 'voice');

create table public.expense_categories (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 60),
  icon text not null default 'category',
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  unique (id, account_id)
);
create unique index expense_categories_name_uq on public.expense_categories (account_id, lower(name));

create table public.budgets (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  category_id uuid not null,
  amount_kobo bigint not null check (amount_kobo > 0),
  period public.budget_period not null default 'monthly',
  starts_on date not null,
  repeat boolean not null default true,
  rollover boolean not null default false,
  alert_80 boolean not null default true,
  alert_100 boolean not null default true,
  paused boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (category_id, account_id) references public.expense_categories (id, account_id) on delete restrict,
  unique (account_id, category_id, period, starts_on)
);
create index budgets_category_idx on public.budgets (category_id, account_id);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  amount_kobo bigint not null check (amount_kobo > 0),
  category_id uuid,
  spent_at timestamptz not null default now(),
  source public.expense_source not null default 'manual',
  -- becomes a foreign key to the ledger when the wallet migration is written
  wallet_transaction_id uuid,
  note text,
  receipt_path text,
  created_by uuid not null default auth.uid() references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (category_id, account_id) references public.expense_categories (id, account_id) on delete set null (category_id)
);
create index expenses_account_spent_idx on public.expenses (account_id, spent_at desc);
create index expenses_category_idx on public.expenses (category_id, account_id);

create trigger budgets_set_updated_at before update on public.budgets
  for each row execute function private.set_updated_at();
create trigger expenses_set_updated_at before update on public.expenses
  for each row execute function private.set_updated_at();

-- Starter categories for every new account (design templates).
create or replace function private.seed_expense_categories()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.type = 'individual' then
    insert into public.expense_categories (account_id, name, icon) values
      (new.id, 'Feeding', 'restaurant'), (new.id, 'Transport', 'directions_bus'),
      (new.id, 'Emergency fund', 'shield'), (new.id, 'Rent', 'home'),
      (new.id, 'Airtime and data', 'phone_android'), (new.id, 'School fees', 'school');
  else
    insert into public.expense_categories (account_id, name, icon) values
      (new.id, 'Stock purchases', 'inventory'), (new.id, 'Salaries', 'groups'),
      (new.id, 'Rent', 'home'), (new.id, 'Transport', 'local_shipping'),
      (new.id, 'Utilities', 'bolt'), (new.id, 'Marketing', 'campaign');
  end if;
  return new;
end;
$$;

create trigger on_account_seed_categories
  after insert on public.accounts
  for each row execute function private.seed_expense_categories();

-- Progress for each budget in its current period. Runs with the caller's rights, so RLS still applies.
create view public.budget_progress with (security_invoker = true) as
select
  b.id as budget_id,
  b.account_id,
  b.category_id,
  b.amount_kobo,
  b.period,
  b.starts_on,
  (case b.period when 'monthly' then b.starts_on + interval '1 month'
                 else b.starts_on + interval '1 year' end)::date as ends_on,
  coalesce(s.spent_kobo, 0) as spent_kobo,
  b.amount_kobo - coalesce(s.spent_kobo, 0) as remaining_kobo,
  case
    when coalesce(s.spent_kobo, 0) * 100 > b.amount_kobo * 100 then 'red'
    when coalesce(s.spent_kobo, 0) * 100 >= b.amount_kobo * 80 then 'amber'
    else 'green'
  end as state
from public.budgets b
left join lateral (
  select sum(e.amount_kobo)::bigint as spent_kobo
  from public.expenses e
  where e.account_id = b.account_id
    and e.category_id = b.category_id
    and e.spent_at >= b.starts_on
    and e.spent_at < (case b.period when 'monthly' then b.starts_on + interval '1 month'
                                    else b.starts_on + interval '1 year' end)
) s on true;

-- ---------------------------------------------------------------- RLS

alter table public.expense_categories enable row level security;
alter table public.budgets enable row level security;
alter table public.expenses enable row level security;

create policy expense_categories_all on public.expense_categories for all to authenticated
  using (private.is_account_member(account_id)) with check (private.is_account_member(account_id));
create policy budgets_all on public.budgets for all to authenticated
  using (private.is_account_member(account_id)) with check (private.is_account_member(account_id));
create policy expenses_all on public.expenses for all to authenticated
  using (private.is_account_member(account_id)) with check (private.is_account_member(account_id));

revoke all on public.expense_categories, public.budgets, public.expenses from anon, authenticated;
grant select, insert, update, delete on public.expense_categories, public.budgets, public.expenses to authenticated;
grant select on public.budget_progress to authenticated;
revoke all on public.budget_progress from anon;

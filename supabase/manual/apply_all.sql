-- Uruvia: all migrations in order, for pasting into the Supabase SQL Editor on an EMPTY project.

-- ======== 20261009181228_extensions_helpers.sql ========
-- Uruvia 0001: private schema, shared enums, updated_at trigger.
-- Nothing here is exposed to the Data API: the private schema is not in the exposed list.

create schema if not exists private;
grant usage on schema private to authenticated;

-- Account kinds. One person can own one Individual and one Business account.
create type public.account_type as enum ('individual', 'business');

-- Roles inside an account. Staff is a later feature, the role exists now so RLS never needs rewriting.
create type public.member_role as enum ('owner', 'staff');

-- Lifecycle of an identity check, written only by the server.
create type public.kyc_status as enum ('pending', 'approved', 'action_needed', 'rejected');

-- What a KYC submission is for: a personal tier upgrade, or the Business add-on (CAC and director BVN).
create type public.kyc_kind as enum ('tier', 'business');

-- Keeps updated_at honest on any table that has the column.
create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ======== 20261009181230_identity_accounts.sql ========
-- Uruvia 0002: profiles, accounts, membership, business profile, devices, transaction PIN.

-- ---------------------------------------------------------------- tables

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  phone text,
  avatar_path text,
  language text not null default 'en',
  -- 1 Basic (verified phone and email), 2 Verified, 3 Full. Written only by the server.
  kyc_tier smallint not null default 1 check (kyc_tier between 1 and 3),
  last_active_account_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  type public.account_type not null,
  name text not null check (char_length(name) between 1 and 80),
  status text not null default 'active' check (status in ('active', 'suspended', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, type),
  -- lets business_profiles prove its account really is a business account
  unique (id, type)
);

alter table public.profiles
  add constraint profiles_last_active_account_fk
  foreign key (last_active_account_id) references public.accounts (id) on delete set null;

create table public.account_members (
  account_id uuid not null references public.accounts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role public.member_role not null default 'owner',
  created_at timestamptz not null default now(),
  primary key (account_id, user_id)
);
create index account_members_user_id_idx on public.account_members (user_id);

create table public.business_profiles (
  account_id uuid primary key,
  account_type public.account_type not null default 'business' check (account_type = 'business'),
  business_name text not null check (char_length(business_name) between 1 and 120),
  category text,
  address text,
  logo_path text,
  invoice_prefix text not null default 'INV' check (invoice_prefix ~ '^[A-Za-z0-9]{1,8}$'),
  -- basis points, 750 = 7.5%. Editable in Business settings.
  vat_rate_bps integer not null default 750 check (vat_rate_bps between 0 and 10000),
  currency text not null default 'NGN' check (currency = 'NGN'),
  -- bank name, account number and account name printed on invoices
  payment_details jsonb not null default '{}'::jsonb,
  -- set by the server once the Business add-on check passes
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (account_id, account_type) references public.accounts (id, type) on delete cascade
);

create table public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  platform text not null check (platform in ('android', 'ios', 'web', 'other')),
  device_name text,
  push_token text,
  last_seen_at timestamptz not null default now(),
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);
create index devices_user_id_idx on public.devices (user_id);

-- Transaction PIN. No client policy on purpose: the hash is never readable from the app.
create table public.user_security (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  txn_pin_hash text,
  failed_attempts smallint not null default 0,
  locked_until timestamptz,
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at before update on public.profiles
  for each row execute function private.set_updated_at();
create trigger accounts_set_updated_at before update on public.accounts
  for each row execute function private.set_updated_at();
create trigger business_profiles_set_updated_at before update on public.business_profiles
  for each row execute function private.set_updated_at();
create trigger user_security_set_updated_at before update on public.user_security
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------- helpers used by policies
-- SECURITY DEFINER so they can read account_members without recursing into its own policy.
-- They live in the private schema, which the Data API does not expose.

create or replace function private.is_account_member(p_account_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.account_members m
    where m.account_id = p_account_id and m.user_id = (select auth.uid())
  );
$$;

create or replace function private.is_account_owner(p_account_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.account_members m
    where m.account_id = p_account_id
      and m.user_id = (select auth.uid())
      and m.role = 'owner'
  );
$$;

create or replace function private.is_business_account(p_account_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.accounts a
    where a.id = p_account_id and a.type = 'business' and a.status = 'active'
  );
$$;

-- Member of this account AND the account is a business. Used by every Business-only table.
create or replace function private.is_business_member(p_account_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_account_member(p_account_id) and private.is_business_account(p_account_id);
$$;

revoke all on function private.is_account_member(uuid) from public;
revoke all on function private.is_account_owner(uuid) from public;
revoke all on function private.is_business_account(uuid) from public;
revoke all on function private.is_business_member(uuid) from public;
grant execute on function private.is_account_member(uuid) to authenticated;
grant execute on function private.is_account_owner(uuid) to authenticated;
grant execute on function private.is_business_account(uuid) to authenticated;
grant execute on function private.is_business_member(uuid) to authenticated;

-- ---------------------------------------------------------------- triggers

-- A profile row appears the moment someone signs up.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    nullif(new.raw_user_meta_data ->> 'full_name', ''),
    nullif(new.phone, '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- Creating an account makes its creator the owner.
create or replace function private.handle_new_account()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.account_members (account_id, user_id, role)
  values (new.id, new.owner_id, 'owner');
  return new;
end;
$$;

create trigger on_account_created
  after insert on public.accounts
  for each row execute function private.handle_new_account();

-- ---------------------------------------------------------------- row level security

alter table public.profiles enable row level security;
alter table public.accounts enable row level security;
alter table public.account_members enable row level security;
alter table public.business_profiles enable row level security;
alter table public.devices enable row level security;
alter table public.user_security enable row level security;

-- profiles: read and edit your own row. kyc_tier and phone are not editable from the app.
create policy profiles_select_own on public.profiles for select to authenticated
  using ((select auth.uid()) = id);

create policy profiles_update_own on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check (
    (select auth.uid()) = id
    and (last_active_account_id is null or private.is_account_member(last_active_account_id))
  );

-- accounts: members read; anyone may create their own; only the owner renames.
-- The owner check is needed because INSERT ... RETURNING reads the new row before the membership trigger has run.
create policy accounts_select_member on public.accounts for select to authenticated
  using (owner_id = (select auth.uid()) or private.is_account_member(id));

create policy accounts_insert_own on public.accounts for insert to authenticated
  with check ((select auth.uid()) = owner_id);

create policy accounts_update_owner on public.accounts for update to authenticated
  using (private.is_account_owner(id))
  with check (private.is_account_owner(id));

-- account_members: you can see your own memberships and the other members of your accounts.
-- Writes happen only through triggers and, later, server functions.
create policy account_members_select on public.account_members for select to authenticated
  using (user_id = (select auth.uid()) or private.is_account_member(account_id));

-- business_profiles: only for business accounts, writable by the owner.
create policy business_profiles_select on public.business_profiles for select to authenticated
  using (private.is_account_member(account_id));

create policy business_profiles_insert on public.business_profiles for insert to authenticated
  with check (private.is_account_owner(account_id));

create policy business_profiles_update on public.business_profiles for update to authenticated
  using (private.is_account_owner(account_id))
  with check (private.is_account_owner(account_id));

-- devices: your own.
create policy devices_select_own on public.devices for select to authenticated
  using ((select auth.uid()) = user_id);
create policy devices_insert_own on public.devices for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy devices_update_own on public.devices for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- user_security: deliberately no policies. Only the functions below can touch it.

-- ---------------------------------------------------------------- privileges (explicit, anon gets nothing)

revoke all on public.profiles, public.accounts, public.account_members, public.business_profiles,
  public.devices, public.user_security from anon, authenticated;

grant select on public.profiles to authenticated;
grant update (full_name, avatar_path, language, last_active_account_id) on public.profiles to authenticated;

grant select, insert on public.accounts to authenticated;
grant update (name) on public.accounts to authenticated;

grant select on public.account_members to authenticated;

grant select, insert on public.business_profiles to authenticated;
grant update (business_name, category, address, logo_path, invoice_prefix, vat_rate_bps, payment_details)
  on public.business_profiles to authenticated;

grant select, insert on public.devices to authenticated;
grant update (device_name, push_token, last_seen_at, revoked_at) on public.devices to authenticated;

-- ---------------------------------------------------------------- transaction PIN functions

create or replace function private.set_txn_pin(p_pin text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  if p_pin is null or p_pin !~ '^[0-9]{4,6}$' then
    raise exception 'PIN must be 4 to 6 digits' using errcode = '22023';
  end if;

  insert into public.user_security (user_id, txn_pin_hash, failed_attempts, locked_until)
  values (v_uid, extensions.crypt(p_pin, extensions.gen_salt('bf')), 0, null)
  on conflict (user_id) do update
    set txn_pin_hash = excluded.txn_pin_hash,
        failed_attempts = 0,
        locked_until = null;
end;
$$;

-- Returns true when the PIN is right. Five wrong tries lock the PIN for 15 minutes.
-- Money functions call this before they move anything.
create or replace function private.verify_txn_pin(p_pin text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_row public.user_security%rowtype;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;

  select * into v_row from public.user_security where user_id = v_uid for update;
  if not found or v_row.txn_pin_hash is null then
    raise exception 'no transaction PIN set' using errcode = '22023';
  end if;
  if v_row.locked_until is not null and v_row.locked_until > now() then
    raise exception 'PIN locked until %', v_row.locked_until using errcode = '55000';
  end if;

  if v_row.txn_pin_hash = extensions.crypt(p_pin, v_row.txn_pin_hash) then
    update public.user_security set failed_attempts = 0, locked_until = null where user_id = v_uid;
    return true;
  end if;

  update public.user_security
    set failed_attempts = failed_attempts + 1,
        locked_until = case when failed_attempts + 1 >= 5 then now() + interval '15 minutes' else null end
    where user_id = v_uid;
  return false;
end;
$$;

revoke all on function private.set_txn_pin(text) from public;
revoke all on function private.verify_txn_pin(text) from public;
grant execute on function private.set_txn_pin(text) to authenticated;
grant execute on function private.verify_txn_pin(text) to authenticated;

-- ---------------------------------------------------------------- RPCs the app calls

-- Thin invoker wrappers: the app calls these, the private functions do the work.
create or replace function public.set_transaction_pin(p_pin text)
returns void
language sql
security invoker
set search_path = ''
as $$ select private.set_txn_pin(p_pin); $$;

create or replace function public.verify_transaction_pin(p_pin text)
returns boolean
language sql
security invoker
set search_path = ''
as $$ select private.verify_txn_pin(p_pin); $$;

-- Create an account for the signed-in user and make it the active one.
create or replace function public.create_account(p_type public.account_type, p_name text)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_id uuid;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;

  insert into public.accounts (owner_id, type, name)
  values (v_uid, p_type, p_name)
  returning id into v_id;

  update public.profiles set last_active_account_id = v_id where id = v_uid;
  return v_id;
end;
$$;

revoke all on function public.set_transaction_pin(text) from public, anon;
revoke all on function public.verify_transaction_pin(text) from public, anon;
revoke all on function public.create_account(public.account_type, text) from public, anon;
grant execute on function public.set_transaction_pin(text) to authenticated;
grant execute on function public.verify_transaction_pin(text) to authenticated;
grant execute on function public.create_account(public.account_type, text) to authenticated;

-- ======== 20261009181232_kyc_config.sql ========
-- Uruvia 0003: KYC tiers (config), submissions, documents, private storage bucket.
-- Limits are left empty on purpose: they come from the partner bank and regulator and are still to be confirmed.

create table public.kyc_tiers (
  tier smallint primary key check (tier between 1 and 3),
  name text not null,
  requirements text not null,
  -- to be confirmed with the partner bank; null means "not set yet"
  daily_send_limit_kobo bigint check (daily_send_limit_kobo is null or daily_send_limit_kobo >= 0),
  wallet_balance_cap_kobo bigint check (wallet_balance_cap_kobo is null or wallet_balance_cap_kobo >= 0),
  savings_cap_kobo bigint check (savings_cap_kobo is null or savings_cap_kobo >= 0),
  allows_group_payout boolean not null default false,
  is_provisional boolean not null default true
);

insert into public.kyc_tiers (tier, name, requirements, allows_group_payout) values
  (1, 'Basic',    'Verified phone and email', false),
  (2, 'Verified', 'BVN and selfie', false),
  (3, 'Full',     'NIN or a government ID and proof of address', true);

create table public.kyc_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  kind public.kyc_kind not null default 'tier',
  -- for kind = 'tier': which tier the user is applying for
  tier_target smallint references public.kyc_tiers (tier),
  -- for kind = 'business': the business account the add-on is for
  account_id uuid references public.accounts (id) on delete cascade,
  status public.kyc_status not null default 'pending',
  -- the one clear reason shown when action is needed
  reason text,
  provider_ref text,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  check (
    (kind = 'tier' and tier_target between 2 and 3 and account_id is null)
    or (kind = 'business' and account_id is not null and tier_target is null)
  )
);
create index kyc_submissions_user_id_idx on public.kyc_submissions (user_id);
create index kyc_submissions_account_id_idx on public.kyc_submissions (account_id);

create table public.kyc_documents (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.kyc_submissions (id) on delete cascade,
  doc_type text not null check (doc_type in (
    'id_front', 'id_back', 'selfie', 'proof_of_address', 'cac_certificate', 'director_id'
  )),
  storage_path text not null,
  created_at timestamptz not null default now()
);
create index kyc_documents_submission_id_idx on public.kyc_documents (submission_id);

alter table public.kyc_tiers enable row level security;
alter table public.kyc_submissions enable row level security;
alter table public.kyc_documents enable row level security;

create policy kyc_tiers_read on public.kyc_tiers for select to authenticated using (true);

create policy kyc_submissions_select_own on public.kyc_submissions for select to authenticated
  using ((select auth.uid()) = user_id);

-- A user can only start a pending check for themselves. Approval, rejection and tier changes are server-only.
create policy kyc_submissions_insert_own on public.kyc_submissions for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and status = 'pending'
    and reason is null
    and provider_ref is null
    and reviewed_at is null
    and (account_id is null or private.is_account_owner(account_id))
  );

create policy kyc_documents_select_own on public.kyc_documents for select to authenticated
  using (exists (
    select 1 from public.kyc_submissions s
    where s.id = submission_id and s.user_id = (select auth.uid())
  ));

create policy kyc_documents_insert_own on public.kyc_documents for insert to authenticated
  with check (exists (
    select 1 from public.kyc_submissions s
    where s.id = submission_id and s.user_id = (select auth.uid()) and s.status in ('pending', 'action_needed')
  ));

revoke all on public.kyc_tiers, public.kyc_submissions, public.kyc_documents from anon, authenticated;
grant select on public.kyc_tiers to authenticated;
grant select, insert on public.kyc_submissions to authenticated;
grant select, insert on public.kyc_documents to authenticated;

-- ---------------------------------------------------------------- private bucket for ID documents
-- Path convention: {user_id}/{file}. Owner can add and read their own files. No update, no delete from the app.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('kyc', 'kyc', false, 10485760, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
on conflict (id) do nothing;

create policy kyc_objects_insert_own on storage.objects for insert to authenticated
  with check (bucket_id = 'kyc' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy kyc_objects_select_own on storage.objects for select to authenticated
  using (bucket_id = 'kyc' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- ======== 20261010003954_budgets_expenses.sql ========
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

-- ======== 20261010003956_inventory.sql ========
-- Uruvia 0005: inventory (Business accounts only).
-- Every product has In stock, Reserved and Available (= In stock minus Reserved).
-- Stock numbers change only through the functions at the bottom; the app cannot write them directly.

create type public.stock_movement_kind as enum (
  'opening', 'restock', 'reserve', 'release', 'sale',
  'adjust_damaged', 'adjust_lost', 'adjust_count', 'reversal'
);
create type public.reservation_status as enum ('active', 'released', 'consumed');

create table public.product_categories (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 60),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (id, account_id)
);
create unique index product_categories_name_uq on public.product_categories (account_id, lower(name));

create table public.products (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  category_id uuid,
  name text not null check (char_length(name) between 1 and 120),
  sku text not null check (char_length(sku) between 1 and 60),
  unit text not null default 'pieces',
  cost_kobo bigint not null default 0 check (cost_kobo >= 0),
  price_kobo bigint not null default 0 check (price_kobo >= 0),
  qty_on_hand integer not null default 0 check (qty_on_hand >= 0),
  qty_reserved integer not null default 0 check (qty_reserved >= 0),
  qty_available integer generated always as (qty_on_hand - qty_reserved) stored,
  low_stock_alert boolean not null default true,
  low_stock_threshold integer not null default 5 check (low_stock_threshold >= 0),
  image_path text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (qty_reserved <= qty_on_hand),
  unique (id, account_id),
  foreign key (category_id, account_id) references public.product_categories (id, account_id) on delete restrict
);
create unique index products_sku_uq on public.products (account_id, lower(sku));
create index products_category_idx on public.products (category_id, account_id);

create table public.stock_reservations (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  product_id uuid not null,
  -- foreign key to invoices is added in the invoices migration
  invoice_id uuid,
  customer_id uuid,
  qty integer not null check (qty > 0),
  note text,
  status public.reservation_status not null default 'active',
  reserved_at timestamptz not null default now(),
  -- an unpaid invoice holds stock for at most 10 days
  expires_at timestamptz not null default (now() + interval '10 days'),
  day8_notified_at timestamptz,
  expiry_notified_at timestamptz,
  closed_at timestamptz,
  foreign key (product_id, account_id) references public.products (id, account_id) on delete cascade
);
create index stock_reservations_product_idx on public.stock_reservations (product_id, account_id);
create index stock_reservations_invoice_idx on public.stock_reservations (invoice_id);
create index stock_reservations_active_expiry_idx on public.stock_reservations (expires_at) where status = 'active';

create table public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  product_id uuid not null,
  kind public.stock_movement_kind not null,
  -- change to In stock and to Reserved, signed
  delta_on_hand integer not null default 0,
  delta_reserved integer not null default 0,
  reservation_id uuid references public.stock_reservations (id) on delete set null,
  invoice_id uuid,
  sale_id uuid,
  note text,
  created_by uuid default auth.uid() references public.profiles (id),
  created_at timestamptz not null default now(),
  foreign key (product_id, account_id) references public.products (id, account_id) on delete cascade
);
create index stock_movements_product_idx on public.stock_movements (product_id, created_at desc);
create index stock_movements_reservation_idx on public.stock_movements (reservation_id);

create table public.restock_reminders (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  product_id uuid not null,
  remind_at timestamptz not null,
  done_at timestamptz,
  created_at timestamptz not null default now(),
  foreign key (product_id, account_id) references public.products (id, account_id) on delete cascade
);
create index restock_reminders_product_idx on public.restock_reminders (product_id, account_id);

create trigger products_set_updated_at before update on public.products
  for each row execute function private.set_updated_at();

-- Opening stock typed on the add-product form becomes the first movement.
create or replace function private.log_opening_stock()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.qty_on_hand > 0 then
    insert into public.stock_movements (account_id, product_id, kind, delta_on_hand, note)
    values (new.account_id, new.id, 'opening', new.qty_on_hand, 'Opening stock');
  end if;
  return new;
end;
$$;
create trigger products_log_opening after insert on public.products
  for each row execute function private.log_opening_stock();

-- ---------------------------------------------------------------- RLS (Business accounts only)

alter table public.product_categories enable row level security;
alter table public.products enable row level security;
alter table public.stock_reservations enable row level security;
alter table public.stock_movements enable row level security;
alter table public.restock_reminders enable row level security;

create policy product_categories_all on public.product_categories for all to authenticated
  using (private.is_business_member(account_id)) with check (private.is_business_member(account_id));
create policy products_select on public.products for select to authenticated
  using (private.is_business_member(account_id));
create policy products_insert on public.products for insert to authenticated
  with check (private.is_business_member(account_id) and qty_reserved = 0);
create policy products_update on public.products for update to authenticated
  using (private.is_business_member(account_id)) with check (private.is_business_member(account_id));
create policy stock_reservations_select on public.stock_reservations for select to authenticated
  using (private.is_business_member(account_id));
create policy stock_movements_select on public.stock_movements for select to authenticated
  using (private.is_business_member(account_id));
create policy restock_reminders_all on public.restock_reminders for all to authenticated
  using (private.is_business_member(account_id)) with check (private.is_business_member(account_id));

revoke all on public.product_categories, public.products, public.stock_reservations,
  public.stock_movements, public.restock_reminders from anon, authenticated;

grant select, insert, update, delete on public.product_categories, public.restock_reminders to authenticated;
grant select on public.stock_reservations, public.stock_movements to authenticated;
-- qty_on_hand may be set on insert (opening stock) but never updated directly. qty_reserved is never client-written.
grant select on public.products to authenticated;
grant insert (account_id, category_id, name, sku, unit, cost_kobo, price_kobo, qty_on_hand,
              low_stock_alert, low_stock_threshold, image_path) on public.products to authenticated;
grant update (category_id, name, sku, unit, cost_kobo, price_kobo, low_stock_alert,
              low_stock_threshold, image_path, archived_at) on public.products to authenticated;

-- ---------------------------------------------------------------- stock functions (private, checked inside)

create or replace function private.assert_business_member(p_account_id uuid)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  if not private.is_business_member(p_account_id) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
end;
$$;

-- Reserve stock. Fails with the maximum available if the request is too large.
-- Called by issue_invoice() and by the manual Reserve sheet. Callers must already have checked membership.
create or replace function private.reserve_stock(
  p_account_id uuid, p_product_id uuid, p_qty integer,
  p_invoice_id uuid default null, p_customer_id uuid default null, p_note text default null
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_prod public.products%rowtype;
  v_id uuid;
begin
  perform private.assert_business_member(p_account_id);
  select * into v_prod from public.products
   where id = p_product_id and account_id = p_account_id for update;
  if not found then
    raise exception 'product not found' using errcode = 'P0002';
  end if;
  if p_qty is null or p_qty <= 0 then
    raise exception 'quantity must be positive' using errcode = '22023';
  end if;
  if p_qty > v_prod.qty_available then
    raise exception 'Only % available for %', v_prod.qty_available, v_prod.name using errcode = '23514';
  end if;

  update public.products set qty_reserved = qty_reserved + p_qty where id = p_product_id;
  insert into public.stock_reservations (account_id, product_id, invoice_id, customer_id, qty, note)
  values (p_account_id, p_product_id, p_invoice_id, p_customer_id, p_qty, p_note)
  returning id into v_id;
  insert into public.stock_movements (account_id, product_id, kind, delta_reserved, reservation_id, invoice_id, note)
  values (p_account_id, p_product_id, 'reserve', p_qty, v_id, p_invoice_id, p_note);
  return v_id;
end;
$$;

create or replace function private.release_reservation(p_reservation_id uuid, p_note text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r public.stock_reservations%rowtype;
begin
  select * into r from public.stock_reservations where id = p_reservation_id for update;
  if not found or r.status <> 'active' then
    return;
  end if;
  -- scheduled jobs have no signed-in user; app calls must come from a member of the account
  if (select auth.uid()) is not null then
    perform private.assert_business_member(r.account_id);
  end if;
  perform 1 from public.products where id = r.product_id for update;
  update public.products set qty_reserved = qty_reserved - r.qty where id = r.product_id;
  update public.stock_reservations set status = 'released', closed_at = now() where id = r.id;
  insert into public.stock_movements (account_id, product_id, kind, delta_reserved, reservation_id, invoice_id, note)
  values (r.account_id, r.product_id, 'release', -r.qty, r.id, r.invoice_id, p_note);
end;
$$;

-- ---------------------------------------------------------------- RPCs the app calls

create or replace function public.reserve_product_stock(
  p_product_id uuid, p_qty integer, p_customer_id uuid default null, p_note text default null
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_account uuid;
begin
  select account_id into v_account from public.products where id = p_product_id;
  if v_account is null then
    raise exception 'product not found' using errcode = 'P0002';
  end if;
  perform private.assert_business_member(v_account);
  return private.reserve_stock(v_account, p_product_id, p_qty, null, p_customer_id, p_note);
end;
$$;

create or replace function public.release_product_reservation(p_reservation_id uuid)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_account uuid;
begin
  select account_id into v_account from public.stock_reservations where id = p_reservation_id;
  if v_account is null then
    raise exception 'reservation not found' using errcode = 'P0002';
  end if;
  perform private.assert_business_member(v_account);
  perform private.release_reservation(p_reservation_id, 'Released manually');
end;
$$;

create or replace function public.restock_product(p_product_id uuid, p_qty integer, p_note text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_account uuid;
begin
  select account_id into v_account from public.products where id = p_product_id;
  if v_account is null then
    raise exception 'product not found' using errcode = 'P0002';
  end if;
  perform private.assert_business_member(v_account);
  if p_qty is null or p_qty <= 0 then
    raise exception 'quantity must be positive' using errcode = '22023';
  end if;
  perform 1 from public.products where id = p_product_id for update;
  update public.products set qty_on_hand = qty_on_hand + p_qty where id = p_product_id;
  insert into public.stock_movements (account_id, product_id, kind, delta_on_hand, note)
  values (v_account, p_product_id, 'restock', p_qty, p_note);
end;
$$;

-- Reasons: damaged, lost, count. p_delta is signed; the result may not go below what is reserved.
create or replace function public.adjust_product_stock(p_product_id uuid, p_delta integer, p_reason text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_account uuid;
  v_kind public.stock_movement_kind;
begin
  select account_id into v_account from public.products where id = p_product_id;
  if v_account is null then
    raise exception 'product not found' using errcode = 'P0002';
  end if;
  perform private.assert_business_member(v_account);
  v_kind := case p_reason
    when 'damaged' then 'adjust_damaged'
    when 'lost' then 'adjust_lost'
    when 'count' then 'adjust_count'
    else null end;
  if v_kind is null then
    raise exception 'reason must be damaged, lost or count' using errcode = '22023';
  end if;
  if p_delta is null or p_delta = 0 then
    raise exception 'adjustment cannot be zero' using errcode = '22023';
  end if;
  perform 1 from public.products where id = p_product_id for update;
  -- products check constraints reject anything that would go below zero or below Reserved
  update public.products set qty_on_hand = qty_on_hand + p_delta where id = p_product_id;
  insert into public.stock_movements (account_id, product_id, kind, delta_on_hand, note)
  values (v_account, p_product_id, v_kind, p_delta, p_note);
end;
$$;

-- These public functions run as definer on purpose: stock columns are not client-writable.
-- Each one checks Business membership first and is not granted to anon.
-- Only an empty category can be deleted: products.category_id is ON DELETE RESTRICT.

revoke all on function private.assert_business_member(uuid) from public;
revoke all on function private.reserve_stock(uuid, uuid, integer, uuid, uuid, text) from public;
revoke all on function private.release_reservation(uuid, text) from public;
grant execute on function private.assert_business_member(uuid) to authenticated;
grant execute on function private.reserve_stock(uuid, uuid, integer, uuid, uuid, text) to authenticated;
grant execute on function private.release_reservation(uuid, text) to authenticated;

revoke all on function public.reserve_product_stock(uuid, integer, uuid, text) from public, anon;
revoke all on function public.release_product_reservation(uuid) from public, anon;
revoke all on function public.restock_product(uuid, integer, text) from public, anon;
revoke all on function public.adjust_product_stock(uuid, integer, text, text) from public, anon;
grant execute on function public.reserve_product_stock(uuid, integer, uuid, text) to authenticated;
grant execute on function public.release_product_reservation(uuid) to authenticated;
grant execute on function public.restock_product(uuid, integer, text) to authenticated;
grant execute on function public.adjust_product_stock(uuid, integer, text, text) to authenticated;

-- ======== 20261010003958_invoices_sales.sql ========
-- Uruvia 0006: customers, invoices, payments, sales (Business accounts only).
-- Rules from the design: drafts hold no stock; issuing reserves stock; no edits once a payment exists;
-- a fully paid invoice creates a sale and moves stock from reserved to sold.
-- Wallet payments are on hold: invoice_payments.wallet_transaction_id is a plain nullable uuid for now.

create type public.invoice_status as enum ('draft', 'sent', 'partially_paid', 'paid', 'overdue', 'cancelled');
create type public.payment_method as enum ('wallet', 'transfer', 'cash', 'pos', 'card');

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  phone text,
  email text,
  address text,
  notes text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, account_id)
);
create index customers_account_idx on public.customers (account_id, lower(name));

-- Gap-free per-account numbering for invoices and sales.
create table public.doc_counters (
  account_id uuid not null references public.accounts (id) on delete cascade,
  kind text not null check (kind in ('invoice', 'sale')),
  last_number bigint not null default 0,
  primary key (account_id, kind)
);

create table public.invoices (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  customer_id uuid not null,
  invoice_number text not null,
  status public.invoice_status not null default 'draft',
  issue_date date not null default current_date,
  due_date date not null default (current_date + 14),
  -- inputs the app may set while the invoice is a draft
  discount_kobo bigint not null default 0 check (discount_kobo >= 0),
  vat_enabled boolean not null default false,
  charges_kobo bigint not null default 0 check (charges_kobo >= 0),
  notes text,
  terms text,
  -- computed by the database
  vat_rate_bps integer not null default 0,
  subtotal_kobo bigint not null default 0,
  vat_kobo bigint not null default 0,
  total_kobo bigint not null default 0,
  amount_paid_kobo bigint not null default 0 check (amount_paid_kobo >= 0),
  balance_kobo bigint generated always as (total_kobo - amount_paid_kobo) stored,
  issued_at timestamptz,
  paid_at timestamptz,
  cancelled_at timestamptz,
  revised_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, account_id),
  unique (account_id, invoice_number),
  check (amount_paid_kobo <= total_kobo or status = 'draft'),
  foreign key (customer_id, account_id) references public.customers (id, account_id) on delete restrict
);
create index invoices_account_status_idx on public.invoices (account_id, status, due_date);
create index invoices_customer_idx on public.invoices (customer_id, account_id);

create table public.invoice_items (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  invoice_id uuid not null,
  -- null for custom lines such as services
  product_id uuid,
  description text not null check (char_length(description) between 1 and 200),
  qty integer not null check (qty > 0),
  unit_price_kobo bigint not null check (unit_price_kobo >= 0),
  line_total_kobo bigint generated always as (qty * unit_price_kobo) stored,
  -- cost at the time of sale, filled when the invoice is issued
  unit_cost_kobo bigint not null default 0,
  sort_order integer not null default 0,
  foreign key (invoice_id, account_id) references public.invoices (id, account_id) on delete cascade,
  foreign key (product_id, account_id) references public.products (id, account_id) on delete restrict
);
create index invoice_items_invoice_idx on public.invoice_items (invoice_id, account_id);
create index invoice_items_product_idx on public.invoice_items (product_id, account_id);

create table public.invoice_payments (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  invoice_id uuid not null,
  amount_kobo bigint not null check (amount_kobo > 0),
  method public.payment_method not null,
  paid_on date not null default current_date,
  reference text,
  proof_path text,
  -- becomes a foreign key to the ledger when the wallet migration is written
  wallet_transaction_id uuid,
  recorded_by uuid default auth.uid() references public.profiles (id),
  created_at timestamptz not null default now(),
  foreign key (invoice_id, account_id) references public.invoices (id, account_id) on delete cascade
);
create index invoice_payments_invoice_idx on public.invoice_payments (invoice_id, account_id);

create table public.sales (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  sale_number text not null,
  invoice_id uuid,
  customer_id uuid,
  total_kobo bigint not null check (total_kobo >= 0),
  cost_kobo bigint not null default 0,
  profit_kobo bigint generated always as (total_kobo - cost_kobo) stored,
  sold_at timestamptz not null default now(),
  -- sale reversal rules are an open board decision; the columns exist so no later migration is needed
  reversed_at timestamptz,
  reversal_reason text,
  unique (id, account_id),
  unique (account_id, sale_number),
  unique (invoice_id),
  foreign key (invoice_id, account_id) references public.invoices (id, account_id) on delete restrict,
  foreign key (customer_id, account_id) references public.customers (id, account_id) on delete restrict
);
create index sales_account_sold_idx on public.sales (account_id, sold_at desc);
create index sales_customer_idx on public.sales (customer_id, account_id);

create table public.sale_items (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null,
  sale_id uuid not null,
  product_id uuid,
  description text not null,
  qty integer not null check (qty > 0),
  unit_price_kobo bigint not null,
  unit_cost_kobo bigint not null default 0,
  foreign key (sale_id, account_id) references public.sales (id, account_id) on delete cascade,
  foreign key (product_id, account_id) references public.products (id, account_id) on delete restrict
);
create index sale_items_sale_idx on public.sale_items (sale_id, account_id);
create index sale_items_product_idx on public.sale_items (product_id, account_id);

-- Now that invoices and sales exist, tie stock records to them.
alter table public.stock_reservations
  add constraint stock_reservations_invoice_fk foreign key (invoice_id, account_id)
  references public.invoices (id, account_id) on delete cascade;
alter table public.stock_reservations
  add constraint stock_reservations_customer_fk foreign key (customer_id, account_id)
  references public.customers (id, account_id) on delete set null (customer_id);
alter table public.stock_movements
  add constraint stock_movements_sale_fk foreign key (sale_id, account_id)
  references public.sales (id, account_id) on delete set null (sale_id);
create index stock_reservations_customer_idx on public.stock_reservations (customer_id, account_id);
create index stock_movements_sale_idx on public.stock_movements (sale_id, account_id);
create index stock_movements_invoice_idx on public.stock_movements (invoice_id);

create trigger customers_set_updated_at before update on public.customers
  for each row execute function private.set_updated_at();
create trigger invoices_set_updated_at before update on public.invoices
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------- numbering and totals

create or replace function private.next_doc_number(p_account_id uuid, p_kind text)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_n bigint;
begin
  insert into public.doc_counters (account_id, kind, last_number) values (p_account_id, p_kind, 1)
  on conflict (account_id, kind) do update set last_number = public.doc_counters.last_number + 1
  returning last_number into v_n;
  return v_n;
end;
$$;

-- Fills the invoice number, VAT rate snapshot and totals. Clients cannot write these columns.
create or replace function private.invoice_before_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_prefix text;
  v_rate integer;
  v_base bigint;
begin
  if tg_op = 'INSERT' then
    select invoice_prefix, vat_rate_bps into v_prefix, v_rate
      from public.business_profiles where account_id = new.account_id;
    new.invoice_number := coalesce(v_prefix, 'INV') || '-' || lpad(private.next_doc_number(new.account_id, 'invoice')::text, 5, '0');
    new.vat_rate_bps := coalesce(v_rate, 0);
    new.status := 'draft';
    new.subtotal_kobo := 0;
    new.amount_paid_kobo := 0;
  end if;

  if new.due_date < new.issue_date then
    raise exception 'due date cannot be before the issue date' using errcode = '23514';
  end if;

  v_base := greatest(new.subtotal_kobo - new.discount_kobo, 0);
  new.vat_kobo := case when new.vat_enabled then round(v_base * new.vat_rate_bps / 10000.0)::bigint else 0 end;
  new.total_kobo := v_base + new.vat_kobo + new.charges_kobo;
  return new;
end;
$$;

create trigger invoices_before_write before insert or update of discount_kobo, vat_enabled, charges_kobo,
  subtotal_kobo, issue_date, due_date on public.invoices
  for each row execute function private.invoice_before_write();

-- Items change the subtotal, which re-runs the trigger above.
create or replace function private.invoice_items_after_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_invoice uuid := coalesce(new.invoice_id, old.invoice_id);
  v_account uuid := coalesce(new.account_id, old.account_id);
begin
  update public.invoices i
     set subtotal_kobo = coalesce((select sum(line_total_kobo) from public.invoice_items where invoice_id = v_invoice), 0)
   where i.id = v_invoice and i.account_id = v_account;
  return null;
end;
$$;

create trigger invoice_items_after_write after insert or update or delete on public.invoice_items
  for each row execute function private.invoice_items_after_write();

-- Items only change while the invoice is a draft.
create or replace function private.invoice_items_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status public.invoice_status;
begin
  select status into v_status from public.invoices
   where id = coalesce(new.invoice_id, old.invoice_id) and account_id = coalesce(new.account_id, old.account_id);
  if v_status is distinct from 'draft' then
    raise exception 'items can only change while the invoice is a draft' using errcode = '55000';
  end if;
  return coalesce(new, old);
end;
$$;

create trigger invoice_items_guard before insert or update or delete on public.invoice_items
  for each row execute function private.invoice_items_guard();

-- ---------------------------------------------------------------- RLS (Business accounts only)

alter table public.customers enable row level security;
alter table public.doc_counters enable row level security;
alter table public.invoices enable row level security;
alter table public.invoice_items enable row level security;
alter table public.invoice_payments enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;

create policy customers_select on public.customers for select to authenticated
  using (private.is_business_member(account_id));
create policy customers_insert on public.customers for insert to authenticated
  with check (private.is_business_member(account_id));
create policy customers_update on public.customers for update to authenticated
  using (private.is_business_member(account_id)) with check (private.is_business_member(account_id));

create policy invoices_select on public.invoices for select to authenticated
  using (private.is_business_member(account_id));
create policy invoices_insert on public.invoices for insert to authenticated
  with check (private.is_business_member(account_id));
create policy invoices_update_draft on public.invoices for update to authenticated
  using (private.is_business_member(account_id) and status = 'draft')
  with check (private.is_business_member(account_id));

create policy invoice_items_select on public.invoice_items for select to authenticated
  using (private.is_business_member(account_id));
create policy invoice_items_insert on public.invoice_items for insert to authenticated
  with check (private.is_business_member(account_id));
create policy invoice_items_update on public.invoice_items for update to authenticated
  using (private.is_business_member(account_id)) with check (private.is_business_member(account_id));
create policy invoice_items_delete on public.invoice_items for delete to authenticated
  using (private.is_business_member(account_id));

create policy invoice_payments_select on public.invoice_payments for select to authenticated
  using (private.is_business_member(account_id));
create policy sales_select on public.sales for select to authenticated
  using (private.is_business_member(account_id));
create policy sale_items_select on public.sale_items for select to authenticated
  using (private.is_business_member(account_id));
-- doc_counters: no client policy on purpose.

revoke all on public.customers, public.doc_counters, public.invoices, public.invoice_items,
  public.invoice_payments, public.sales, public.sale_items from anon, authenticated;

grant select, insert on public.customers to authenticated;
grant update (name, phone, email, address, notes) on public.customers to authenticated;
grant select on public.invoices, public.invoice_payments, public.sales, public.sale_items to authenticated;
grant insert (account_id, customer_id, issue_date, due_date, discount_kobo, vat_enabled, charges_kobo, notes, terms)
  on public.invoices to authenticated;
grant update (customer_id, issue_date, due_date, discount_kobo, vat_enabled, charges_kobo, notes, terms)
  on public.invoices to authenticated;
grant select, delete on public.invoice_items to authenticated;
grant insert (account_id, invoice_id, product_id, description, qty, unit_price_kobo, sort_order)
  on public.invoice_items to authenticated;
grant update (product_id, description, qty, unit_price_kobo, sort_order) on public.invoice_items to authenticated;

-- ---------------------------------------------------------------- invoice functions
-- Public functions below run as definer on purpose: status, paid amounts and stock are not client-writable.
-- Each one checks Business membership first (lock_invoice or assert_business_member) and is not granted to anon.

create or replace function private.lock_invoice(p_invoice_id uuid)
returns public.invoices
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.invoices%rowtype;
begin
  select * into v from public.invoices where id = p_invoice_id for update;
  if not found then
    raise exception 'invoice not found' using errcode = 'P0002';
  end if;
  perform private.assert_business_member(v.account_id);
  return v;
end;
$$;

-- Draft to sent: reserves stock for every product line, all or nothing.
create or replace function public.issue_invoice(p_invoice_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.invoices%rowtype;
  it record;
begin
  v := private.lock_invoice(p_invoice_id);
  if v.status <> 'draft' then
    raise exception 'only a draft can be issued' using errcode = '55000';
  end if;
  if not exists (select 1 from public.invoice_items where invoice_id = v.id) then
    raise exception 'add at least one item first' using errcode = '23514';
  end if;

  for it in
    select i.id, i.product_id, i.qty, p.cost_kobo
      from public.invoice_items i left join public.products p on p.id = i.product_id and p.account_id = i.account_id
     where i.invoice_id = v.id
  loop
    if it.product_id is not null then
      perform private.reserve_stock(v.account_id, it.product_id, it.qty, v.id, v.customer_id, 'Invoice ' || v.invoice_number);
      update public.invoice_items set unit_cost_kobo = it.cost_kobo where id = it.id;
    end if;
  end loop;

  update public.invoices set status = 'sent', issued_at = now(), revised_at = null where id = v.id;
end;
$$;

-- Lets a user edit an issued invoice that has no payment yet: back to draft, stock released.
create or replace function public.revert_invoice_to_draft(p_invoice_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.invoices%rowtype;
  r record;
begin
  v := private.lock_invoice(p_invoice_id);
  if v.status not in ('sent', 'overdue') or v.amount_paid_kobo > 0 then
    raise exception 'an invoice can only be edited while it has no payment' using errcode = '55000';
  end if;
  for r in select id from public.stock_reservations where invoice_id = v.id and status = 'active' loop
    perform private.release_reservation(r.id, 'Invoice reopened for editing');
  end loop;
  update public.invoices set status = 'draft', issued_at = null, revised_at = now() where id = v.id;
end;
$$;

create or replace function public.cancel_invoice(p_invoice_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.invoices%rowtype;
  r record;
begin
  v := private.lock_invoice(p_invoice_id);
  if v.status in ('paid', 'cancelled') then
    raise exception 'this invoice cannot be cancelled' using errcode = '55000';
  end if;
  for r in select id from public.stock_reservations where invoice_id = v.id and status = 'active' loop
    perform private.release_reservation(r.id, 'Invoice cancelled');
  end loop;
  update public.invoices set status = 'cancelled', cancelled_at = now() where id = v.id;
end;
$$;

create or replace function private.create_sale_from_invoice(p_invoice_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.invoices%rowtype;
  v_sale uuid;
  v_cost bigint;
  r record;
begin
  select * into v from public.invoices where id = p_invoice_id;
  perform private.assert_business_member(v.account_id);

  select coalesce(sum(qty * unit_cost_kobo), 0) into v_cost from public.invoice_items where invoice_id = v.id;
  insert into public.sales (account_id, sale_number, invoice_id, customer_id, total_kobo, cost_kobo)
  values (v.account_id, 'SAL-' || lpad(private.next_doc_number(v.account_id, 'sale')::text, 5, '0'),
          v.id, v.customer_id, v.total_kobo, v_cost)
  returning id into v_sale;

  insert into public.sale_items (account_id, sale_id, product_id, description, qty, unit_price_kobo, unit_cost_kobo)
  select account_id, v_sale, product_id, description, qty, unit_price_kobo, unit_cost_kobo
    from public.invoice_items where invoice_id = v.id;

  -- reserved stock leaves the shelf
  for r in select * from public.stock_reservations where invoice_id = v.id and status = 'active' loop
    perform 1 from public.products where id = r.product_id for update;
    update public.products set qty_on_hand = qty_on_hand - r.qty, qty_reserved = qty_reserved - r.qty
     where id = r.product_id;
    update public.stock_reservations set status = 'consumed', closed_at = now() where id = r.id;
    insert into public.stock_movements (account_id, product_id, kind, delta_on_hand, delta_reserved, reservation_id, invoice_id, sale_id, note)
    values (r.account_id, r.product_id, 'sale', -r.qty, -r.qty, r.id, v.id, v_sale, 'Sale of ' || v.invoice_number);
  end loop;

  return v_sale;
end;
$$;

-- Records a payment. Reaching a zero balance marks the invoice paid and creates the sale.
create or replace function public.record_invoice_payment(
  p_invoice_id uuid, p_amount_kobo bigint, p_method public.payment_method,
  p_paid_on date default current_date, p_reference text default null, p_proof_path text default null
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.invoices%rowtype;
  v_paid bigint;
  v_id uuid;
begin
  v := private.lock_invoice(p_invoice_id);
  if v.status not in ('sent', 'partially_paid', 'overdue') then
    raise exception 'payments can only be recorded on an issued invoice' using errcode = '55000';
  end if;
  if p_amount_kobo is null or p_amount_kobo <= 0 then
    raise exception 'amount must be above zero' using errcode = '22023';
  end if;
  if p_amount_kobo > v.balance_kobo then
    raise exception 'amount is more than the balance of %', v.balance_kobo using errcode = '23514';
  end if;

  insert into public.invoice_payments (account_id, invoice_id, amount_kobo, method, paid_on, reference, proof_path)
  values (v.account_id, v.id, p_amount_kobo, p_method, p_paid_on, p_reference, p_proof_path)
  returning id into v_id;

  v_paid := v.amount_paid_kobo + p_amount_kobo;
  if v_paid = v.total_kobo then
    update public.invoices set amount_paid_kobo = v_paid, status = 'paid', paid_at = now() where id = v.id;
    perform private.create_sale_from_invoice(v.id);
  else
    update public.invoices set amount_paid_kobo = v_paid, status = 'partially_paid' where id = v.id;
  end if;
  return v_id;
end;
$$;

-- A customer with unpaid invoices cannot be archived.
create or replace function public.archive_customer(p_customer_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_account uuid;
begin
  select account_id into v_account from public.customers where id = p_customer_id;
  if v_account is null then
    raise exception 'customer not found' using errcode = 'P0002';
  end if;
  perform private.assert_business_member(v_account);
  if exists (select 1 from public.invoices
              where customer_id = p_customer_id and account_id = v_account
                and status in ('sent', 'partially_paid', 'overdue')) then
    raise exception 'this customer still has unpaid invoices' using errcode = '55000';
  end if;
  update public.customers set archived_at = now() where id = p_customer_id;
end;
$$;

revoke all on function private.next_doc_number(uuid, text) from public;
revoke all on function private.lock_invoice(uuid) from public;
revoke all on function private.create_sale_from_invoice(uuid) from public;
grant execute on function private.lock_invoice(uuid) to authenticated;
grant execute on function private.create_sale_from_invoice(uuid) to authenticated;

revoke all on function public.issue_invoice(uuid) from public, anon;
revoke all on function public.revert_invoice_to_draft(uuid) from public, anon;
revoke all on function public.cancel_invoice(uuid) from public, anon;
revoke all on function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) from public, anon;
revoke all on function public.archive_customer(uuid) from public, anon;
grant execute on function public.issue_invoice(uuid) to authenticated;
grant execute on function public.revert_invoice_to_draft(uuid) to authenticated;
grant execute on function public.cancel_invoice(uuid) to authenticated;
grant execute on function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) to authenticated;
grant execute on function public.archive_customer(uuid) to authenticated;

-- ======== 20261010004000_notifications_support_plans.sql ========
-- Uruvia 0007: notifications, support, plans and subscriptions, scheduled stock and invoice jobs.
-- Subscription payment goes through the wallet or a card provider, both on hold. Plans and status are ready.

-- ---------------------------------------------------------------- notifications

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  account_id uuid references public.accounts (id) on delete cascade,
  kind text not null,
  title text not null,
  body text,
  payload jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index notifications_user_idx on public.notifications (user_id, created_at desc);
create index notifications_account_idx on public.notifications (account_id);
-- one notification per kind and subject, so a job that runs twice cannot repeat itself
create unique index notifications_dedupe_uq on public.notifications (user_id, kind, (payload ->> 'ref'))
  where payload ? 'ref';

create table public.notification_preferences (
  user_id uuid not null references public.profiles (id) on delete cascade,
  kind text not null,
  push_enabled boolean not null default true,
  weekly_summary boolean not null default false,
  primary key (user_id, kind)
);

-- ---------------------------------------------------------------- support

create sequence public.support_ticket_seq;

create table public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  reference text not null unique default ('UVR-' || lpad(nextval('public.support_ticket_seq')::text, 6, '0')),
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  account_id uuid references public.accounts (id) on delete set null,
  category text not null,
  related_type text check (related_type in ('transaction', 'invoice')),
  related_id uuid,
  description text not null check (char_length(description) between 1 and 4000),
  attachment_paths text[] not null default '{}',
  status text not null default 'open' check (status in ('open', 'in_progress', 'resolved')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index support_tickets_user_idx on public.support_tickets (user_id, created_at desc);
create index support_tickets_account_idx on public.support_tickets (account_id);

create table public.support_messages (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.support_tickets (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null default auth.uid(),
  is_staff boolean not null default false,
  body text not null check (char_length(body) between 1 and 4000),
  created_at timestamptz not null default now()
);
create index support_messages_ticket_idx on public.support_messages (ticket_id, created_at);
create index support_messages_author_idx on public.support_messages (author_id);

create trigger support_tickets_set_updated_at before update on public.support_tickets
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------- plans and subscriptions

create table public.plans (
  code text primary key,
  account_type public.account_type not null,
  name text not null,
  price_kobo bigint not null check (price_kobo >= 0),
  price_usd_cents integer not null check (price_usd_cents >= 0),
  -- 'monthly' or 'yearly'. Not decided yet, so left empty.
  billing_period text check (billing_period in ('monthly', 'yearly')),
  grace_days integer check (grace_days >= 0)
);

insert into public.plans (code, account_type, name, price_kobo, price_usd_cents) values
  ('individual_pro', 'individual', 'Individual Pro', 500000, 500),
  ('business_pro', 'business', 'Business Pro', 1000000, 800);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  plan_code text not null references public.plans (code),
  status text not null default 'active' check (status in ('active', 'past_due', 'cancelled', 'expired')),
  current_period_end timestamptz,
  grace_until timestamptz,
  cancel_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index subscriptions_one_live_uq on public.subscriptions (account_id) where status in ('active', 'past_due');
create index subscriptions_plan_idx on public.subscriptions (plan_code);

create trigger subscriptions_set_updated_at before update on public.subscriptions
  for each row execute function private.set_updated_at();

-- True while the account has a paid plan (including the grace period after a failed renewal).
create or replace function private.is_pro(p_account_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.subscriptions s
     where s.account_id = p_account_id
       and (s.status = 'active' or (s.status = 'past_due' and coalesce(s.grace_until, now()) > now()))
       and (s.current_period_end is null or s.current_period_end > now() or s.status = 'past_due')
  );
$$;

revoke all on function private.is_pro(uuid) from public;
grant execute on function private.is_pro(uuid) to authenticated;

-- ---------------------------------------------------------------- RLS

alter table public.notifications enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.support_tickets enable row level security;
alter table public.support_messages enable row level security;
alter table public.plans enable row level security;
alter table public.subscriptions enable row level security;

create policy notifications_select_own on public.notifications for select to authenticated
  using ((select auth.uid()) = user_id);
create policy notifications_update_own on public.notifications for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy notification_prefs_all on public.notification_preferences for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy support_tickets_select_own on public.support_tickets for select to authenticated
  using ((select auth.uid()) = user_id);
create policy support_tickets_insert_own on public.support_tickets for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and status = 'open'
    and (account_id is null or private.is_account_member(account_id))
  );
-- users may only mark their own ticket as resolved
create policy support_tickets_resolve_own on public.support_tickets for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id and status = 'resolved');

create policy support_messages_select_own on public.support_messages for select to authenticated
  using (exists (select 1 from public.support_tickets t where t.id = ticket_id and t.user_id = (select auth.uid())));
create policy support_messages_insert_own on public.support_messages for insert to authenticated
  with check (
    author_id = (select auth.uid()) and is_staff = false
    and exists (select 1 from public.support_tickets t where t.id = ticket_id and t.user_id = (select auth.uid()))
  );

create policy plans_read on public.plans for select to authenticated using (true);
create policy subscriptions_select_member on public.subscriptions for select to authenticated
  using (private.is_account_member(account_id));

revoke all on public.notifications, public.notification_preferences, public.support_tickets,
  public.support_messages, public.plans, public.subscriptions from anon, authenticated;
revoke all on sequence public.support_ticket_seq from anon, authenticated;

grant select on public.notifications to authenticated;
grant update (read_at) on public.notifications to authenticated;
grant select, insert, update, delete on public.notification_preferences to authenticated;
grant select on public.support_tickets, public.support_messages, public.plans, public.subscriptions to authenticated;
grant insert (account_id, category, related_type, related_id, description, attachment_paths)
  on public.support_tickets to authenticated;
grant update (status) on public.support_tickets to authenticated;
grant insert (ticket_id, body) on public.support_messages to authenticated;
grant usage on sequence public.support_ticket_seq to authenticated;

-- ---------------------------------------------------------------- scheduled work (called by pg_cron, no signed-in user)

create or replace function private.notify_account_owners(
  p_account_id uuid, p_kind text, p_title text, p_body text, p_ref text, p_payload jsonb default '{}'::jsonb
) returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.notifications (user_id, account_id, kind, title, body, payload)
  select m.user_id, p_account_id, p_kind, p_title, p_body, p_payload || jsonb_build_object('ref', p_ref)
    from public.account_members m
   where m.account_id = p_account_id and m.role = 'owner'
  on conflict do nothing;
$$;

-- Day 8 warning, then release on day 10 with a second notice.
create or replace function private.run_reservation_jobs()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
begin
  for r in
    select s.id, s.account_id, s.invoice_id, i.invoice_number, p.name as product_name
      from public.stock_reservations s
      join public.products p on p.id = s.product_id and p.account_id = s.account_id
      left join public.invoices i on i.id = s.invoice_id and i.account_id = s.account_id
     where s.status = 'active' and s.day8_notified_at is null and s.reserved_at <= now() - interval '8 days'
  loop
    perform private.notify_account_owners(r.account_id, 'reservation_day8',
      'Stock reservation ends soon',
      coalesce(r.invoice_number, 'A booking') || ' holds ' || r.product_name || ' and will be released in 2 days.',
      'day8:' || r.id::text, jsonb_build_object('reservation_id', r.id, 'invoice_id', r.invoice_id));
    update public.stock_reservations set day8_notified_at = now() where id = r.id;
  end loop;

  for r in
    select s.id, s.account_id, s.invoice_id, i.invoice_number, p.name as product_name
      from public.stock_reservations s
      join public.products p on p.id = s.product_id and p.account_id = s.account_id
      left join public.invoices i on i.id = s.invoice_id and i.account_id = s.account_id
     where s.status = 'active' and s.expires_at <= now()
  loop
    perform private.release_reservation(r.id, '10 days passed without payment');
    perform private.notify_account_owners(r.account_id, 'reservation_expired',
      'Stock released',
      coalesce(r.invoice_number, 'A booking') || ' reached 10 days unpaid, so ' || r.product_name || ' was released.',
      'expired:' || r.id::text, jsonb_build_object('reservation_id', r.id, 'invoice_id', r.invoice_id));
    update public.stock_reservations set expiry_notified_at = now() where id = r.id;
  end loop;
end;
$$;

create or replace function private.run_invoice_overdue_job()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
begin
  for r in
    update public.invoices
       set status = 'overdue'
     where status in ('sent', 'partially_paid') and due_date < current_date
    returning id, account_id, invoice_number
  loop
    perform private.notify_account_owners(r.account_id, 'invoice_overdue', 'Invoice overdue',
      r.invoice_number || ' is past its due date.', 'overdue:' || r.id::text, jsonb_build_object('invoice_id', r.id));
  end loop;
end;
$$;

-- Low stock: fire once when Available falls to or below the threshold.
create or replace function private.low_stock_notify()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.low_stock_alert and new.qty_available <= new.low_stock_threshold
     and (old.qty_available is null or old.qty_available > old.low_stock_threshold) then
    perform private.notify_account_owners(new.account_id, 'low_stock', 'Low stock',
      new.name || ' is down to ' || new.qty_available || '.',
      'low:' || new.id::text || ':' || to_char(now(), 'YYYYMMDDHH24MISS'), jsonb_build_object('product_id', new.id));
  end if;
  return new;
end;
$$;
create trigger products_low_stock after update of qty_on_hand, qty_reserved on public.products
  for each row execute function private.low_stock_notify();

revoke all on function private.notify_account_owners(uuid, text, text, text, text, jsonb) from public;
revoke all on function private.run_reservation_jobs() from public;
revoke all on function private.run_invoice_overdue_job() from public;
revoke all on function private.low_stock_notify() from public;

-- Schedule with pg_cron where it is available (hosted Supabase). Skipped on plain Postgres.
do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron with schema pg_catalog;
    perform cron.schedule('uruvia-reservations', '0 * * * *', 'select private.run_reservation_jobs()');
    perform cron.schedule('uruvia-invoice-overdue', '10 0 * * *', 'select private.run_invoice_overdue_job()');
  end if;
end;
$$;

-- ======== 20261010011341_harden_public_rpcs.sql ========
-- Uruvia 0008: no SECURITY DEFINER function stays in the exposed public schema.
-- The privileged logic moves to the private schema (not reachable from the Data API).
-- Thin SECURITY INVOKER wrappers with the same names and arguments stay in public, so the app calls them unchanged.
-- Each privileged function still checks Business membership itself.

alter function public.adjust_product_stock(uuid, integer, text, text) set schema private;
alter function public.restock_product(uuid, integer, text) set schema private;
alter function public.archive_customer(uuid) set schema private;
alter function public.cancel_invoice(uuid) set schema private;
alter function public.issue_invoice(uuid) set schema private;
alter function public.revert_invoice_to_draft(uuid) set schema private;
alter function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) set schema private;

revoke all on function private.adjust_product_stock(uuid, integer, text, text) from public, anon;
revoke all on function private.restock_product(uuid, integer, text) from public, anon;
revoke all on function private.archive_customer(uuid) from public, anon;
revoke all on function private.cancel_invoice(uuid) from public, anon;
revoke all on function private.issue_invoice(uuid) from public, anon;
revoke all on function private.revert_invoice_to_draft(uuid) from public, anon;
revoke all on function private.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) from public, anon;

grant execute on function private.adjust_product_stock(uuid, integer, text, text) to authenticated;
grant execute on function private.restock_product(uuid, integer, text) to authenticated;
grant execute on function private.archive_customer(uuid) to authenticated;
grant execute on function private.cancel_invoice(uuid) to authenticated;
grant execute on function private.issue_invoice(uuid) to authenticated;
grant execute on function private.revert_invoice_to_draft(uuid) to authenticated;
grant execute on function private.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) to authenticated;

create or replace function public.adjust_product_stock(p_product_id uuid, p_delta integer, p_reason text, p_note text default null)
returns void language sql security invoker set search_path = ''
as $$ select private.adjust_product_stock(p_product_id, p_delta, p_reason, p_note); $$;

create or replace function public.restock_product(p_product_id uuid, p_qty integer, p_note text default null)
returns void language sql security invoker set search_path = ''
as $$ select private.restock_product(p_product_id, p_qty, p_note); $$;

create or replace function public.archive_customer(p_customer_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.archive_customer(p_customer_id); $$;

create or replace function public.cancel_invoice(p_invoice_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.cancel_invoice(p_invoice_id); $$;

create or replace function public.issue_invoice(p_invoice_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.issue_invoice(p_invoice_id); $$;

create or replace function public.revert_invoice_to_draft(p_invoice_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.revert_invoice_to_draft(p_invoice_id); $$;

create or replace function public.record_invoice_payment(
  p_invoice_id uuid, p_amount_kobo bigint, p_method public.payment_method,
  p_paid_on date default current_date, p_reference text default null, p_proof_path text default null
) returns uuid language sql security invoker set search_path = ''
as $$ select private.record_invoice_payment(p_invoice_id, p_amount_kobo, p_method, p_paid_on, p_reference, p_proof_path); $$;

revoke all on function public.adjust_product_stock(uuid, integer, text, text) from public, anon;
revoke all on function public.restock_product(uuid, integer, text) from public, anon;
revoke all on function public.archive_customer(uuid) from public, anon;
revoke all on function public.cancel_invoice(uuid) from public, anon;
revoke all on function public.issue_invoice(uuid) from public, anon;
revoke all on function public.revert_invoice_to_draft(uuid) from public, anon;
revoke all on function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) from public, anon;

grant execute on function public.adjust_product_stock(uuid, integer, text, text) to authenticated;
grant execute on function public.restock_product(uuid, integer, text) to authenticated;
grant execute on function public.archive_customer(uuid) to authenticated;
grant execute on function public.cancel_invoice(uuid) to authenticated;
grant execute on function public.issue_invoice(uuid) to authenticated;
grant execute on function public.revert_invoice_to_draft(uuid) to authenticated;
grant execute on function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) to authenticated;

-- Server-only tables: say so explicitly. Nobody signed in can read or write them from the app.
create policy doc_counters_no_client_access on public.doc_counters for all to authenticated
  using (false) with check (false);
create policy user_security_no_client_access on public.user_security for all to authenticated
  using (false) with check (false);
-- Uruvia 0009: helpers for sign-up and onboarding.
--   has_transaction_pin(): tells the app whether this user already set a transaction PIN (the hash itself is never readable).
--   create_business_account(): creates the business account and its profile in one transaction.
-- Privileged parts live in the private schema; the public wrappers are SECURITY INVOKER.

create or replace function private.has_txn_pin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_security
    where user_id = (select auth.uid()) and txn_pin_hash is not null
  );
$$;

revoke all on function private.has_txn_pin() from public, anon;
grant execute on function private.has_txn_pin() to authenticated;

create or replace function public.has_transaction_pin()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$ select private.has_txn_pin(); $$;

revoke all on function public.has_transaction_pin() from public, anon;
grant execute on function public.has_transaction_pin() to authenticated;

create or replace function public.create_business_account(
  p_name text,
  p_category text default null,
  p_address text default null,
  p_invoice_prefix text default 'INV',
  p_vat_rate_bps integer default 750,
  p_payment_details jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_id uuid;
begin
  v_id := public.create_account('business', p_name);

  insert into public.business_profiles
    (account_id, business_name, category, address, invoice_prefix, vat_rate_bps, payment_details)
  values
    (v_id, p_name, nullif(p_category, ''), nullif(p_address, ''),
     coalesce(nullif(p_invoice_prefix, ''), 'INV'), coalesce(p_vat_rate_bps, 750),
     coalesce(p_payment_details, '{}'::jsonb));

  return v_id;
end;
$$;

revoke all on function public.create_business_account(text, text, text, text, integer, jsonb) from public, anon;
grant execute on function public.create_business_account(text, text, text, text, integer, jsonb) to authenticated;
-- Uruvia 0010: one call that returns the numbers shown on the Home screen.
-- SECURITY INVOKER, so Row Level Security still decides what the caller can count.
-- "Today" and "this month" follow Nigerian time (Africa/Lagos).

create or replace function public.home_summary(p_account_id uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  with t as (select (now() at time zone 'Africa/Lagos')::date as today)
  select jsonb_build_object(
    'spent_this_month_kobo', coalesce((
      select sum(e.amount_kobo) from public.expenses e, t
      where e.account_id = p_account_id
        and (e.spent_at at time zone 'Africa/Lagos')::date >= date_trunc('month', t.today)::date), 0),
    'budget_total_kobo', coalesce((
      select sum(bp.amount_kobo) from public.budget_progress bp, t
      where bp.account_id = p_account_id and bp.starts_on <= t.today and bp.ends_on > t.today), 0),
    'budget_spent_kobo', coalesce((
      select sum(bp.spent_kobo) from public.budget_progress bp, t
      where bp.account_id = p_account_id and bp.starts_on <= t.today and bp.ends_on > t.today), 0),
    'budget_over_count', (
      select count(*) from public.budget_progress bp, t
      where bp.account_id = p_account_id and bp.starts_on <= t.today and bp.ends_on > t.today and bp.state = 'red'),
    'sales_today_kobo', coalesce((
      select sum(s.total_kobo) from public.sales s, t
      where s.account_id = p_account_id and s.reversed_at is null
        and (s.sold_at at time zone 'Africa/Lagos')::date = t.today), 0),
    'sales_month_kobo', coalesce((
      select sum(s.total_kobo) from public.sales s, t
      where s.account_id = p_account_id and s.reversed_at is null
        and (s.sold_at at time zone 'Africa/Lagos')::date >= date_trunc('month', t.today)::date), 0),
    'outstanding_kobo', coalesce((
      select sum(i.balance_kobo) from public.invoices i
      where i.account_id = p_account_id and i.status in ('sent', 'partially_paid', 'overdue')), 0),
    'overdue_count', (
      select count(*) from public.invoices i, t
      where i.account_id = p_account_id
        and (i.status = 'overdue' or (i.status in ('sent', 'partially_paid') and i.due_date < t.today))),
    'low_stock_count', (
      select count(*) from public.products p
      where p.account_id = p_account_id and p.archived_at is null
        and p.low_stock_alert and p.qty_available <= p.low_stock_threshold)
  );
$$;

revoke all on function public.home_summary(uuid) from public, anon;
grant execute on function public.home_summary(uuid) to authenticated;

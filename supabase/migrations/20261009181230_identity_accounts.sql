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

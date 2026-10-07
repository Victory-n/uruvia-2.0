 -- =====================================================================
-- Uruvia schema
-- Run in the Supabase SQL editor (or as a migration).
-- =====================================================================

-- ---------- Enums ----------
do $$ begin
  create type public.account_type as enum ('individual', 'business');
exception when duplicate_object then null; end $$;

-- ---------- Shared helpers ----------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------- profiles ----------
-- One row per auth user. Every user starts on the 'individual' account
-- and can later switch to 'business' by changing active_account_type.
create table if not exists public.profiles (
  id                   uuid primary key references auth.users (id) on delete cascade,
  first_name           text not null default '',
  last_name            text not null default '',
  email                text not null,
  phone                text,
  currency             text not null default 'NGN',
  active_account_type  public.account_type not null default 'individual',
  agreed_to_terms_at   timestamptz,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create unique index if not exists profiles_email_key on public.profiles (lower(email));

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---------- business_profiles ----------
-- Created when a user sets up a business account. A user may own one.
create table if not exists public.business_profiles (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null unique references public.profiles (id) on delete cascade,
  business_name  text not null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create trigger business_profiles_set_updated_at
  before update on public.business_profiles
  for each row execute function public.set_updated_at();

-- ---------- Auto-create profile on sign up ----------
-- Reads first_name / last_name / phone / agreed_to_terms from the
-- raw_user_meta_data passed by supabase.auth.signUp(data: {...}).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (
    id, first_name, last_name, email, phone,
    active_account_type, agreed_to_terms_at
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'first_name', ''),
    coalesce(new.raw_user_meta_data ->> 'last_name', ''),
    new.email,
    nullif(new.raw_user_meta_data ->> 'phone', ''),
    'individual',
    case when (new.raw_user_meta_data ->> 'agreed_to_terms') = 'true'
         then now() end
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Row Level Security ----------
alter table public.profiles          enable row level security;
alter table public.business_profiles enable row level security;

create policy "Users can read own profile"
  on public.profiles for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "Owners can read own business profile"
  on public.business_profiles for select
  to authenticated
  using ((select auth.uid()) = owner_id);

create policy "Owners can create own business profile"
  on public.business_profiles for insert
  to authenticated
  with check ((select auth.uid()) = owner_id);

create policy "Owners can update own business profile"
  on public.business_profiles for update
  to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

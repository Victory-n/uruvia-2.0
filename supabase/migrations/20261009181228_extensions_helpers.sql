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

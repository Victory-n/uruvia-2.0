-- Run this once in the Supabase SQL Editor (after 0001 to 0008).
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

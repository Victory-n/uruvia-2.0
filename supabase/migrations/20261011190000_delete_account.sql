-- 0016: Delete my account (Apple 5.1.1(v), Google Play account deletion).
-- The signed-in user deletes their own sign-in, profile, accounts and everything in them.

-- Rows a member created inside someone else's account must survive that member leaving.
alter table public.expenses alter column created_by drop not null;
alter table public.expenses drop constraint if exists expenses_created_by_fkey;
alter table public.expenses
  add constraint expenses_created_by_fkey foreign key (created_by) references public.profiles (id) on delete set null;

alter table public.stock_movements drop constraint if exists stock_movements_created_by_fkey;
alter table public.stock_movements
  add constraint stock_movements_created_by_fkey foreign key (created_by) references public.profiles (id) on delete set null;

alter table public.invoice_payments drop constraint if exists invoice_payments_recorded_by_fkey;
alter table public.invoice_payments
  add constraint invoice_payments_recorded_by_fkey foreign key (recorded_by) references public.profiles (id) on delete set null;

-- Deletes everything the user owns, in an order that satisfies the RESTRICT keys, then the sign-in itself.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_owned uuid[];
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;

  select coalesce(array_agg(id), '{}') into v_owned from public.accounts where owner_id = v_uid;

  -- A business with other people in it cannot vanish under them.
  if exists (
    select 1 from public.account_members m
    where m.account_id = any (v_owned) and m.user_id <> v_uid
  ) then
    raise exception 'Remove the other people from your business before deleting your account.'
      using errcode = 'P0001';
  end if;

  -- Children first, so no RESTRICT key is hit.
  delete from public.sale_items where account_id = any (v_owned);
  delete from public.sales where account_id = any (v_owned);
  delete from public.invoice_payments where account_id = any (v_owned);
  delete from public.invoice_items where account_id = any (v_owned);
  delete from public.invoices where account_id = any (v_owned);
  delete from public.customers where account_id = any (v_owned);
  delete from public.budgets where account_id = any (v_owned);
  delete from public.expenses where account_id = any (v_owned);
  delete from public.expense_categories where account_id = any (v_owned);
  delete from public.products where account_id = any (v_owned);
  delete from public.product_categories where account_id = any (v_owned);

  -- Removing the sign-in cascades to profile, accounts, memberships, devices, PIN, notifications, tickets, subscriptions.
  delete from auth.users where id = v_uid;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

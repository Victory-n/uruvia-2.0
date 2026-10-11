-- 0014: Invoices and customers for Individual accounts too.
-- Budgets, expenses and savings already work for both account types (they only check membership).
-- Inventory and stock stay Business-only. Invoice lines for Individuals are custom items (no product).

create or replace function private.assert_account_member(p_account_id uuid)
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
  if not private.is_account_member(p_account_id) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
end;
$$;
revoke all on function private.assert_account_member(uuid) from public;
grant execute on function private.assert_account_member(uuid) to authenticated;

-- Row policies: members of any account type.
drop policy if exists customers_select on public.customers;
drop policy if exists customers_insert on public.customers;
drop policy if exists customers_update on public.customers;
drop policy if exists invoices_select on public.invoices;
drop policy if exists invoices_insert on public.invoices;
drop policy if exists invoices_update_draft on public.invoices;
drop policy if exists invoice_items_select on public.invoice_items;
drop policy if exists invoice_items_insert on public.invoice_items;
drop policy if exists invoice_items_update on public.invoice_items;
drop policy if exists invoice_items_delete on public.invoice_items;
drop policy if exists invoice_payments_select on public.invoice_payments;
drop policy if exists sales_select on public.sales;
drop policy if exists sale_items_select on public.sale_items;

create policy customers_select on public.customers for select to authenticated
  using (private.is_account_member(account_id));
create policy customers_insert on public.customers for insert to authenticated
  with check (private.is_account_member(account_id));
create policy customers_update on public.customers for update to authenticated
  using (private.is_account_member(account_id)) with check (private.is_account_member(account_id));

create policy invoices_select on public.invoices for select to authenticated
  using (private.is_account_member(account_id));
create policy invoices_insert on public.invoices for insert to authenticated
  with check (private.is_account_member(account_id));
create policy invoices_update_draft on public.invoices for update to authenticated
  using (private.is_account_member(account_id) and status = 'draft')
  with check (private.is_account_member(account_id));

create policy invoice_items_select on public.invoice_items for select to authenticated
  using (private.is_account_member(account_id));
create policy invoice_items_insert on public.invoice_items for insert to authenticated
  with check (private.is_account_member(account_id));
create policy invoice_items_update on public.invoice_items for update to authenticated
  using (private.is_account_member(account_id)) with check (private.is_account_member(account_id));
create policy invoice_items_delete on public.invoice_items for delete to authenticated
  using (private.is_account_member(account_id));

create policy invoice_payments_select on public.invoice_payments for select to authenticated
  using (private.is_account_member(account_id));
create policy sales_select on public.sales for select to authenticated
  using (private.is_account_member(account_id));
create policy sale_items_select on public.sale_items for select to authenticated
  using (private.is_account_member(account_id));

-- Functions that guarded with the Business check now guard with plain membership.
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
  perform private.assert_account_member(v.account_id);
  return v;
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
  perform private.assert_account_member(v.account_id);

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
  perform private.assert_account_member(v_account);
  if exists (select 1 from public.invoices
              where customer_id = p_customer_id and account_id = v_account
                and status in ('sent', 'partially_paid', 'overdue')) then
    raise exception 'this customer still has unpaid invoices' using errcode = '55000';
  end if;
  update public.customers set archived_at = now() where id = p_customer_id;
end;
$$;

-- Individuals have no products, so a product line is refused for them.
create or replace function private.invoice_items_individual_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.product_id is not null and not private.is_business_account(new.account_id) then
    raise exception 'products are only available on Business accounts' using errcode = '23514';
  end if;
  return new;
end;
$$;
drop trigger if exists invoice_items_individual_guard on public.invoice_items;
create trigger invoice_items_individual_guard before insert or update of product_id on public.invoice_items
  for each row execute function private.invoice_items_individual_guard();

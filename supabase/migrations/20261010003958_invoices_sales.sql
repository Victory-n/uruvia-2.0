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

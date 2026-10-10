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

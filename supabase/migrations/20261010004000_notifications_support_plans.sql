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

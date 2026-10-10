-- Run this once in the Supabase SQL Editor (after 0001 to 0011).
-- Uruvia 0012: notify the account owners when a restock reminder falls due.
-- Runs hourly. Each reminder notifies once (the notification is de-duplicated) and is then marked done.

create or replace function private.run_restock_reminder_job()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
begin
  for r in
    select rr.id, rr.account_id, rr.product_id, p.name as product_name
      from public.restock_reminders rr
      join public.products p on p.id = rr.product_id and p.account_id = rr.account_id
     where rr.done_at is null and rr.remind_at <= now()
  loop
    perform private.notify_account_owners(r.account_id, 'restock_reminder',
      'Time to restock',
      'You asked to be reminded to restock ' || r.product_name || '.',
      'restock:' || r.id::text,
      jsonb_build_object('product_id', r.product_id));
    update public.restock_reminders set done_at = now() where id = r.id;
  end loop;
end;
$$;

revoke all on function private.run_restock_reminder_job() from public, anon, authenticated;

do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron with schema pg_catalog;
    perform cron.schedule('uruvia-restock-reminders', '15 * * * *', 'select private.run_restock_reminder_job()');
  end if;
end
$$;

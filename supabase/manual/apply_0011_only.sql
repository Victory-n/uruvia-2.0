-- Run this once in the Supabase SQL Editor (after 0001 to 0010).
-- Uruvia 0011: budget alerts and budget renewals.
--   * When an expense pushes a budget to 80% or 100%, the account owners get one notification per budget period.
--   * A daily job creates the next period for budgets set to repeat.
-- Rollover of unspent money is NOT applied yet (the rule is not decided); a repeating budget keeps the same amount.

create or replace function private.fmt_naira(p_kobo bigint)
returns text
language sql
immutable
set search_path = ''
as $$ select '₦' || to_char(p_kobo / 100, 'FM999,999,999,999,990'); $$;

create or replace function private.check_budget_alerts()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  b record;
  v_end date;
  v_spent bigint;
  v_cat text;
begin
  if new.category_id is null then
    return new;
  end if;

  select name into v_cat from public.expense_categories where id = new.category_id;

  for b in
    select * from public.budgets
     where account_id = new.account_id and category_id = new.category_id and not paused
  loop
    v_end := (case b.period when 'monthly' then b.starts_on + interval '1 month'
                            else b.starts_on + interval '1 year' end)::date;
    if new.spent_at < b.starts_on or new.spent_at >= v_end then
      continue;
    end if;

    select coalesce(sum(e.amount_kobo), 0) into v_spent
      from public.expenses e
     where e.account_id = b.account_id and e.category_id = b.category_id
       and e.spent_at >= b.starts_on and e.spent_at < v_end;

    if v_spent >= b.amount_kobo and b.alert_100 then
      perform private.notify_account_owners(b.account_id, 'budget_100',
        v_cat || ' budget used up',
        'You have spent ' || private.fmt_naira(v_spent) || ' of your ' || private.fmt_naira(b.amount_kobo) || ' budget.',
        'budget100:' || b.id::text || ':' || b.starts_on::text,
        jsonb_build_object('budget_id', b.id));
    elsif v_spent * 5 >= b.amount_kobo * 4 and b.alert_80 then
      perform private.notify_account_owners(b.account_id, 'budget_80',
        v_cat || ' budget almost used',
        'You have used 80% of your ' || private.fmt_naira(b.amount_kobo) || ' budget.',
        'budget80:' || b.id::text || ':' || b.starts_on::text,
        jsonb_build_object('budget_id', b.id));
    end if;
  end loop;

  return new;
end;
$$;

create trigger expenses_budget_alerts
  after insert or update of amount_kobo, category_id, spent_at on public.expenses
  for each row execute function private.check_budget_alerts();

-- Next period for budgets that repeat. Fills any gap up to today.
create or replace function private.run_budget_renewals()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
  v_today date := (now() at time zone 'Africa/Lagos')::date;
  v_next date;
begin
  for r in
    select distinct on (account_id, category_id, period) *
      from public.budgets
     where repeat and not paused
     order by account_id, category_id, period, starts_on desc
  loop
    v_next := r.starts_on;
    loop
      v_next := (case r.period when 'monthly' then v_next + interval '1 month'
                               else v_next + interval '1 year' end)::date;
      exit when v_next > v_today;
      insert into public.budgets (account_id, category_id, amount_kobo, period, starts_on, repeat, rollover, alert_80, alert_100)
      values (r.account_id, r.category_id, r.amount_kobo, r.period, v_next, r.repeat, r.rollover, r.alert_80, r.alert_100)
      on conflict do nothing;
    end loop;
  end loop;
end;
$$;

revoke all on function private.run_budget_renewals() from public, anon, authenticated;

do $$
begin
  if exists (select 1 from pg_available_extensions where name = 'pg_cron') then
    create extension if not exists pg_cron with schema pg_catalog;
    -- 23:05 UTC = 00:05 in Nigeria
    perform cron.schedule('uruvia-budget-renewals', '5 23 * * *', 'select private.run_budget_renewals()');
  end if;
end
$$;

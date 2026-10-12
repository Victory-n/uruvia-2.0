-- 0019: Budget rollover and "change from next period".
--   rollover: when on, money left unspent in a period is added to the next period's limit.
--   next_amount_kobo: an amount that takes effect when the next period starts (instead of now).
-- The limit shown in the app is amount_kobo (what the person set) plus carry_kobo (carried over).

alter table public.budgets add column if not exists carry_kobo bigint not null default 0 check (carry_kobo >= 0);
alter table public.budgets add column if not exists next_amount_kobo bigint check (next_amount_kobo is null or next_amount_kobo > 0);

-- Same columns as before, in the same order, with the limit now including the carry-over. New columns come last.
create or replace view public.budget_progress with (security_invoker = true) as
select
  b.id as budget_id,
  b.account_id,
  b.category_id,
  b.amount_kobo + b.carry_kobo as amount_kobo,
  b.period,
  b.starts_on,
  (case b.period when 'monthly' then b.starts_on + interval '1 month'
                 else b.starts_on + interval '1 year' end)::date as ends_on,
  coalesce(s.spent_kobo, 0) as spent_kobo,
  b.amount_kobo + b.carry_kobo - coalesce(s.spent_kobo, 0) as remaining_kobo,
  case
    when coalesce(s.spent_kobo, 0) > b.amount_kobo + b.carry_kobo then 'red'
    when coalesce(s.spent_kobo, 0) * 100 >= (b.amount_kobo + b.carry_kobo) * 80 then 'amber'
    else 'green'
  end as state,
  b.amount_kobo as base_kobo,
  b.carry_kobo,
  b.next_amount_kobo,
  b.rollover
from public.budgets b
left join lateral (
  select sum(e.amount_kobo)::bigint as spent_kobo
  from public.expenses e
  where e.account_id = b.account_id
    and e.category_id = b.category_id
    and e.spent_at >= b.starts_on
    and e.spent_at < (case b.period when 'monthly' then b.starts_on + interval '1 month'
                                    else b.starts_on + interval '1 year' end)
) s on true;

-- Alerts compare spending with the full limit, carry-over included.
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
  v_limit bigint;
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
    v_limit := b.amount_kobo + b.carry_kobo;

    select coalesce(sum(e.amount_kobo), 0) into v_spent
      from public.expenses e
     where e.account_id = b.account_id and e.category_id = b.category_id
       and e.spent_at >= b.starts_on and e.spent_at < v_end;

    if v_spent >= v_limit and b.alert_100 then
      perform private.notify_account_owners(b.account_id, 'budget_100',
        v_cat || ' budget used up',
        'You have spent ' || private.fmt_naira(v_spent) || ' of your ' || private.fmt_naira(v_limit) || ' budget.',
        'budget100:' || b.id::text || ':' || b.starts_on::text,
        jsonb_build_object('budget_id', b.id));
    elsif v_spent * 5 >= v_limit * 4 and b.alert_80 then
      perform private.notify_account_owners(b.account_id, 'budget_80',
        v_cat || ' budget almost used',
        'You have used 80% of your ' || private.fmt_naira(v_limit) || ' budget.',
        'budget80:' || b.id::text || ':' || b.starts_on::text,
        jsonb_build_object('budget_id', b.id));
    end if;
  end loop;

  return new;
end;
$$;

-- Next period for budgets that repeat. Fills any gap up to today.
-- A pending next_amount_kobo becomes the new amount. With rollover on, what was left unspent is carried over.
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
  v_prev_start date;
  v_prev_limit bigint;
  v_prev_end date;
  v_spent bigint;
  v_base bigint;
  v_carry bigint;
begin
  for r in
    select distinct on (account_id, category_id, period) *
      from public.budgets
     where repeat and not paused
     order by account_id, category_id, period, starts_on desc
  loop
    v_prev_start := r.starts_on;
    v_prev_limit := r.amount_kobo + r.carry_kobo;
    v_base := coalesce(r.next_amount_kobo, r.amount_kobo);
    v_next := r.starts_on;
    loop
      v_next := (case r.period when 'monthly' then v_next + interval '1 month'
                               else v_next + interval '1 year' end)::date;
      exit when v_next > v_today;

      select coalesce(sum(e.amount_kobo), 0) into v_spent
        from public.expenses e
       where e.account_id = r.account_id and e.category_id = r.category_id
         and e.spent_at >= v_prev_start and e.spent_at < v_next;

      v_carry := case when r.rollover then greatest(0, v_prev_limit - v_spent) else 0 end;

      insert into public.budgets (account_id, category_id, amount_kobo, carry_kobo, period, starts_on, repeat, rollover, alert_80, alert_100)
      values (r.account_id, r.category_id, v_base, v_carry, r.period, v_next, r.repeat, r.rollover, r.alert_80, r.alert_100)
      on conflict do nothing;

      v_prev_start := v_next;
      v_prev_limit := v_base + v_carry;
    end loop;
  end loop;
end;
$$;

revoke all on function private.run_budget_renewals() from public, anon, authenticated;

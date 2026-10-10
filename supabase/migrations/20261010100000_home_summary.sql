-- Uruvia 0010: one call that returns the numbers shown on the Home screen.
-- SECURITY INVOKER, so Row Level Security still decides what the caller can count.
-- "Today" and "this month" follow Nigerian time (Africa/Lagos).

create or replace function public.home_summary(p_account_id uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  with t as (select (now() at time zone 'Africa/Lagos')::date as today)
  select jsonb_build_object(
    'spent_this_month_kobo', coalesce((
      select sum(e.amount_kobo) from public.expenses e, t
      where e.account_id = p_account_id
        and (e.spent_at at time zone 'Africa/Lagos')::date >= date_trunc('month', t.today)::date), 0),
    'budget_total_kobo', coalesce((
      select sum(bp.amount_kobo) from public.budget_progress bp, t
      where bp.account_id = p_account_id and bp.starts_on <= t.today and bp.ends_on > t.today), 0),
    'budget_spent_kobo', coalesce((
      select sum(bp.spent_kobo) from public.budget_progress bp, t
      where bp.account_id = p_account_id and bp.starts_on <= t.today and bp.ends_on > t.today), 0),
    'budget_over_count', (
      select count(*) from public.budget_progress bp, t
      where bp.account_id = p_account_id and bp.starts_on <= t.today and bp.ends_on > t.today and bp.state = 'red'),
    'sales_today_kobo', coalesce((
      select sum(s.total_kobo) from public.sales s, t
      where s.account_id = p_account_id and s.reversed_at is null
        and (s.sold_at at time zone 'Africa/Lagos')::date = t.today), 0),
    'sales_month_kobo', coalesce((
      select sum(s.total_kobo) from public.sales s, t
      where s.account_id = p_account_id and s.reversed_at is null
        and (s.sold_at at time zone 'Africa/Lagos')::date >= date_trunc('month', t.today)::date), 0),
    'outstanding_kobo', coalesce((
      select sum(i.balance_kobo) from public.invoices i
      where i.account_id = p_account_id and i.status in ('sent', 'partially_paid', 'overdue')), 0),
    'overdue_count', (
      select count(*) from public.invoices i, t
      where i.account_id = p_account_id
        and (i.status = 'overdue' or (i.status in ('sent', 'partially_paid') and i.due_date < t.today))),
    'low_stock_count', (
      select count(*) from public.products p
      where p.account_id = p_account_id and p.archived_at is null
        and p.low_stock_alert and p.qty_available <= p.low_stock_threshold)
  );
$$;

revoke all on function public.home_summary(uuid) from public, anon;
grant execute on function public.home_summary(uuid) to authenticated;

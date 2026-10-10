-- Run this ONLY if you already ran migrations 0001 to 0007 (the earlier apply_all.sql).
-- It is migration 0008, run once.
-- Uruvia 0008: no SECURITY DEFINER function stays in the exposed public schema.
-- The privileged logic moves to the private schema (not reachable from the Data API).
-- Thin SECURITY INVOKER wrappers with the same names and arguments stay in public, so the app calls them unchanged.
-- Each privileged function still checks Business membership itself.

alter function public.adjust_product_stock(uuid, integer, text, text) set schema private;
alter function public.restock_product(uuid, integer, text) set schema private;
alter function public.archive_customer(uuid) set schema private;
alter function public.cancel_invoice(uuid) set schema private;
alter function public.issue_invoice(uuid) set schema private;
alter function public.revert_invoice_to_draft(uuid) set schema private;
alter function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) set schema private;

revoke all on function private.adjust_product_stock(uuid, integer, text, text) from public, anon;
revoke all on function private.restock_product(uuid, integer, text) from public, anon;
revoke all on function private.archive_customer(uuid) from public, anon;
revoke all on function private.cancel_invoice(uuid) from public, anon;
revoke all on function private.issue_invoice(uuid) from public, anon;
revoke all on function private.revert_invoice_to_draft(uuid) from public, anon;
revoke all on function private.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) from public, anon;

grant execute on function private.adjust_product_stock(uuid, integer, text, text) to authenticated;
grant execute on function private.restock_product(uuid, integer, text) to authenticated;
grant execute on function private.archive_customer(uuid) to authenticated;
grant execute on function private.cancel_invoice(uuid) to authenticated;
grant execute on function private.issue_invoice(uuid) to authenticated;
grant execute on function private.revert_invoice_to_draft(uuid) to authenticated;
grant execute on function private.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) to authenticated;

create or replace function public.adjust_product_stock(p_product_id uuid, p_delta integer, p_reason text, p_note text default null)
returns void language sql security invoker set search_path = ''
as $$ select private.adjust_product_stock(p_product_id, p_delta, p_reason, p_note); $$;

create or replace function public.restock_product(p_product_id uuid, p_qty integer, p_note text default null)
returns void language sql security invoker set search_path = ''
as $$ select private.restock_product(p_product_id, p_qty, p_note); $$;

create or replace function public.archive_customer(p_customer_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.archive_customer(p_customer_id); $$;

create or replace function public.cancel_invoice(p_invoice_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.cancel_invoice(p_invoice_id); $$;

create or replace function public.issue_invoice(p_invoice_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.issue_invoice(p_invoice_id); $$;

create or replace function public.revert_invoice_to_draft(p_invoice_id uuid)
returns void language sql security invoker set search_path = ''
as $$ select private.revert_invoice_to_draft(p_invoice_id); $$;

create or replace function public.record_invoice_payment(
  p_invoice_id uuid, p_amount_kobo bigint, p_method public.payment_method,
  p_paid_on date default current_date, p_reference text default null, p_proof_path text default null
) returns uuid language sql security invoker set search_path = ''
as $$ select private.record_invoice_payment(p_invoice_id, p_amount_kobo, p_method, p_paid_on, p_reference, p_proof_path); $$;

revoke all on function public.adjust_product_stock(uuid, integer, text, text) from public, anon;
revoke all on function public.restock_product(uuid, integer, text) from public, anon;
revoke all on function public.archive_customer(uuid) from public, anon;
revoke all on function public.cancel_invoice(uuid) from public, anon;
revoke all on function public.issue_invoice(uuid) from public, anon;
revoke all on function public.revert_invoice_to_draft(uuid) from public, anon;
revoke all on function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) from public, anon;

grant execute on function public.adjust_product_stock(uuid, integer, text, text) to authenticated;
grant execute on function public.restock_product(uuid, integer, text) to authenticated;
grant execute on function public.archive_customer(uuid) to authenticated;
grant execute on function public.cancel_invoice(uuid) to authenticated;
grant execute on function public.issue_invoice(uuid) to authenticated;
grant execute on function public.revert_invoice_to_draft(uuid) to authenticated;
grant execute on function public.record_invoice_payment(uuid, bigint, public.payment_method, date, text, text) to authenticated;

-- Server-only tables: say so explicitly. Nobody signed in can read or write them from the app.
create policy doc_counters_no_client_access on public.doc_counters for all to authenticated
  using (false) with check (false);
create policy user_security_no_client_access on public.user_security for all to authenticated
  using (false) with check (false);

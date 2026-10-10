-- Run this once in the Supabase SQL Editor (after 0001 to 0012).
-- Uruvia 0013: create or update a draft invoice and its items in one step, so a failed save never leaves half an invoice.
-- Runs as the signed-in user (SECURITY INVOKER): the table policies and column grants still decide what is allowed.
-- Pass p_invoice_id null to create. Only drafts can be changed.

create or replace function public.save_invoice_draft(
  p_account_id uuid,
  p_invoice_id uuid,
  p_customer_id uuid,
  p_issue_date date,
  p_due_date date,
  p_discount_kobo bigint,
  p_vat_enabled boolean,
  p_charges_kobo bigint,
  p_notes text,
  p_terms text,
  p_items jsonb
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_id uuid := p_invoice_id;
  it jsonb;
  n integer := 0;
begin
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'add at least one item first' using errcode = '23514';
  end if;

  if v_id is null then
    insert into public.invoices (account_id, customer_id, issue_date, due_date, discount_kobo, vat_enabled, charges_kobo, notes, terms)
    values (p_account_id, p_customer_id, p_issue_date, p_due_date, coalesce(p_discount_kobo, 0), coalesce(p_vat_enabled, false),
            coalesce(p_charges_kobo, 0), nullif(trim(p_notes), ''), nullif(trim(p_terms), ''))
    returning id into v_id;
  else
    update public.invoices
       set customer_id = p_customer_id, issue_date = p_issue_date, due_date = p_due_date,
           discount_kobo = coalesce(p_discount_kobo, 0), vat_enabled = coalesce(p_vat_enabled, false),
           charges_kobo = coalesce(p_charges_kobo, 0), notes = nullif(trim(p_notes), ''), terms = nullif(trim(p_terms), '')
     where id = v_id and account_id = p_account_id and status = 'draft';
    if not found then
      raise exception 'this invoice can no longer be edited' using errcode = '55000';
    end if;
    delete from public.invoice_items where invoice_id = v_id and account_id = p_account_id;
  end if;

  for it in select * from jsonb_array_elements(p_items) loop
    n := n + 1;
    insert into public.invoice_items (account_id, invoice_id, product_id, description, qty, unit_price_kobo, sort_order)
    values (p_account_id, v_id, nullif(it ->> 'product_id', '')::uuid, it ->> 'description',
            (it ->> 'qty')::integer, (it ->> 'unit_price_kobo')::bigint, n);
  end loop;

  return v_id;
end;
$$;

revoke all on function public.save_invoice_draft(uuid, uuid, uuid, date, date, bigint, boolean, bigint, text, text, jsonb) from public, anon;
grant execute on function public.save_invoice_draft(uuid, uuid, uuid, date, date, bigint, boolean, bigint, text, text, jsonb) to authenticated;

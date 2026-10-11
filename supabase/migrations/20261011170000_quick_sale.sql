-- 0015: Quick sale. A direct sale at the counter: no invoice, paid at once.
-- Stock leaves the shelf immediately. Business accounts only.

alter table public.sales add column if not exists payment_method public.payment_method;
alter table public.sales add column if not exists note text;

-- p_items: [{ "product_id": uuid|null, "description": text, "qty": int, "unit_price_kobo": bigint }, ...]
create or replace function public.record_quick_sale(
  p_account_id uuid,
  p_customer_id uuid,
  p_method public.payment_method,
  p_note text,
  p_items jsonb
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_sale uuid;
  v_total bigint := 0;
  v_cost bigint := 0;
  it jsonb;
  v_prod public.products%rowtype;
  v_pid uuid;
  v_qty integer;
  v_price bigint;
  v_desc text;
  v_unit_cost bigint;
begin
  perform private.assert_business_member(p_account_id);

  if p_method = 'wallet' then
    raise exception 'wallet payments are not available yet' using errcode = '22023';
  end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'add at least one item' using errcode = '22023';
  end if;
  if jsonb_array_length(p_items) > 50 then
    raise exception 'too many items' using errcode = '22023';
  end if;

  insert into public.sales (account_id, sale_number, customer_id, total_kobo, cost_kobo, payment_method, note)
  values (p_account_id, 'SAL-' || lpad(private.next_doc_number(p_account_id, 'sale')::text, 5, '0'),
          p_customer_id, 0, 0, p_method, nullif(trim(coalesce(p_note, '')), ''))
  returning id into v_sale;

  for it in select * from jsonb_array_elements(p_items) loop
    v_pid := nullif(it ->> 'product_id', '')::uuid;
    v_qty := (it ->> 'qty')::integer;
    v_price := (it ->> 'unit_price_kobo')::bigint;
    v_desc := nullif(trim(coalesce(it ->> 'description', '')), '');
    v_unit_cost := 0;

    if v_qty is null or v_qty <= 0 then
      raise exception 'quantity must be positive' using errcode = '22023';
    end if;
    if v_price is null or v_price < 0 then
      raise exception 'price cannot be negative' using errcode = '22023';
    end if;

    if v_pid is not null then
      select * into v_prod from public.products
       where id = v_pid and account_id = p_account_id for update;
      if not found then
        raise exception 'product not found' using errcode = 'P0002';
      end if;
      if v_qty > v_prod.qty_available then
        raise exception 'Only % available for %', v_prod.qty_available, v_prod.name using errcode = '23514';
      end if;
      update public.products set qty_on_hand = qty_on_hand - v_qty where id = v_pid;
      insert into public.stock_movements (account_id, product_id, kind, delta_on_hand, sale_id, note)
      values (p_account_id, v_pid, 'sale', -v_qty, v_sale, 'Quick sale');
      v_unit_cost := v_prod.cost_kobo;
      v_desc := coalesce(v_desc, v_prod.name);
    end if;

    if v_desc is null then
      raise exception 'each item needs a description' using errcode = '22023';
    end if;

    insert into public.sale_items (account_id, sale_id, product_id, description, qty, unit_price_kobo, unit_cost_kobo)
    values (p_account_id, v_sale, v_pid, v_desc, v_qty, v_price, v_unit_cost);

    v_total := v_total + v_qty * v_price;
    v_cost := v_cost + v_qty * v_unit_cost;
  end loop;

  update public.sales set total_kobo = v_total, cost_kobo = v_cost where id = v_sale;
  return v_sale;
end;
$$;

revoke all on function public.record_quick_sale(uuid, uuid, public.payment_method, text, jsonb) from public, anon;
grant execute on function public.record_quick_sale(uuid, uuid, public.payment_method, text, jsonb) to authenticated;

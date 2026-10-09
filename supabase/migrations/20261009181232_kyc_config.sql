-- Uruvia 0003: KYC tiers (config), submissions, documents, private storage bucket.
-- Limits are left empty on purpose: they come from the partner bank and regulator and are still to be confirmed.

create table public.kyc_tiers (
  tier smallint primary key check (tier between 1 and 3),
  name text not null,
  requirements text not null,
  -- to be confirmed with the partner bank; null means "not set yet"
  daily_send_limit_kobo bigint check (daily_send_limit_kobo is null or daily_send_limit_kobo >= 0),
  wallet_balance_cap_kobo bigint check (wallet_balance_cap_kobo is null or wallet_balance_cap_kobo >= 0),
  savings_cap_kobo bigint check (savings_cap_kobo is null or savings_cap_kobo >= 0),
  allows_group_payout boolean not null default false,
  is_provisional boolean not null default true
);

insert into public.kyc_tiers (tier, name, requirements, allows_group_payout) values
  (1, 'Basic',    'Verified phone and email', false),
  (2, 'Verified', 'BVN and selfie', false),
  (3, 'Full',     'NIN or a government ID and proof of address', true);

create table public.kyc_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  kind public.kyc_kind not null default 'tier',
  -- for kind = 'tier': which tier the user is applying for
  tier_target smallint references public.kyc_tiers (tier),
  -- for kind = 'business': the business account the add-on is for
  account_id uuid references public.accounts (id) on delete cascade,
  status public.kyc_status not null default 'pending',
  -- the one clear reason shown when action is needed
  reason text,
  provider_ref text,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  check (
    (kind = 'tier' and tier_target between 2 and 3 and account_id is null)
    or (kind = 'business' and account_id is not null and tier_target is null)
  )
);
create index kyc_submissions_user_id_idx on public.kyc_submissions (user_id);
create index kyc_submissions_account_id_idx on public.kyc_submissions (account_id);

create table public.kyc_documents (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.kyc_submissions (id) on delete cascade,
  doc_type text not null check (doc_type in (
    'id_front', 'id_back', 'selfie', 'proof_of_address', 'cac_certificate', 'director_id'
  )),
  storage_path text not null,
  created_at timestamptz not null default now()
);
create index kyc_documents_submission_id_idx on public.kyc_documents (submission_id);

alter table public.kyc_tiers enable row level security;
alter table public.kyc_submissions enable row level security;
alter table public.kyc_documents enable row level security;

create policy kyc_tiers_read on public.kyc_tiers for select to authenticated using (true);

create policy kyc_submissions_select_own on public.kyc_submissions for select to authenticated
  using ((select auth.uid()) = user_id);

-- A user can only start a pending check for themselves. Approval, rejection and tier changes are server-only.
create policy kyc_submissions_insert_own on public.kyc_submissions for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and status = 'pending'
    and reason is null
    and provider_ref is null
    and reviewed_at is null
    and (account_id is null or private.is_account_owner(account_id))
  );

create policy kyc_documents_select_own on public.kyc_documents for select to authenticated
  using (exists (
    select 1 from public.kyc_submissions s
    where s.id = submission_id and s.user_id = (select auth.uid())
  ));

create policy kyc_documents_insert_own on public.kyc_documents for insert to authenticated
  with check (exists (
    select 1 from public.kyc_submissions s
    where s.id = submission_id and s.user_id = (select auth.uid()) and s.status in ('pending', 'action_needed')
  ));

revoke all on public.kyc_tiers, public.kyc_submissions, public.kyc_documents from anon, authenticated;
grant select on public.kyc_tiers to authenticated;
grant select, insert on public.kyc_submissions to authenticated;
grant select, insert on public.kyc_documents to authenticated;

-- ---------------------------------------------------------------- private bucket for ID documents
-- Path convention: {user_id}/{file}. Owner can add and read their own files. No update, no delete from the app.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('kyc', 'kyc', false, 10485760, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
on conflict (id) do nothing;

create policy kyc_objects_insert_own on storage.objects for insert to authenticated
  with check (bucket_id = 'kyc' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy kyc_objects_select_own on storage.objects for select to authenticated
  using (bucket_id = 'kyc' and (storage.foldername(name))[1] = (select auth.uid())::text);

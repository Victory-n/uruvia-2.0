
-- Edited from the Supabase dashboard (Table editor > app_config). One row only.

create table if not exists public.app_config (
  id smallint primary key default 1 check (id = 1),
  min_version_android text not null default '0.0.0',
  min_version_ios text not null default '0.0.0',
  maintenance boolean not null default false,
  maintenance_message text,
  store_url_android text,
  store_url_ios text,
  updated_at timestamptz not null default now()
);

insert into public.app_config (id) values (1) on conflict (id) do nothing;

alter table public.app_config enable row level security;

drop policy if exists app_config_read on public.app_config;
create policy app_config_read on public.app_config for select to anon, authenticated using (true);

grant select on public.app_config to anon, authenticated;

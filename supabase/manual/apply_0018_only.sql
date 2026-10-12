
--   account-files: {account_id}/products|logo|receipts|proofs/{file}   readable and writable by members of that account
--   avatars:       {user_id}/{file}                                    readable and writable by that user only
-- Photos are shown through short-lived signed links, never public URLs.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('account-files', 'account-files', false, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('avatars', 'avatars', false, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- True when the first folder of the path is an account the signed-in user belongs to.
create or replace function private.can_use_account_file(p_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_account uuid;
begin
  begin
    v_account := ((storage.foldername(p_name))[1])::uuid;
  exception when others then
    return false;
  end;
  return private.is_account_member(v_account);
end;
$$;

revoke all on function private.can_use_account_file(text) from public;
grant execute on function private.can_use_account_file(text) to authenticated;

drop policy if exists account_files_select on storage.objects;
drop policy if exists account_files_insert on storage.objects;
drop policy if exists account_files_update on storage.objects;
drop policy if exists account_files_delete on storage.objects;
create policy account_files_select on storage.objects for select to authenticated
  using (bucket_id = 'account-files' and private.can_use_account_file(name));
create policy account_files_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'account-files' and private.can_use_account_file(name));
create policy account_files_update on storage.objects for update to authenticated
  using (bucket_id = 'account-files' and private.can_use_account_file(name))
  with check (bucket_id = 'account-files' and private.can_use_account_file(name));
create policy account_files_delete on storage.objects for delete to authenticated
  using (bucket_id = 'account-files' and private.can_use_account_file(name));

drop policy if exists avatars_select on storage.objects;
drop policy if exists avatars_insert on storage.objects;
drop policy if exists avatars_update on storage.objects;
drop policy if exists avatars_delete on storage.objects;
create policy avatars_select on storage.objects for select to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy avatars_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy avatars_update on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy avatars_delete on storage.objects for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

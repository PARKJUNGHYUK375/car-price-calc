create table if not exists public.inventory_records (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  record jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create index if not exists inventory_records_user_updated_idx
on public.inventory_records(user_id, updated_at desc);

alter table public.inventory_records enable row level security;

drop policy if exists "inventory_records_select_own" on public.inventory_records;
create policy "inventory_records_select_own" on public.inventory_records
for select to authenticated using (auth.uid() = user_id);

drop policy if exists "inventory_records_insert_own" on public.inventory_records;
create policy "inventory_records_insert_own" on public.inventory_records
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "inventory_records_update_own" on public.inventory_records;
create policy "inventory_records_update_own" on public.inventory_records
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "inventory_records_delete_own" on public.inventory_records;
create policy "inventory_records_delete_own" on public.inventory_records
for delete to authenticated using (auth.uid() = user_id);

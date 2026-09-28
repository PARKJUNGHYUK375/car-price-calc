create table if not exists public.purchase_records (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  car_no text,
  car_name text,
  purchase_date date,
  purchase_price text,
  workspace jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists purchase_records_user_updated_idx
on public.purchase_records(user_id, updated_at desc);

alter table public.purchase_records enable row level security;

drop policy if exists "purchase_records_select_own" on public.purchase_records;
create policy "purchase_records_select_own" on public.purchase_records
for select to authenticated using (auth.uid() = user_id);

drop policy if exists "purchase_records_insert_own" on public.purchase_records;
create policy "purchase_records_insert_own" on public.purchase_records
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "purchase_records_update_own" on public.purchase_records;
create policy "purchase_records_update_own" on public.purchase_records
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "purchase_records_delete_own" on public.purchase_records;
create policy "purchase_records_delete_own" on public.purchase_records
for delete to authenticated using (auth.uid() = user_id);
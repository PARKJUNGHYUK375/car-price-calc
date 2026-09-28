create table if not exists public.purchase_drafts (
  user_id uuid primary key references auth.users(id) on delete cascade,
  workspace jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.purchase_drafts enable row level security;

drop policy if exists "purchase_drafts_select_own" on public.purchase_drafts;
create policy "purchase_drafts_select_own"
on public.purchase_drafts for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "purchase_drafts_insert_own" on public.purchase_drafts;
create policy "purchase_drafts_insert_own"
on public.purchase_drafts for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "purchase_drafts_update_own" on public.purchase_drafts;
create policy "purchase_drafts_update_own"
on public.purchase_drafts for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
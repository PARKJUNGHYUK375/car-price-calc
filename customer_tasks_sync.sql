-- Dealer Mate: customer/task synchronization (run once in Supabase SQL Editor).
create table if not exists public.customer_tasks (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  record jsonb not null,
  updated_at timestamptz not null,
  primary key (user_id, id)
);
alter table public.customer_tasks enable row level security;
drop policy if exists "customer_tasks_own_records" on public.customer_tasks;
create policy "customer_tasks_own_records" on public.customer_tasks
  for all to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
grant select, insert, update, delete on public.customer_tasks to authenticated;
revoke all on public.customer_tasks from anon;

create or replace function public.dealer_mate_sync_tasks(payload jsonb default '[]'::jsonb)
returns setof public.customer_tasks
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Sign in required';
  end if;
  if jsonb_typeof(payload) <> 'array' then
    raise exception 'Invalid task payload';
  end if;
  insert into public.customer_tasks (user_id, id, record, updated_at)
    select auth.uid(), x.id, x.record, x.updated_at
    from jsonb_to_recordset(payload) as x(id text, record jsonb, updated_at timestamptz)
    where x.id is not null and x.record is not null and x.updated_at is not null
  on conflict (user_id, id) do update
    set record = excluded.record, updated_at = excluded.updated_at
    where public.customer_tasks.updated_at < excluded.updated_at;
  return query select t.* from public.customer_tasks t where t.user_id = auth.uid();
end;
$$;
revoke all on function public.dealer_mate_sync_tasks(jsonb) from public;
grant execute on function public.dealer_mate_sync_tasks(jsonb) to authenticated;

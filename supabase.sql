-- Выполнить один раз в Supabase: SQL Editor -> New query -> Run.
create table if not exists public.dashboard_state (
  id text primary key check (id = 'main'),
  data jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by text
);

alter table public.dashboard_state enable row level security;

drop policy if exists "Public can read dashboard" on public.dashboard_state;
create policy "Public can read dashboard"
  on public.dashboard_state for select to anon using (true);

drop policy if exists "Public can create dashboard" on public.dashboard_state;
create policy "Public can create dashboard"
  on public.dashboard_state for insert to anon with check (true);

drop policy if exists "Public can edit dashboard" on public.dashboard_state;
create policy "Public can edit dashboard"
  on public.dashboard_state for update to anon using (true) with check (true);

-- Включить realtime для таблицы, если она ещё не добавлена в публикацию.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'dashboard_state'
  ) then
    alter publication supabase_realtime add table public.dashboard_state;
  end if;
end $$;

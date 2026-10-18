-- DeepWork — Supabase 스키마. SQL Editor에 통째로 붙여넣고 Run.
-- 모든 행은 로그인한 본인(auth.uid())만 읽고 쓸 수 있다(RLS).
-- 시간 칸은 로컬(KST) 문자열 'YYYY-MM-DDTHH:MM[:SS]' 그대로 — 맥 버전과 같은 형식.

create table if not exists seasons (
  id text primary key default replace(gen_random_uuid()::text,'-',''), user_id uuid not null default auth.uid() references auth.users on delete cascade,
  name text not null, start text not null, "end" text not null, theme text default '', created text
);
create table if not exists objectives (
  id text primary key default replace(gen_random_uuid()::text,'-',''), user_id uuid not null default auth.uid() references auth.users on delete cascade,
  season_id text references seasons(id) on delete set null,
  name text not null, category text, deadline text, target_h real,
  status text default 'Not started', notes text default '', sort int default 0, created text
);
create table if not exists blocks (
  id text primary key default replace(gen_random_uuid()::text,'-',''), user_id uuid not null default auth.uid() references auth.users on delete cascade,
  name text not null, start text not null, "end" text,
  type text default 'Focus block', category text,
  objective_id text references objectives(id) on delete set null,
  notes text default '', done boolean default false, actual_h real, deadline text, created text
);
create table if not exists focus_sessions (
  id text primary key default replace(gen_random_uuid()::text,'-',''), user_id uuid not null default auth.uid() references auth.users on delete cascade,
  block_id text references blocks(id) on delete cascade,
  started_at text not null, ended_at text, paused_at text, paused_ms bigint default 0,
  rating int, note text default '',
  name text, category text, objective_id text references objectives(id) on delete set null
);
create table if not exists reviews (
  id text primary key default replace(gen_random_uuid()::text,'-',''), user_id uuid not null default auth.uid() references auth.users on delete cascade,
  kind text not null, period text not null, energy int,
  wins text default '', lessons text default '', next text default '', updated text,
  unique (user_id, kind, period)
);
create table if not exists settings (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  key text not null, value jsonb, primary key (user_id, key)
);

create index if not exists blocks_user_start on blocks (user_id, start);
create index if not exists sessions_user on focus_sessions (user_id, started_at);

do $$
declare t text;
begin
  foreach t in array array['seasons','objectives','blocks','focus_sessions','reviews','settings'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists own_rows on %I', t);
    execute format('create policy own_rows on %I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;

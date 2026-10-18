-- DeepWork 업데이트 002: 블록 없이 한 집중(자유 집중)에도 이름·카테고리·목표를 붙인다.
alter table focus_sessions add column if not exists name text;
alter table focus_sessions add column if not exists category text;
alter table focus_sessions add column if not exists objective_id text references objectives(id) on delete set null;

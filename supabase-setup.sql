-- Supabase SQL Editor 에서 이 파일 내용을 붙여넣고 Run 실행하세요.
-- 테이블이 없거나 RLS 때문에 저장이 안 될 때 사용합니다.

-- 1) 테이블 생성
create table if not exists lotto_draws (
  id uuid primary key default gen_random_uuid(),
  main_numbers smallint[] not null,
  bonus_number smallint not null,
  created_at timestamptz default now()
);

create index if not exists idx_lotto_draws_created_at
  on lotto_draws (created_at desc);

-- 2) RLS 켜기 + 익명(anon) 사용자 insert/select 허용
alter table lotto_draws enable row level security;

-- 기존 정책이 있으면 먼저 삭제 후 생성 (에러 방지)
drop policy if exists "Allow anonymous insert" on lotto_draws;
drop policy if exists "Allow anonymous select" on lotto_draws;

create policy "Allow anonymous insert"
  on lotto_draws for insert
  to anon
  with check (true);

create policy "Allow anonymous select"
  on lotto_draws for select
  to anon
  using (true);

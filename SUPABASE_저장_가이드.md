# Supabase에 추첨 번호 저장하기 — 처음부터

로또 사이트에서 뽑은 번호를 Supabase DB에 쌓는 방법을 **순서대로** 정리했습니다.

---

## 1단계: Supabase 프로젝트 준비

1. **https://supabase.com** 접속 후 로그인
2. 이미 만든 프로젝트가 있으면 선택, 없으면 **New project**로 새로 만들기
3. **Settings**(⚙️) → **API** 메뉴로 이동
4. 아래 두 값을 메모해 두기 (나중에 씀)
   - **Project URL** (예: `https://xxxxx.supabase.co`)
   - **Project API keys** → **anon** **public** 키 (긴 JWT 문자열)

---

## 2단계: 테이블 + 권한 한 번에 만들기

1. Supabase 왼쪽 메뉴에서 **SQL Editor** 클릭
2. **New query** 클릭
3. 아래 SQL **전부 복사**해서 빈 칸에 **붙여넣기**
4. **Run** (또는 Ctrl+Enter) 실행
5. **Success** 나오면 완료

```sql
-- 테이블이 이미 있으면 삭제 후 다시 생성 (깨끗하게 시작)
drop table if exists lotto_draws;

-- 추첨 결과 저장 테이블
create table lotto_draws (
  id uuid primary key default gen_random_uuid(),
  main_numbers smallint[] not null,
  bonus_number smallint not null,
  created_at timestamptz default now()
);

-- RLS 켜기
alter table lotto_draws enable row level security;

-- 익명(anon) 사용자도 INSERT 가능
create policy "Allow anonymous insert"
  on lotto_draws for insert
  to anon
  with check (true);

-- 익명(anon) 사용자도 SELECT 가능
create policy "Allow anonymous select"
  on lotto_draws for select
  to anon
  using (true);
```

6. 왼쪽 **Table Editor** 클릭 → **lotto_draws** 테이블이 보이면 성공

---

## 3단계: 웹에서 쓰는 Supabase 주소/키 넣기

우리 사이트는 **Supabase URL**과 **anon 키**를 알아야 저장할 수 있습니다.  
두 가지 방법 중 하나만 하면 됩니다.

### 방법 A: 코드에 직접 넣기 (가장 단순)

1. 프로젝트에서 **index.html** 열기
2. 아래 부분 찾기 (Ctrl+F로 `SUPABASE_URL` 검색):

```html
window.SUPABASE_URL = 'https://upnebboolprzgyroztjl.supabase.co';
window.SUPABASE_ANON_KEY = 'eyJhbGci...';
```

3. **본인 Supabase**의 값으로 바꾸기  
   - `SUPABASE_URL` → Settings → API 의 **Project URL**  
   - `SUPABASE_ANON_KEY` → 같은 화면의 **anon public** 키

4. 저장 후 Vercel에 배포(푸시)하면 해당 사이트에서 저장 가능

### 방법 B: Vercel 환경 변수로 넣기

1. **Vercel** 대시보드 → 해당 프로젝트 → **Settings** → **Environment Variables**
2. 변수 두 개 추가:
   - Name: `SUPABASE_URL`  
     Value: `https://본인프로젝트.supabase.co`
   - Name: `SUPABASE_ANON_KEY`  
     Value: `eyJhbGci...` (anon public 키 전체)
3. **Save** 후 **Redeploy** 한 번 하기

(이미 index.html에 URL/키가 들어 있으면, 환경 변수 없어도 동작합니다.)

---

## 4단계: 저장되는지 확인

1. **로또 사이트** 접속 (예: https://20260311-two.vercel.app/)
2. **1세트 뽑기** 클릭 → 추첨이 끝날 때까지 대기
3. **뽑힌 번호** 아래에
   - **저장됨** 이 뜨면 → Supabase에 정상 저장된 것
   - **저장 실패: …** 가 뜨면 → 메시지 내용 확인
4. **Supabase** → **Table Editor** → **lotto_draws** 테이블 선택 후 **새로고침**  
   → 방금 뽑은 번호가 한 줄로 추가돼 있으면 성공

---

## 저장이 안 될 때

- **저장 실패: …** 메시지가 뜨면 **그 문장 전체**를 확인하세요.
  - `relation "lotto_draws" does not exist` → **2단계 SQL**을 다시 실행해서 테이블 생성
  - `new row violates row-level security` → **2단계 SQL**에서 RLS 정책 부분 다시 실행
  - `Supabase 설정이 없습니다` → **3단계**에서 URL/키가 제대로 들어갔는지 확인
- **저장 중...** 만 보이고 **저장됨**이 안 뜨면  
  → 브라우저 **F12** → **Console** 탭에 에러가 있는지 확인해 보세요.

---

## 정리

| 단계 | 할 일 |
|------|--------|
| 1 | Supabase에서 Project URL, anon 키 확인 |
| 2 | SQL Editor에서 위 SQL 실행 → `lotto_draws` 테이블 + RLS 생성 |
| 3 | index.html에 URL/키 넣기 (또는 Vercel 환경 변수 설정 후 Redeploy) |
| 4 | 사이트에서 1세트 뽑기 → "저장됨" + Table Editor에 데이터 확인 |

이 순서대로 하면 추첨할 때마다 Supabase `lotto_draws` 테이블에 자동으로 저장됩니다.

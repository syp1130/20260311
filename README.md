# 로또 번호 추천 서비스

1~45 번호 중 무작위로 6개 + 보너스 번호를 추천하는 웹 페이지입니다.

---

## Supabase로 추첨 번호 저장하기

### 1. Supabase 프로젝트 만들기

1. [Supabase](https://supabase.com)에 로그인 후 **New project**로 프로젝트 생성
2. **Project URL**과 **anon public** 키 확인:  
   **Settings** → **API** → **Project URL** / **Project API keys** → `anon` `public`

### 2. 테이블 만들기

Supabase 대시보드에서 **SQL Editor** 열고 아래 쿼리 실행:

```sql
create table if not exists lotto_draws (
  id uuid primary key default gen_random_uuid(),
  main_numbers smallint[] not null,
  bonus_number smallint not null,
  created_at timestamptz default now()
);

-- (선택) 최근 기록만 조회할 때 사용
create index if not exists idx_lotto_draws_created_at
  on lotto_draws (created_at desc);
```

### 3. RLS 정책 설정 (클라이언트에서 insert 허용)

**Authentication** → **Policies**에서 `lotto_draws` 테이블에 정책 추가하거나,  
**SQL Editor**에서 아래 실행:

```sql
alter table lotto_draws enable row level security;

create policy "Allow anonymous insert"
  on lotto_draws for insert
  to anon
  with check (true);

create policy "Allow anonymous select"
  on lotto_draws for select
  to anon
  using (true);
```

- 익명(anon) 사용자도 **insert** / **select** 가능하게 한 설정입니다.  
- 나중에 로그인을 붙이면 `to authenticated` 등으로 바꾸면 됩니다.

### 4. Supabase 키 설정 (Vercel 배포 시 권장)

**Vercel로 배포한 경우** — 환경 변수로 설정하면 코드에 키를 넣지 않아도 됩니다.

1. Vercel 대시보드 → 해당 프로젝트 → **Settings** → **Environment Variables**
2. 아래 두 개 추가:

| Name               | Value                    | Environment |
|--------------------|--------------------------|-------------|
| `SUPABASE_URL`     | `https://xxxxx.supabase.co` | Production, Preview 등 필요한 환경 |
| `SUPABASE_ANON_KEY` | `eyJhbGci...` (anon public 키) | 동일 |

3. 저장 후 **Redeploy** 하면 `/api/config`가 이 값을 읽어 클라이언트에 전달합니다.

**로컬에서만 쓸 때** — `index.html`에서 `window.SUPABASE_URL`, `window.SUPABASE_ANON_KEY`를 직접 넣어도 되고, 로컬에서 `/api/config`를 제공하는 서버를 쓰면 같은 방식으로 동작합니다.

이렇게 설정하면 추첨이 끝날 때마다 **자동으로** `lotto_draws` 테이블에 번호가 저장됩니다.

---

## 사용 방법

1. **파일로 열기**  
   `index.html` 파일을 더블클릭하거나 브라우저로 드래그해서 열면 됩니다.

2. **로컬 서버로 실행 (선택)**  
   터미널에서 프로젝트 폴더로 이동한 뒤 아래 중 하나를 실행하세요.
   - Python 3: `python -m http.server 8080`
   - Node.js (npx): `npx serve .`
   - 그 다음 브라우저에서 `http://localhost:8080` 접속

## 기능

- **1세트 뽑기**: 6개 번호 + 보너스 1개
- **5세트 뽑기**: 동일 규칙으로 5세트 한 번에 생성
- 번호는 오름차순 정렬, 보너스 번호는 금색으로 표시

참고용이며 당첨을 보장하지 않습니다.

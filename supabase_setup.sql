-- DIT FC ONLINE LEAGUE 시즌 3: Supabase SQL Editor에서 전체 실행
create table if not exists public.league_state (
  id integer primary key check (id = 1),
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.league_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.league_state enable row level security;
alter table public.league_admins enable row level security;

grant select on public.league_state to anon, authenticated;
grant insert, update on public.league_state to authenticated;
grant select on public.league_admins to authenticated;

drop policy if exists "Public can read league state" on public.league_state;
create policy "Public can read league state" on public.league_state
  for select to anon, authenticated using (true);

drop policy if exists "Admins can insert league state" on public.league_state;
create policy "Admins can insert league state" on public.league_state
  for insert to authenticated with check (
    exists (select 1 from public.league_admins a where a.user_id = (select auth.uid()))
  );
drop policy if exists "Admins can update league state" on public.league_state;
create policy "Admins can update league state" on public.league_state
  for update to authenticated using (
    exists (select 1 from public.league_admins a where a.user_id = (select auth.uid()))
  ) with check (
    exists (select 1 from public.league_admins a where a.user_id = (select auth.uid()))
  );

drop policy if exists "Admins can view own admin record" on public.league_admins;
create policy "Admins can view own admin record" on public.league_admins
  for select to authenticated using (user_id = (select auth.uid()));

insert into public.league_state (id, payload)
values (1, '{"matches":[{"round":1,"num":1,"a":"최익재","b":"이병철","sa":1,"sb":4},{"round":1,"num":2,"a":"박성욱","b":"이승운","sa":null,"sb":null},{"round":1,"num":3,"a":"송석현","b":"정민우","sa":null,"sb":null},{"round":1,"num":4,"a":"정동빈","b":"신현식","sa":null,"sb":null},{"round":1,"num":5,"a":"박진용","b":"강석규","sa":null,"sb":null},{"round":2,"num":6,"a":"이승운","b":"최익재","sa":2,"sb":2},{"round":2,"num":7,"a":"정민우","b":"이병철","sa":null,"sb":null},{"round":2,"num":8,"a":"신현식","b":"박성욱","sa":null,"sb":null},{"round":2,"num":9,"a":"강석규","b":"송석현","sa":null,"sb":null},{"round":2,"num":10,"a":"박진용","b":"정동빈","sa":null,"sb":null},{"round":3,"num":11,"a":"최익재","b":"정민우","sa":null,"sb":null},{"round":3,"num":12,"a":"이승운","b":"신현식","sa":null,"sb":null},{"round":3,"num":13,"a":"이병철","b":"강석규","sa":8,"sb":1},{"round":3,"num":14,"a":"박성욱","b":"박진용","sa":null,"sb":null},{"round":3,"num":15,"a":"송석현","b":"정동빈","sa":null,"sb":null},{"round":4,"num":16,"a":"신현식","b":"최익재","sa":null,"sb":null},{"round":4,"num":17,"a":"강석규","b":"정민우","sa":null,"sb":null},{"round":4,"num":18,"a":"박진용","b":"이승운","sa":null,"sb":null},{"round":4,"num":19,"a":"정동빈","b":"이병철","sa":null,"sb":null},{"round":4,"num":20,"a":"송석현","b":"박성욱","sa":null,"sb":null},{"round":5,"num":21,"a":"최익재","b":"강석규","sa":1,"sb":1},{"round":5,"num":22,"a":"신현식","b":"박진용","sa":null,"sb":null},{"round":5,"num":23,"a":"정민우","b":"정동빈","sa":null,"sb":null},{"round":5,"num":24,"a":"이승운","b":"송석현","sa":null,"sb":null},{"round":5,"num":25,"a":"이병철","b":"박성욱","sa":null,"sb":null},{"round":6,"num":26,"a":"박진용","b":"최익재","sa":null,"sb":null},{"round":6,"num":27,"a":"정동빈","b":"강석규","sa":null,"sb":null},{"round":6,"num":28,"a":"송석현","b":"신현식","sa":null,"sb":null},{"round":6,"num":29,"a":"박성욱","b":"정민우","sa":4,"sb":6},{"round":6,"num":30,"a":"이병철","b":"이승운","sa":2,"sb":2},{"round":7,"num":31,"a":"최익재","b":"정동빈","sa":null,"sb":null},{"round":7,"num":32,"a":"박진용","b":"송석현","sa":null,"sb":null},{"round":7,"num":33,"a":"강석규","b":"박성욱","sa":null,"sb":null},{"round":7,"num":34,"a":"신현식","b":"이병철","sa":null,"sb":null},{"round":7,"num":35,"a":"정민우","b":"이승운","sa":null,"sb":null},{"round":8,"num":36,"a":"송석현","b":"최익재","sa":null,"sb":null},{"round":8,"num":37,"a":"박성욱","b":"정동빈","sa":null,"sb":null},{"round":8,"num":38,"a":"이병철","b":"박진용","sa":null,"sb":null},{"round":8,"num":39,"a":"이승운","b":"강석규","sa":1,"sb":2},{"round":8,"num":40,"a":"정민우","b":"신현식","sa":null,"sb":null},{"round":9,"num":41,"a":"최익재","b":"박성욱","sa":2,"sb":7},{"round":9,"num":42,"a":"송석현","b":"이병철","sa":null,"sb":null},{"round":9,"num":43,"a":"정동빈","b":"이승운","sa":null,"sb":null},{"round":9,"num":44,"a":"박진용","b":"정민우","sa":null,"sb":null},{"round":9,"num":45,"a":"강석규","b":"신현식","sa":null,"sb":null}],"scorers":{},"brackets":{}}'::jsonb)
on conflict (id) do nothing;

-- 실시간 반영을 위해 Supabase Dashboard > Database > Publications에서
-- supabase_realtime publication에 league_state 테이블을 추가해줘.

-- ============================================================
-- Run this in your Supabase project → SQL Editor
-- ============================================================

-- 1. Tournaments table
create table if not exists tournaments (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    time_control text not null,   -- e.g. "5+0", "1+0", "10+0"
    icon text default 'trophy',   -- fire | bolt | trophy | star | crown
    starts_at timestamptz not null default now(),
    ends_at timestamptz not null,
    player_count integer default 0,
    created_at timestamptz default now()
);

alter table tournaments enable row level security;
create policy "public read tournaments" on tournaments for select using (true);
create policy "public update player_count" on tournaments for update using (true) with check (true);

-- Enable realtime on tournaments
alter publication supabase_realtime add table tournaments;

-- Enable realtime on sudoku_rooms (for live game count — skip if already done)
alter publication supabase_realtime add table sudoku_rooms;

-- 2. Seed some tournaments (adjust dates as needed)
insert into tournaments (name, time_control, icon, starts_at, ends_at, player_count) values
    ('Blitz Tourney',    '5+0',  'fire',   now(),                      now() + interval '2 hours',  0),
    ('Bullet Arena',     '1+0',  'bolt',   now() - interval '30 min',  now() + interval '90 min',   0),
    ('Daily Sudoku Cup', '10+0', 'trophy', now() - interval '1 hour',  now() + interval '23 hours', 0)
on conflict do nothing;

-- 3. Function to auto-increment player_count when someone joins a tournament room
-- (Wire this up to your matchmaking logic later — optional for now)
-- create or replace function increment_tournament_players(tournament_id uuid)
-- returns void language sql as $$
--   update tournaments set player_count = player_count + 1 where id = tournament_id;
-- $$;

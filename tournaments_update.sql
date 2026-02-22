-- ============================================================
-- Run this in Supabase → SQL Editor
-- ============================================================

-- 1. Add creator columns to tournaments table
alter table tournaments
    add column if not exists creator_id uuid references auth.users(id),
    add column if not exists creator_username text;

-- 2. Update RLS to allow signed-in users to create tournaments
create policy "authenticated users can create tournaments"
    on tournaments for insert
    to authenticated
    with check (auth.uid() = creator_id);

-- 3. RPC function to safely increment player count
create or replace function increment_tournament_count(tid uuid)
returns void language sql security definer as $$
    update tournaments
    set player_count = player_count + 1
    where id = tid and ends_at > now();
$$;

-- Run this in the Supabase SQL Editor

create table leaderboard (
  id uuid primary key default gen_random_uuid(),
  nickname text not null check (char_length(nickname) >= 2 and char_length(nickname) <= 10),
  score integer not null check (score >= 0),
  device_id text not null,
  total_merges integer default 0,
  max_chain_level integer default 0,
  created_at timestamptz default now()
);

alter table leaderboard enable row level security;
create policy "Anyone can read" on leaderboard for select using (true);
create policy "Anyone can insert" on leaderboard for insert with check (true);
create index idx_leaderboard_score on leaderboard (score desc);

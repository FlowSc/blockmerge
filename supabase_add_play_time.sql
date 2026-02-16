-- Migration: Add play_time_seconds column to leaderboard table
-- Run this in Supabase SQL Editor

alter table leaderboard
  add column if not exists play_time_seconds int default 0;

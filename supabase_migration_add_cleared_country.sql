-- Migration: Add game_mode, is_cleared, and country columns to leaderboard
-- Run this in the Supabase SQL Editor

ALTER TABLE leaderboard ADD COLUMN IF NOT EXISTS game_mode text DEFAULT 'classic';
ALTER TABLE leaderboard ADD COLUMN IF NOT EXISTS is_cleared boolean DEFAULT false;
ALTER TABLE leaderboard ADD COLUMN IF NOT EXISTS country text;

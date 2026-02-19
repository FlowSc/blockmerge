# Chain Digger - Game Design Document

## Concept

One-tap mining chain-reaction puzzle game. Tap clusters of same-colored ore blocks to blast them, trigger gravity cascades, and dig deeper into the mine. Oxygen runs out = game over.

**Target:** ~3 minute play sessions, short dopamine cycles, pixel art + dark neon aesthetic.

## Grid

- **8 columns x 13 rows** fixed viewport
- Block destruction accumulates dig points -> **every 20 points scrolls 1 row** (top row removed, new row spawned at bottom)
- New row generation: "vein" algorithm (65% copy adjacent color / 35% random from palette) -> natural cluster formation
- **Empty column collapse**: after explosions, empty columns compress toward center -> additional chain opportunities
- Guarantee at least one tappable cluster (>=3) after full settle

## Block Types

- **Normal ore**: 4 colors at start
  - Depth 41m+: 5 colors
  - Depth 101m+: 6 colors
- **Bomb ore**: ~2% spawn rate, when included in explosion clears 3x3 area
- (v2: Prism ore wildcard, Hard rock obstacle)

## Controls

- **Tap**: explode orthogonally connected same-color cluster of 3+
- Cluster < 3: shake animation, no explosion
- No other controls (pure one-tap game)

## Chain System

Resolution order: explosion -> gravity drop -> empty column collapse -> auto-explode new clusters -> repeat until stable

- Chain index `c` starts at 1 for tapped explosion, increments each auto step
- Chain multipliers: `[1.0, 1.5, 2.2, 3.1, 4.2, 5.6, ...]`
- Score formula: `12 * n * (1 + 0.18*(n-3)) * chainMult(c) * depthMult`
  - `n` = blocks destroyed in that step
  - `depthMult = 1 + depth/200` (cap at 2.0)
- Bonus: n >= 8 -> +100, n >= 12 -> +300

## Oxygen System (3-Minute Pressure)

- Start: **180 seconds**
- Passive drain: **-1.0s per second**
- Tap cost: **-0.2s per tap** (anti-spam)
- Recovery:
  - Block destroyed: **+0.12s per block**
  - Chain 2: **+1s**
  - Chain 3: **+2s**
  - Chain 4+: **+4s**
- Cap: **210 seconds**
- Warning: oxygen <= 15s -> red pulse UI

## Visual Feedback (Dopamine)

- Explosion: hit-stop (80-120ms) + particle burst + rising-pitch SFX
- Chain text: `CHAIN x2!`, `CHAIN x3!`, `MEGA x4!`, ...
- Screen shake: amplitude increases with chain level
- Chain 4+: 200ms slow-motion -> burst resume
- Large cluster (8+): bonus score + gem particle spray
- Oxygen rescue: big chain visibly refills oxygen bar (clutch feeling)

## Game Over & Results

- Oxygen reaches 0 -> game over
- Result screen shows: **Score**, **Max Depth**, **Max Chain**, **Play Time**
- Score submission -> leaderboard (same as MCB: period filters, Supabase)
- Interstitial ad after results

## Monetization

- Bottom banner ad (during gameplay)
- Interstitial ad after game over

## Tech Stack

- Flutter + Riverpod + GoRouter + Supabase
- Same architecture as MCB (feature-first, shared coding standards)
- Separate project: `izak/chain_digger/`
- Localization: EN, KO, JA, ES

## Game Modes

- **v1**: Oxygen mode only
- **v2 roadmap**:
  - Classic mode (no time limit, game over when no moves remain)
  - Endless mode (reach target depth stages)
  - Prism ore (wildcard block)
  - Hard rock (obstacle block, 2 hits to break)
  - Gem collection -> skin/theme unlocks

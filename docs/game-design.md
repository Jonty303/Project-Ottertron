# Project Ottertron — game design v0.3

Engine: **Godot 4.5.2-stable**. A top-down shoot-'em-up in square arenas. Character art goal: static 64×64 directional pixel sprites, no animation.

## Run structure

- The otter begins with **12 HP**. Loss at zero HP.
- At the start, **5 Colin enemies** spawn inside the square arena, at least 225px away from the otter and typically at least 90px apart.
- On clearing all enemies, a **one-second breather** precedes a fresh wave of five enemies; a reward pickup appears as the wave ends.
- Repeat until **50 enemies** are killed (ten waves). Victory at 50, defeat if player HP reaches zero first; neither state allows extra waves.
- HUD displays kill progress, wave, enemies remaining, player health and current doughnut stats.
- Spawn locations are randomized in the playable interior, not on walls or the otter.

## Weapons

- Continuous firing while right stick deflected, independent left-stick movement, keyboard WASD/arrows fallback.
- Doughnuts start with **damage 1**, **speed 315px/s** (down from 370), and **size 0.78×** (about 17px artwork width rather than the old 22px).
- Projectiles have independently stored damage, speed and size and inherit player's stat values when fired.
- Art scale **and hitbox radius** grow with size. Size capped at **2.0×** for now.

## Pickups

- Three *separate* types: red **D** = damage +1; blue **S** = speed +70px/s; purple **+** = size +0.18×.
- All three spawn near the player for testing at the beginning of a run. One additional pickup appears when a wave is cleared; reward type cycles damage, speed, size by wave.
- Pickups remain until collected. Values are adjustable in the pickup script and stats stack through the run.
- Floating text announces collected upgrades.

## Enemy: Colin

- Small bald, rotund office worker with glasses, yellow cardigan, white shirt, tie and trousers. Static sprite art goal.
- **2 HP** with overhead health bar. Slow pursuit (~68px/sec), including across the entire room.
- Begins draining at 53px and holds a wobbly purple aura. Tick every 1.0 second. Damage per tick: 1 for first 3, 2 for next 3, 3 for next 3, capped at 4.
- Escape further than 96px to break channel, stop ticking and reset the next channel's damage ramp.
- Multiple Colins can channel independently. Damage taken by the otter and doughnut hits on Colins show floating numbers.

## Planned

- Replace procedural placeholders with the approved 64×64 sprite artwork; the otter UP-RIGHT view is an exact mirror of UP-LEFT.
- More varied enemy types, balancing, room variety and audio.

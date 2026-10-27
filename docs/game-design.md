# Project Ottertron — game design v0.6

**Engine:** Godot 4.5.2-stable. **Genre:** top-down twin-stick wave-survival shooter. Character art goal: static directional 64×64 sprites, with effect animation allowed.

## Survival

- Otter begins with **12 HP**. Kills goal: **50** across 10 waves of five Colins.
- Waves 1–9: 3 yellow, 1 red, 1 blue; wave 10: 1 boss (2.2×, 40 HP) and 4 weighted-random minions.
- Clear all living enemies and finish any pending red explosions before spawning the next wave, one second later. On the final wave, detonations also finish before victory is declared.
- HUD shows survival progress, wave, otter HP and doughnut weapon statistics.

## Colin variants

- Yellow: slow, close-range escalating life-drain; 10 HP; no gameplay explosion on death.
- Red: life-drain and 10 HP; on death becomes non-colliding and pulses **bright red for 0.9 seconds**. No floating textual warning. Then bursts into a **mushroom cloud**, plus 128px blast for one randomly rolled 1–10 HP damage value affecting otter and other living Colins. Can cause chain reactions.
- Blue: avoids close contact, shoots approximately 1 pencil per second for random 1–10 damage, with friendly fire against other Colins. Pencils break into pieces on impact but show **no `SNAP!` text**. Normal damage numbers still appear.
- Boss (purple): 2.2× scale, slower, 40 HP, both aura and pencils, never explodes offensively by default.
- **Every non-red death displays a small cosmetic mushroom cloud.** Red explosions also use the mushroom shape, with a radius indicator and actual damage.

## Otter death and results dialogue

- The source of every player hit is recorded at damage application: named enemy life-drain, ranged Colin's pencil, or red Colin's explosion.
- Lethal damage triggers crossed-out eyes, a 0.48s squash/rotation collapse and health bar removal. Gameplay and enemy movement stop.
- After a small pause, a gravestone **falls from above with a bounce and dust**, landing adjacent to the corpse, then a modal **GAME OVER** panel appears.
- The panel contains **cause of death**, **elapsed survival time (mm:ss)** and **kill progress**, with restart button/controller prompt. Elapsed time is accumulated while the run is active and frozen at death.
- Win also displays a results panel and survival time.

## Retained mechanics

- Doughnuts: 1 damage, 315px/s, 0.78×, 1% chance of 2× crit. Floating damage and critical text.
- Upgrades: +1 damage, +70px/s, +0.18× projectile size and hitbox.
- Aura: ticks each second, escalating 1 to 4 damage, resets when escaped beyond 96px (boss has larger ranges).

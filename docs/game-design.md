# Project Ottertron — game design v0.7

**Engine:** Godot 4.5.2-stable. **Camera:** top-down camera constrained to an expanded **1792×1792px arena**.

## Arena

There are **13 solid blocking rock/plant features**, **5 pop-up spike traps** and **3 animated fire pits**, initially placed at fixed safe positions. Solid features block player, enemies and both projectile families via collision layer 8, and enemy spawning avoids them and hazards.

- **Spike trap:** triggered when otter enters the plate (30px radius). Spikes pop over a short 0.12s warning and deal **2 damage** when triggered. They retract after 0.68s, then cool down 2.8s before being able to reactivate following re-entry.
- **Fire pit:** applies a **five-tick burn** to the otter on entry; each tick is **1 HP exactly one second apart**. No instant damage. Animated fire draws on pit and burning otter. Reapplication refreshes the five ticks. Ticks pause during boon selection, and death reason is `Fire pit burn`.
- **Health pickup:** restores **3 HP** without exceeding 12 HP, cannot be consumed at full health. One starts in the room; additional pickup drop chance is **20% on enemy kill if player is wounded**.

## Chaos boons

At the end of waves **2, 4, 6 and 8**, when all enemies and any red bombs are resolved, offer a **three-choice modal**. There is no combat until a selection is made; survivor timer and burn ticks are paused. The paired modifiers remain active and compound when selected more than once:

1. **Swarm:** enemies spawned ×1.25 (rounded up from the five-enemy base); otter doughnut damage ×1.25 (rounded up to integer on each fired shot).
2. **Fortitude:** newly spawned enemy health ×1.30 (rounded up); otter movement speed ×1.20.
3. **Ferocity:** future enemy damage ×1.25 (rounded up per hit/tick), including draining, pencil impacts and red explosions; otter doughnut speed ×1.25.

Enemy modifiers scale from the global cumulative multipliers and apply to subsequently spawned enemies. Upgraded player stats persist the entire run; all reset on restart. Existing traditional damage/speed/size pickups remain separate.

## Waves, winning and losing

Waves 1–9 initially contain **3 yellow + 1 red + 1 blue Colin**. Wave 10 has **1 large, slow boss Colin + 4 randomly chosen minions**, before any extra-spawn modifiers. Bonus enemies are randomly selected normal/red/blue. Enemy spawn points are away from the otter, walls, obstacles, traps, pickups and one another.

**Base target is 50 enemies across 10 waves**, but a swarm boon means the actual kill count may be higher. Victory occurs when **wave 10** is cleared, including delayed red explosions. Defeat occurs at zero otter HP; the otter collapses, gravestone descends and results modal identifies the actual lethal damage and survival time.

## Retained combat

Yellow 10 HP, red 10 HP always explodes after 0.9s, blue 10 HP fires snapping friendly-fire pencils, boss base 40 HP and 2.2× visual scale with life drain and pencils. Life-drain escalates each second and resets after a range break. Red explosion base damage rolls 1–10 inside 128px and hurts otter and other living Colins. Doughnuts begin at 1 damage, 315px/s, 0.78× with 1% double-damage critical chance. Pickups boost damage +1, speed +70 or size +0.18×.

## Art and roadmap

Characters remain procedural placeholders pending approved static 64×64 direction sprites. Terrain, flame, spike and pickup visual effects are also temporary procedural art.

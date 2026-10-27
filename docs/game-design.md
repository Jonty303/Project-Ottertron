# Project Ottertron — game design v0.2

**Engine:** Godot 4.5.2-stable. **Perspective:** top-down 2D. **Artwork target:** static directional 64×64 sprites (no animation yet). **Rooms:** square, variable dimensions later; prototype is 960×960.

## Player: cuddly otter

- Rounded brown body, cream tummy and muzzle, expressive eyes and little whiskers.
- Eight directional static views intended (otter UP-RIGHT is exact horizontal flip of UP-LEFT).
- Left stick: free 360-degree movement; right stick: continuous aim/fire while deflected. Movement and aim independent.
- **12 HP** to start; health bar above the otter plus HUD display.
- Starting glazed doughnuts: **1 damage**, **370 px/s**, **0.20s** between shots. Damage and projectile speed stored as player weapon stats and copied onto each fired doughnut.
- Collecting the test glowing power-up gives **+1 damage** and **+80 px/s** speed. Power-ups are designed to add further increases, not hardcoded weapon tiers.

## Enemy: Colin

- Bald, rotund, glasses, yellow cardigan, white shirt/tie, brown trousers; initially static 64×64 directional character.
- **2 HP** (two unupgraded glazed doughnut hits), with a small overhead health bar.
- Slowly walks towards the otter (~68 px/s) until close enough to begin draining.
- **Wobbly aura life drain**, with two animated purple wavy rings and a wobbly tether to the otter (effect animation, not sprite animation).
- Starts draining at **53px** distance, immediately stops walking and channels while the target remains in range.
- Initial damage **1 HP per tick**; first hit occurs **1 second after channel starts**.
- Tick interval **1.0s**, adjustable independently.
- Damage increases by 1 after every three completed ticks: ticks 1–3: 1; 4–6: 2; 7–9: 3; tick 10 onward: 4 (cap).
- If separation exceeds **96px**, channel breaks (hysteresis intentionally avoids flickering) and resets timer and ramp. If Colin approaches and channels again it starts at 1 damage.
- Both start and break distances are exported balance variables; 96px is inside the requested 64–128px range.

## Combat readability

- Small in-world overhead bars on player and enemies, decreasing as they lose HP.
- Floating combat text near the victim for every damaging hit or drain tick (actual HP lost).
- Life drain displays `LIFE DRAIN` when started and `DRAIN BROKEN` on breaking.
- Power-up displays its impact on weapon stats.
- No direct contact damage: Colin damages through his aura only.

## Later

- Replace procedural placeholders with approved sprite textures, without changing combat logic.
- Room-size variants, more enemy types, differentiated doughnut and pickup stats, effects and audio.

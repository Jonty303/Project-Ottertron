# Project Ottertron

A cute top-down twin-stick shoot-'em-up using **Godot 4.5.2-stable**. Play a cuddly otter firing glazed doughnuts at Colin, a slow, rotund office worker with a yellow cardigan and a wobbly life-drain aura.

## Run

1. Install [Godot 4.5.2-stable](https://godotengine.org/download/archive/4.5.2-stable/).
2. Clone or download the private repository, import `project.godot` in Godot Project Manager and press F5.

| Action | Controller | Keyboard |
| --- | --- | --- |
| Move | Left stick | WASD |
| Aim and shoot | Right stick | Arrows |
| Restart after victory or defeat | A / Cross | R |

## Survival mode

- **5 Colins per wave**, spawning apart in the square arena.
- Kill **50 total** to win (ten waves). Otter starts with **12 HP** and loses when health reaches zero.
- New wave starts one second after all living enemies are dead **and any armed explosive corpses have detonated**.
- Enemies have overhead health bars; HUD shows kill count, wave, enemies left, doughnut stats and bomb count.
- Colin starts at **10 HP**. He approaches and channels a wobbly escalating life-drain aura when in close range. Getting 96px away breaks his channel.
- Doughnuts start at **1 damage**, **315px/s**, **0.78× size**. Each hit independently has **1% critical chance**, doubling damage and displaying a `CRIT!` number.

### Explosive Colin deaths

When Colin dies, **25% of the time** he glows red for **two seconds**, then explodes. The blast reaches **128px** and rolls **1–10 damage**, affecting the otter and other nearby living Colins. The blast can kill additional Colins, which can also become explosive corpses and trigger chain reactions.

The glowing dead Colin is non-colliding and cannot be damaged again. The kill count increments on death, not on detonation. When the game ends, all armed bombs are cancelled.

### Weapon power-ups

Three separate colour-coded pickups appear at game start. Another appears on each cleared wave:

| Pickup | Mark | Effect |
| --- | --- | --- |
| Damage | Red D | +1 doughnut damage |
| Speed | Cyan S | +70px/s doughnut speed |
| Size | Purple + | +0.18× doughnut size, including hitbox |

All upgrades stack. Critical chance is a configurable 0.01 on the player and copied onto each new doughnut projectile.

## Testing

GitHub Actions imports and launches the project headlessly with Godot 4.5.2 and runs `tests/waves_smoke.gd` to verify survival progression, upgrades, guaranteed critical/normal strikes, blast collateral damage and chain reactions. See `docs/test-plan.md` for hands-on testing.

**Artwork:** procedural stand-ins for the approved 64×64 otter and Colin directional sprites. No character animation yet.

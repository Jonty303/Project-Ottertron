# Project Ottertron

A cute top-down twin-stick shoot-'em-up built for **Godot 4.5.2-stable**. A cuddly otter fires glazed doughnuts at a growing office-worker menace.

## Run

1. Install [Godot 4.5.2-stable](https://godotengine.org/download/archive/4.5.2-stable/).
2. Clone this private GitHub repository, import `project.godot`, and press **F5**.

| Action | Gamepad | Keyboard testing |
| --- | --- | --- |
| Move | Left stick | WASD |
| Shoot/aim | Right stick | Arrow keys |
| Restart after game over | A / Cross | R |

## Enemy types

| Enemy | Look | Health | Behaviour |
| --- | --- | --- | --- |
| **Colin** | Yellow jumper | 10 | Slowly approaches; wobbly escalating life-drain aura in close range; **never explodes** |
| **Explosive Colin** | Red jumper | 10 | Approaches and life-drains; **always** glows red for 2 seconds upon death and then explodes |
| **Pencil Colin** | Blue jumper | 10 | Keeps ~190–270px distance and fires **one pencil each second**; no death explosion |
| **Boss Colin** | Large purple jumper; **2.2×** size | **40** | Slow (~33px/s); both life-drain and pencil attacks; no death explosion |

Every exploding red Colin damages the otter **and any other living Colin** within **128px**. The explosion rolls **1–10 damage** (one roll per blast); collateral kills count toward the 50-kill goal and red victims can chain-explode. The corpse is inert and non-colliding during the 2-second warning.

Pencils fly toward the otter, can hit **other Colins** (but not the shooter), and deal **1–10 random damage** before snapping on contact with enemies, the otter, or walls. A small snap effect and floating text indicate the break.

## Survival rounds

- **Rounds 1–9:** five enemies per round: **three yellow, one red, one blue**, shuffled each round.
- **Round 10:** **one boss Colin and four random minions** (55% yellow / 25% red / 20% blue per minion).
- **Victory at 50 enemy kills**, including the boss. Loss when the otter's 12 HP reaches zero.
- A wave clears only when all five Colins have died and all pending red explosions have resolved, then the next wave begins after 1 second.

## Player weapon and upgrades

- Starting doughnuts: **1 damage, 315px/s, 0.78× size**.
- Each hit has a **1% critical chance for double damage**.
- Red D = +1 doughnut damage; cyan S = +70px/s; purple + = +0.18× projectile size (including hitbox). Pickups stack and can be collected during play.

## Development

- `scenes/`: reusable character, doughnut, pencil and power-up scenes.
- `scripts/`: game loop, enemy types, ranged AI, projectiles, hit effects and health displays.
- `tests/`: headless wave, power-up, explosion and enemy-type regressions.
- `docs/`: [design](docs/game-design.md), [roadmap](docs/roadmap.md) and [test plan](docs/test-plan.md).

**Art:** the current in-engine sprites remain procedural placeholders. The approved 64×64 concept art is the future replacement target; the boss's in-game size is intentionally 2.2×.

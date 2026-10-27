# Project Ottertron

A cute, top-down twin-stick shoot-'em-up using **Godot 4.5.2-stable**. Play a cuddly otter firing small glazed doughnuts at Colin, a slow, rotund office worker with a yellow cardigan and a wobbly life-drain aura.

## How to play

1. Install [Godot 4.5.2-stable](https://godotengine.org/download/archive/4.5.2-stable/).
2. Clone or download this private repository.
3. Import `project.godot` in Godot Project Manager, then press **F5**.

| Action | Joypad | Keyboard |
| --- | --- | --- |
| Move | Left stick | WASD |
| Aim and shoot | Right stick (release to stop) | Arrows |
| Restart after victory/defeat | A / Cross | R |

## Wave survival

- Fight **five Colins at a time** in one square arena.
- Clearing *every Colin in the current wave* brings the next wave after a **one-second pause**. Enemies spawn away from the otter and each other and chase across the whole room.
- Defeat **50 enemies total** (ten waves of five) to win. If the otter loses all **12 HP**, the run ends in defeat. The HUD tracks **kills / 50**, current wave, enemies remaining and weapon stats.
- Colin has **2 HP**, moves slowly and channels a wobbly draining aura when close. Each 1-second tick escalates in damage over time; retreating beyond 96px interrupts and resets that channel.
- Damage to either side is displayed as floating combat text. The player and each Colin have overhead health bars.

## Doughnut upgrades

Doughnuts begin **smaller and slower** than before: **0.78× size**, **315 pixels/sec**, **1 damage**.

Three color-coded pickups are visible at the start and additional pickups appear between cleared waves:

| Pickup | Marking | Effect (stackable) |
| --- | --- | --- |
| Damage | Red / D | +1 doughnut damage |
| Speed | Cyan / S | +70px/sec doughnut speed |
| Size | Purple / + | +0.18× doughnut size, including collision radius (max 2.0×) |

Pickups carry only *one* type of upgrade, so the effects can be balanced independently. Each fired doughnut captures the three stats at launch; shots already in the air keep their previous stats.

## Repository

`scenes/` contains reusable player, Colin, doughnut and pickup scenes. `scripts/` contains gameplay systems, aura and floating combat text. `docs/game-design.md`, `docs/roadmap.md`, and `docs/test-plan.md` describe rules, outstanding work and manual tests. `tests/waves_smoke.gd` tests the wave loop and upgrade behaviour in Godot headless mode on every push.

**Artwork status:** the in-game characters are procedural placeholders, not the approved 64×64 sprites. The directional sprite reference, including the mirrored otter UP-RIGHT pose, remains the art goal. No character animation is included.

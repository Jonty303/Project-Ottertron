# Project Ottertron

A cute top-down twin-stick survival shooter for **Godot 4.5.2-stable**. The otter battles coloured office-worker Colins with glazed doughnuts.

## Play

1. Install Godot **4.5.2-stable**, clone this repository and import `project.godot`.
2. Press F5. Move with the **left stick / WASD**, aim and auto-fire using the **right stick / arrow keys**.
3. Press A/Cross or R to restart after the results screen.

## Large arena and environmental dangers

The arena has grown from **960×960 to 1792×1792 world pixels**, with a camera that follows the otter but stays inside the perimeter walls.

- **Rocks and shrubs:** solid obstacles blocking otter, Colins, doughnuts and pencils.
- **Spike traps:** disguised ground plates that pop spikes when the otter steps on them, dealing **2 damage** after a short 0.12-second trigger; retract, cool down and can trigger again when re-entered.
- **Fire pits:** animated flames. Stepping in applies a **5-second burn**, which ticks **1 HP damage every second**, for up to **5 damage** total. Otter is surrounded by animated flames during the burn. Entering another fire pit refreshes the burn duration. The cause of death is reported accurately.
- **Health pickups:** glowing green hearts restore **3 HP**, capped at the original 12 max. One is present at the start; damaged players have a **20% chance** of getting one on a defeated Colin.

## Chaos boons: a benefit with a penalty

After **wave 2, 4, 6 or 8**, a modal gives a choice of three bargains. Pick one to continue; both sides of the selected bargain are **permanent until this run ends**. Repeated choices stack multiplicatively.

| Bad (enemy modifier) | Good (otter modifier) |
| --- | --- |
| **+25% more enemies** in future waves | **+25% doughnut damage** |
| **+30% enemy health** on future spawns | **+20% movement speed** |
| **+25% enemy damage** on future spawns | **+25% doughnut projectile speed** |

Choices affect future wave sizes and newly spawned Colins; damage effects cover their life-drain, pencils and red explosions. The player is paused while choosing. Projectiles are cleared so the break is safe.

### Victory and extra enemies

Rounds 1–9 normally consist of **3 yellow, 1 red and 1 blue Colin** (5 total). Round 10 consists of **1 slow 40-HP boss** (before global health scaling), plus **4 random minions**.

There are **50 base enemies across ten waves**, but extra-enemy boons can increase the actual kill total. Victory now occurs **on fully clearing the tenth wave and its pending red explosions**, rather than prematurely at exactly 50 kills. The HUD tracks kills, waves, boons and weapon stats.

## Retained combat

- Normal yellow Colin: close-range escalating life-drain; no damage explosion on death.
- Red Colin: **0.9-second** silent pulsing warning, mushroom explosion dealing **1–10 damage** in **128px** radius. Hurts the otter and nearby living Colins, allowing chains.
- Blue Colin: keeps distance, shoots pencils roughly every second, friendly-fire enabled. Pencils visibly snap, without floating `SNAP!` wording.
- Boss Colin: large and slow, both life-drain and pencils, four minions.
- All deaths have a cosmetic mushroom cloud; the otter collapses with X-eyes, a tombstone drops, then a result dialog shows **cause of death and survival time**.
- Doughnuts start at **1 damage, 315px/s, 0.78× size**; **1%** of hits crit for double damage. Additional pickups boost damage, speed or size.

## Technical documentation

See [game design](docs/game-design.md), [roadmap](docs/roadmap.md) and [test plan](docs/test-plan.md). GitHub Actions runs headless Godot 4.5.2 import, smoke, wave, enemy variant and environment/boon regression tests.

**Art status:** existing Colins and otter use procedural placeholders; approved 64×64 sprites are still the intended final assets.


## Controller-driven Chaos boons and wider camera (v0.8)

- **Boon controller controls:** D-pad **up/down** or **left stick up/down** to highlight a boon; **A / Cross** to confirm. The left stick uses a re-centre threshold so holding it does not skip multiple boons. Keyboard arrows/WASD plus Enter/Space and mouse buttons also work.
- **Viewport:** **1280×800 (16:10)**, up from 1152×720.
- **Camera:** **0.85× zoom**, showing about **1506×941 world pixels**, instead of 1152×720. Godot camera limits stay enabled, smoothing and offset are disabled, and the camera clamps at all four arena edges so no outside area is shown.
- The HUD, bottom hints, boon panel and results dialogue are laid out for the wider viewport. The arena itself remains **1792×1792**.

Automated camera/controller coverage: `tests/camera_controller_smoke.gd` checks joystick choice behaviour and that the actual visible world rectangle stays within room limits at each corner.

# Project Ottertron

Godot **4.5.2-stable** top-down twin-stick survival game. Run by importing `project.godot` and pressing F5. Left stick/WASD moves, right stick/arrows aims and continuously fires.

## Wave expansion (v0.9)

- **8 enemies per wave** initially. Regular waves comprise **five yellow, two explosive red and one ranged blue Colin**, shuffled. Wave 10 has the oversized 40-HP boss plus **seven random minions**; persistent Chaos penalties may spawn additional enemies. Victory occurs when wave 10 is completely cleared.
- Every enemy appears through a brief blue-white **teleport shimmer**, and each death leaves a permanent, non-colliding **pile of bones**. Red Colin still pulses red before his damaging 128px mushroom-cloud explosion; other death clouds remain cosmetic.

## Expanded random Chaos boon pool

After waves 2, 4, 6 and 8, choose one of **three randomly drawn boons from seven**. Navigate with D-pad or left stick, confirm with A/Cross. Each choice persists for that run. Older bargains remain: Swarm (+25% enemies/+25% doughnut damage), Fortitude (+30% enemy health/+20% otter speed), Ferocity (+25% enemy damage/+25% doughnut speed).

| New boon | Enemy trade-off | Otter benefit |
| --- | --- | --- |
| **Tri-shot** | Enemies +10% HP | Adds ±45° doughnuts alongside the forward shot |
| **Double-shot** | +15% enemies | Adds a second doughnut to **every** firing lane, including diagonals |
| **Piercing** | Enemies +10% damage | Doughnuts pass through distinct Colins, damaging each once; rocks and intact bushes always stop them |
| **Front blast** | Enemies +15% HP | Forward doughnuts create **57px splash** for **40% weapon damage** (minimum 1) on impact; forward shots never pierce while this boon is active |

Angled and duplicate shots can combine for **six simultaneous doughnuts**. If Piercing and Front Blast are both active, **angled lanes pierce** but the **front lanes explode instead**.

## Destructible bushes, traps and fire

- Rocks stay solid forever.
- Bushes absorb **three projectile hits**, shaking visibly on each one. On the third hit, they collapse into a **permanent leaf pile**, no longer blocking movement or shots.
- Spikes are **subtle dark holes** until any Colin or the otter steps onto them. Spikes rise and cause 2 damage per actor, retracting when the final actor steps off. Enemies do not deliberately avoid traps.
- Fire pits ignite enemies **and** the otter for five one-second ticks of 1 damage. Fire is contagious on contact between burning and unburned actors, with a flame effect on both. Burning Colins steer away from other Colins, **not the otter**.
- Existing health pickups restore up to 3 HP.

## Existing combat

Normal Colin uses an escalating life-drain aura, red Colin always explodes after a short pulse, blue fires snapping friendly-fire pencils, and the boss does both. Otter has 12 HP, doughnuts have a 1% critical-double-damage chance. The death sequence ends with crossed-out eyes, a falling gravestone and a results dialogue with death cause and survival time.

## Development

`scripts/` and `scenes/` contain the Godot logic; `tests/` contains headless Godot 4.5.2 CI smoke tests. Main gameplay art is still procedural placeholder art awaiting the approved pixel sprites.


## v1.0 — Black Colin and battlefield awareness

**Black Colin** wears a very dark jumper, stays at range, and throws dark bombs about every **2.1 seconds**. The bombs arc broadly toward the otter's vicinity, with slight random aim error, and explode **one second after launch**. Their 112px-radius blast hits the otter and nearby Colins. Approximately every **8 seconds**, Black Colin also throws a mine into a randomized location. Mines arm on landing and persist until an otter or Colin steps on them, causing a **larger 180px-radius explosion** with friendly fire. Each bomb or mine rolls **1–10 damage**, subject to permanent enemy-damage Chaos modifiers. Colins steer away from armed mines, but can still accidentally trigger them.

Normal eight-enemy waves now include **four yellow, two red, one blue and one black Colin**; round-10 minions can also be black.

**First-wave arrival:** the otter appears alone when play begins. After approximately **2.5 seconds**, enemies begin a 0.7-second teleport entrance; they cannot attack or collide until fully materialized at about 3.2 seconds.

**Hidden flawless-wave scaling:** clear a wave without losing any HP during that wave, and the next wave secretly receives **one additional random Colin**. A later hit suppresses that bonus for the following wave. Existing Chaos extra-enemy modifiers remain separate.

**Offscreen enemies:** living, fully arrived enemies beyond the camera window produce **red arrows on the screen edges** pointing toward their locations. The arrows disappear when an enemy is visible or defeated; menus hide them.

**Persistent tombstones:** after the otter dies, its tombstone is recorded and restored in the same spot when a new run starts via restart. Multiple gravestones can accumulate during a play session; they reset only when the game application closes. Bone piles remain for the entire current run and disappear when that run restarts.

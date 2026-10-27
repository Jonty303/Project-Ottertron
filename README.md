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

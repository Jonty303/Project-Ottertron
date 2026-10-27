# Project Ottertron

A cute top-down twin-stick shoot-'em-up for **Godot 4.5.2-stable**. A cuddly otter fires glazed doughnuts at several varieties of Colin.

## How to run

Install [Godot 4.5.2-stable](https://godotengine.org/download/archive/4.5.2-stable/), clone the repository, import `project.godot`, and press **F5**.

| Control | Gamepad | Keyboard |
|---|---|---|
| Move | Left stick | WASD |
| Aim/fire | Right stick | Arrows |
| Restart after results dialogue | A / Cross | R |

## Enemies and waves

Waves 1–9: **3 normal yellow Colins, 1 explosive red Colin, 1 ranged blue pencil Colin**. Wave 10: **2.2× boss Colin** with 40 HP, life drain and pencils, plus four random minions. **50 kills** wins; loss at zero otter HP.

- **All enemy deaths now display a brief mushroom-cloud animation.** Normal, blue and boss death clouds are cosmetic only.
- **Red Colin** always explodes: an urgent red pulse lasts **0.9 seconds**, with **no text warning**, followed by a **small mushroom cloud and 128px blast ring** dealing a random 1–10 HP to the otter and nearby living Colins. A red killed in the blast can set up a chain reaction. Wave transitions wait for active red explosions; the final 50th kill also waits for any pending detonations before victory.
- **Blue Colin** fires pencils that snap and briefly split into pieces when they hit an enemy, player, or wall. The literal `SNAP!` text has been removed. The damage from a pencil still shows floating numbers; pencils can hurt other Colins.
- **Boss Colin** moves slowly and uses both life drain and pencils.

## Otter death and results

When the otter dies, movement stops, the otter gets **X eyes and collapses**. A **tombstone drops from above and lands beside the body**, followed by a **game-over dialogue** showing the precise damage source (life drain, pencil or red Colin explosion), the **elapsed time survived (mm:ss)**, and number of Colins defeated. Victory also gets a results dialogue with elapsed time.

The death source is recorded at the point damage is applied; no death cause is guessed from the nearest enemy.

## Weapon

Starting doughnuts: **1 damage, 315px/s, 0.78× size**, with a **1% chance of a 2× critical hit**. Pickups independently improve damage (+1), speed (+70px/s) or size (+0.18×); the size stat also scales projectile collision.

See `docs/game-design.md`, `docs/test-plan.md` and the Godot 4.5.2 GitHub Actions workflow. In-game character art remains placeholder procedural art.

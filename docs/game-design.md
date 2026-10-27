# Project Ottertron — game design v0.5

**Target engine:** Godot 4.5.2-stable. Top-down twin-stick shoot-'em-up in square rooms with static placeholder art until production 64×64 directional sprites are prepared.

## Player and doughnuts

- Otter: **12 HP**, independent left-stick movement and right-stick automatic aiming/firing; HP bar and floating damage text.
- Doughnut: **1 starting damage, 315px/s, 0.78× size**. Random **1% critical chance per hit**, dealing **double damage**. Crits show `CRIT!`.
- Collect separate power-ups for damage (+1), speed (+70px/s), size (+0.18×), with an upgradable projectile collision radius.

## Enemy roster

All Colins use the bald/round/glasses base visual; the jumper colour and behavior distinguish the archetypes:

- **Normal Colin (mustard yellow):** **10 HP**, slowly chases and performs close-range life drain. Explosion chance is exactly **0%**.
- **Explosive Colin (red):** **10 HP**, same approach/life-drain behavior. Explosion chance is exactly **100%**. On death he stops, becomes non-colliding and pulses red for **2.0 seconds**, then detonates in a **128px** radius for **1–10 integer damage**. One value is rolled for the blast, affecting the otter and **all living Colins except the deceased shooter/owner** inside the blast. Red victims can trigger further red explosions on their own timers.
- **Pencil Colin (blue):** **10 HP**, does not life-drain or explode. Holds position at range (typically **190–270px**), backs away when approached and fires one pencil about **every 1.0 second** at the otter. Projectiles travel ~390px/s, dealing **1–10 random integer damage** per impact. Pencil hits can hurt **other Colins**, but not their source. They **snap** on any impact with a wall, otter or enemy; show small broken-pencil effect and floating damage.
- **Boss Colin (purple):** **40 HP** (4× regular Colin), visual **2.2× size** with larger collision and HP bar; slower at **33px/s**. Chases, life-drains at a larger 88px start / 145px break distance and fires a pencil approximately every **1.1 seconds**. No death explosion by default.

Life drain retains its escalating once-a-second tick: starts at 1, increases after 3 ticks, caps at 4, and resets after escaping the break radius. The normal and red Colin aura range is 53px start / 96px break.

## Waves

- Waves 1 through 9 consist of **five Colins**: 3 yellow / 1 red / 1 blue, shuffled into new positions. This gives a steady 20% exposure to each new type.
- Wave 10 is **1 boss Colin + 4 random minions**, with independent 55% normal / 25% red / 20% blue rolls.
- All kills count equally toward the **50-kill victory**, including ranged kills from friendly-fire and bomb collateral. With the five-per-wave structure, the boss wave takes the total from 45 to 50.
- The next wave waits for every living enemy to die **and** for any red corpses to explode; then waits 1 second. Game over at zero otter HP; victory at 50 kills. Both outcomes prevent more projectiles, bombs or waves.

## Visual readability

- Overhead bars for all Colins; larger boss bar.
- Coloured jumper variants; red corpse warning and orange explosion, pencil fragments and `SNAP!`, blue floating friendly-fire damage, red otter damage, doughnut `CRIT!`.
- Future work: dedicated coloured directional pixel sprites for each variant; improve projectile/impact art and difficulty balance.

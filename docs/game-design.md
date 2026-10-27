# Project Ottertron — game design v0.4

Engine: **Godot 4.5.2-stable**. A top-down shoot-'em-up in square arenas. Art goal: static 64×64 directional pixel sprites.

## Run structure

- Otter begins with **12 HP** and an overhead health bar. At zero HP, the game ends in defeat.
- **Five Colins** spawn per wave. Clear each wave to earn a power-up and start another wave after a one-second pause.
- Win at **50 enemy kills** (ten waves of five). Explosive corpses still waiting to detonate do **not** allow another wave to spawn.
- HUD tracks player health, wave, remaining living Colins, kills, donut upgrades and active bomb count.
- Enemies spawn away from the otter and pursue it slowly (~68px/s).

## Doughnuts and criticals

- Right stick direction fires; left stick moves independently. Starting damage **1**, speed **315px/s**, size **0.78x**.
- Each doughnut hit independently has a **1% chance of being critical**, for **2x damage**. Critical hits show `CRIT! -N` floating text. Applied numbers reflect actual HP lost, including any overkill cap.
- Critical chance is an exported player/projectile balance parameter and starts at 0.01. Critical strikes currently apply **only to doughnuts**; life-drain ticks and explosions are not critical.
- Red `D` pick-ups add 1 damage, cyan `S` add 70px/s and purple `+` increase size by 0.18x, scaling artwork and collision hitbox; size capped at 2.0x. Effects stack.

## Colin's combat and exploding death

- **10 starting HP** with small overhead health bar. He is a bald, rotund yellow-cardigan office worker; placeholder art in-engine.
- At 53px, starts a wobbly purple aura that drains the otter's HP every second. Damage ramps from 1 to 4 per tick over a continuous channel. Beyond 96px, aura breaks and resets to initial damage.
- **25% chance on death:** Colin does **not** vanish. He stops moving, cannot be attacked again, **glows and pulses red for 2 seconds**, then explodes in a visible expanding **128px-radius** blast.
- Each explosion rolls **one uniformly random integer damage value from 1 to 10**. That number hits the otter and **every other living Colin** whose centre is at most 128px from the detonation; the dead Colin is excluded.
- Explosions can kill other Colins, contributing to the 50-kill target, and these other Colins independently roll their own 25% explosion chance, allowing **chain reactions**.
- Every hit has floating combat text. Explosions additionally display a `BOOM!` indicator. The corpse is non-colliding, immune to further damage and tracked until detonation.
- If the otter dies or reaches 50 kills, the run ends immediately and no pending detonations or additional waves continue.

## Technical direction

- Configurable per-enemy explosion chance, delay, radius, damage bounds; critical chance configurable on player/projectile.
- Wave progression waits for all living enemies and armed corpses to be resolved.
- Replace procedural artwork later with approved sprites (otter UP-RIGHT exact mirror of UP-LEFT).

# Manual test plan — Godot 4.5.2

1. Start a game: 5 Colins, 0/50 kills, otter 12 HP, each Colin **10 HP**.
2. Shoot Colin with 10 normal unpowered doughnuts. Check health bar, floating numbers and death count. With 1% probability, an individual doughnut instead deals double damage and shows bright `CRIT! -2` floating text; power-ups multiply that base damage before a critical doubles it.
3. Repeatedly defeat Colins. On roughly **one in four deaths**, instead of disappearing, Colin should stop, become **red and visibly pulse for 2 seconds**, then produce a red/orange explosion wave reaching **128px**.
4. Stand inside the explosion: a random **1–10 HP** is lost, reflected on the health bar and in floating text. Stand outside 128px: zero explosion damage.
5. Have another Colin next to an exploding body: he should lose the **same randomly rolled HP amount**. If that kills him, he is counted toward the goal. There is a 25% chance he will become another bomb and detonate two seconds later.
6. Clear the final living enemy while he is an armed corpse: the next wave should **wait until he explodes** and then start after a one-second breather.
7. Kill 50 Colins or lose all player HP; no bombs or further waves should continue once the run ends.
8. Confirm damage (red D), speed (cyan S) and size (purple +) pickups still stack and scale future doughnuts, while movement and aura mechanics are unchanged.

Automated regression: `tests/waves_smoke.gd` now covers forced 100%/0% crits, forced 100% explosion, collateral damage, chained bombs, non-colliding corpses, delayed-wave scheduling and 50-kill/defeat behaviour.

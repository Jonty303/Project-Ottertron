# Manual playtest — Godot 4.5.2 v0.9

1. Start the game: **eight** enemies appear with short teleport/shimmer animations.
2. Kill yellow/blue Colins; small permanent bone piles should remain under their mushroom clouds. Kill red Colin; after his explosive animation, bones persist.
3. Shoot a bush three times. It should shake each time, then become a low leaf pile that no longer blocks doughnuts/pencils or movement. Rocks remain solid.
4. Step onto an invisible-looking cluster of holes: spikes pop up and deal 2 damage, retracting when stepped off. Lure enemies onto them to confirm they take damage too.
5. Step into a fire pit, then touch an enemy before the five ticks end. The enemy should ignite and spread burn to another Colin. Burning Colin tries to avoid other enemies without avoiding the player.
6. After clearing wave 2, the boon dialogue shows three randomly chosen options from seven, navigable by gamepad. Repeat across runs to find and take Tri-shot, Double-shot, Piercing and Front Blast.
7. Tri-shot produces three directions (forward plus ±45°). Add Double-shot for six doughnuts (two per direction).
8. With Piercing, a doughnut hits multiple Colins behind one another, once each, but still stops on rocks and intact bushes.
9. Add Front Blast alongside Piercing: **front** doughnuts should burst with reduced AOE damage instead of piercing; angled ones should still pierce. Verify two front blasts when double-shot is also active.
10. Wave 10 has one giant boss and seven random minions, plus bonus enemies if chosen. The last completed wave, rather than reaching a fixed kill count, ends the run.
11. Verify health pickups, controller input, bounded camera, fire pits, boons and tombstone death scene still work.

New headless smoke test: `tests/weapon_terrain_smoke.gd`.


## v1.0 — acceptance tests

1. Start a new run. The otter appears alone for roughly **2.5 seconds**; then eight Colins teleport in and become targetable after the shimmering entrance.
2. Verify one black-jumpered Colin appears in a regular wave. He stays back, throws bombs in the otter's general direction roughly every 2 seconds, with each bomb exploding after **one second**.
3. Wait for a mine: it should land in a randomized spot and remain. Lure any Colin or the otter over the mine to detonate it. Check the mine's **180px blast** is visibly larger than the thrown bomb's 112px blast and affects every living actor in range, including other Colins.
4. Watch enemies near armed mines. They should try to skirt around them, though a mine remains dangerous if a character steps too close.
5. Clear a wave with no loss of health and inspect the following wave: **one extra enemy** silently appears beyond the normal total. Take damage during the next wave and check the following wave returns to its normal count (before any boon-based multipliers).
6. Lure enemies far outside the camera viewport. Red triangular **direction arrows** should appear at the appropriate screen edges and disappear as enemies enter view or die. Ensure arrows cannot extend outside the viewport.
7. Confirm dead enemies continue leaving bone piles throughout the run. Lose the game, wait for the tombstone to land and restart. The previous tombstone should still stand in the same location even in the next run; bone piles should have reset.
8. Verify controller boon navigation, camera world boundaries, health pickups and the boss fight still work.

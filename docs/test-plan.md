# Manual test plan — Godot 4.5.2

1. Run the game. The arena should be much bigger (1792×1792), with camera tracking the otter but not showing the void outside the walls.
2. Walk or shoot into rocks and shrubs. They should stop movement and both pencil/doughnut projectiles. Colins should not spawn inside obstacles.
3. Walk onto a spike plate: spikes pop up, otter takes **2 damage** after about 0.12s, the spikes retract and cannot immediately re-trigger. After leaving and later returning, they should trigger again.
4. Step into a fire pit: animated flames appear around the otter; **no immediate damage**, then **1 HP lost every second for five ticks**. Run away—burn continues. Re-enter a fire pit while burning to refresh the duration. Burn may kill otter and should yield `Fire pit burn` in game-over dialog.
5. Lose some health and collect a glowing green heart: health restores **3**, never above **12**. When full, pickup remains available. After hurting the otter, occasionally a defeated Colin drops a green heart (~20% chance).
6. Clear wave 1: next wave should start after a second. Clear wave 2: a Chaos boon selection blocks the next wave until a choice is made. The interface should accept controller or mouse interaction.
7. Choose **Swarm**: wave 3 should spawn **7 instead of 5** Colins (25% increase, rounded up); doughnuts deal 25% more base damage. This persists across future waves.
8. In a separate run or later boon offer, choose **Fortitude**: new Colins receive 30% more HP, otter movement is 20% faster.
9. Choose **Ferocity**: enemies do 25% more damage (life drain, pencils, red explosion); doughnuts travel 25% faster. Modifiers stack multiplicatively on repeated selections. Every other wave through wave 8 offers another choice.
10. Reach wave 10: boss remains plus at least four minions (possibly extra random minions from Swarm). Victory occurs only after **everyone** in wave 10 dies and all red corpses have exploded, even if kill counter went beyond 50.
11. Confirm game-over tombstone/cause/time, controller restart, critical hits, boss and pencil behaviour survive this update.

CI runs `tests/environment_boons_smoke.gd` plus prior smoke tests under Godot 4.5.2.


## Camera and controller acceptance (v0.8)

1. With the game at 1280×800, verify more arena features are visible at once than at 1152×720 / 1.0× zoom.
2. Walk into all four arena corners and along the walls. The camera must never expose the world beyond the perimeter wall, including near corners.
3. Clear wave 2 using a controller. The first boon is highlighted. D-pad up/down and left-stick up/down cycle focus, looping at either end. Holding the stick steady must not scroll repeatedly.
4. Press the **A/Cross** button to activate the **currently highlighted** boon, rather than always selecting the first. Verify the trade-off is applied and the game resumes.
5. Verify mouse selection and keyboard arrows/WASD + Enter/Space continue working.
6. Check boon and game-over dialogues, HUD and bottom control hint fit comfortably inside 1280×800.

Automated regression `tests/camera_controller_smoke.gd` simulates joypad events and verifies actual camera screen bounds at all four arena corners.

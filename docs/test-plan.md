# Manual test plan — Godot 4.5.2

1. Run with F5; HUD should read **0 / 50 kills**, **wave 1**, **5 enemies**, otter **12/12 HP**.
2. Confirm five Colins spawn at safe distances and pursue the otter; all have small health bars and their own escalating life-drain auras.
3. Defeat one Colin with two basic hits. Confirm kill count becomes **1**, four Colins remain and no new wave starts yet.
4. Defeat the other four. Wave clear message appears, followed about a second later by five fresh Colins and wave number **2**.
5. Repeat until 50 kills. Exactly ten five-enemy waves should have appeared. Victory stops gameplay and no additional wave spawns; R or joypad A restarts at zero kills.
6. Let the otter lose all twelve HP before winning. Defeat stops gameplay and blocks new waves; restart works.
7. Compare starting doughnuts to the prior version: visibly **smaller**, speed **315px/s** (previously 370), damage **1**.
8. Collect each of the three pickups initially near the player: **red D** increases damage to 2; **cyan S** raises speed to 385px/s; **purple +** raises projectile size from 0.78× to 0.96×. Confirm a larger *collision hitbox*, not just artwork.
9. Clear waves for another pickup of cycling type; additional upgrades stack, and existing in-flight projectiles retain their original stats.
10. Verify floating hit numbers, aura tick damage, and channel break if >96px away.

**Automatic coverage:** GitHub Actions runs `tests/waves_smoke.gd` in headless Godot 4.5.2 as part of the validation workflow. Physical controller feel and sprite appearance still require manual playtesting.

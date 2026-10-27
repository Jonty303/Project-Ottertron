# Manual test plan — Godot 4.5.2

1. Start a run. Wave 1 contains exactly **five** Colins: **3 yellow**, **1 red**, **1 blue**. All normal-sized variants show 10 HP.
2. Defeat a yellow Colin. He disappears immediately and **never** explodes.
3. Defeat a red Colin. He stays in place, pulses red for about **2 seconds**, then detonates in a **128px radius** and inflicts **1–10 damage** on every living Colin and the otter in range. Dead corpses cannot be attacked. A red Colin killed by an explosion produces a possible chain reaction.
4. Approach a blue Colin. He should maintain distance and shoot a pencil about **once each second**, even when other Colins are nearby. A pencil hitting the otter deals a random **1–10 damage** and snaps. A pencil hitting a different Colin (yellow, red, blue or boss) damages them too. A pencil hitting a wall should snap without damage.
5. Every wave 1–9 should contain **3 yellow, 1 red, 1 blue**, with randomized positions; wave transitions wait for red corpse explosions to resolve.
6. On **round 10**, there should be **one oversized purple boss Colin plus four random minions**. The boss is at least double normal size, has **40 HP**, moves noticeably more slowly, fires pencils, and can life-drain the otter up close.
7. Defeat the boss and four minions to reach **50 kills** and win. Otter death before then ends the run. Restart with R / A.
8. Confirm the previous upgrades, 1% critical chance, health bars and floating combat text still function.

Automated tests: `tests/waves_smoke.gd` and `tests/variants_smoke.gd` run in GitHub Actions with Godot 4.5.2.

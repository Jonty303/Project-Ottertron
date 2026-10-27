# Godot 4.5.2 manual test checklist

1. Start play: 5 Colins, 12 otter HP, weapons and power-ups unchanged.
2. Kill any yellow, blue or boss Colin: a short mushroom cloud appears at the death location, with **no area damage**.
3. Kill red Colin: he flashes a more alarming red for **approximately 0.9 seconds** with **no text warning**, then produces a compact mushroom-shaped cloud and expanding ring. The 128px damaging radius still applies for 1–10 HP to the otter and living Colins.
4. Red chain reactions still occur. Wave transition waits for red explosions to resolve; if the final enemy at 50 kills is red, victory also waits for the final blast.
5. Watch pencils hit walls, the otter, and other Colins: pencils break into two halves and disappear, with no `SNAP!` text. Damage numbers continue to appear.
6. Let the otter die from **life-drain**: otter's eyes become Xs, body tilts/squashes, tombstone falls beside him, and then game-over dialog appears. Cause states which variant's aura did the damage; elapsed time and kills are shown.
7. Repeat dying to a **blue pencil**, **boss pencil**, and **red explosion** to verify accurate death causes.
8. Restart from dialogue with the button, A/Cross or R. Victory also shows a results dialogue including time survived.
9. Confirm 50 kills, boss round, critical doughnuts, health bars and upgrades still behave as before.

CI executes the full headless test suite; manual testing is recommended for animation timing and dialogue layout.

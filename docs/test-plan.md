# Manual test checklist — Godot 4.5.2

1. Import the repository with Godot **4.5.2-stable**; run `scenes/main.tscn` (F5).
2. Check the otter's overhead bar starts full at **12/12** and Colin at **2/2**.
3. Move with left stick and fire with right stick; verify shooting stops when the right stick is released.
4. Hit Colin with one ordinary doughnut: an orange/yellow **-1** appears and his health bar becomes 1/2. A second hit defeats him.
5. Restart. Let Colin get within ~53px; see the purple wobbly aura and **LIFE DRAIN** status. Every 1 second a red damage number appears above the otter; HP reduces correctly.
6. Remain channelled: the first three ticks each do 1 damage, the fourth does 2. Confirm the ramp continues up to 4 per tick.
7. Move away until farther than 96px: **DRAIN BROKEN** appears; stop taking damage. Let Colin approach again and verify first tick returns to 1 after a fresh second.
8. Restart and collect the glowing power-up northwest of the player: see **POWER UP** text; HUD changes doughnut damage from 1 to 2 and speed from 370 to 450. Verify the next ordinary hit defeats Colin.
9. Lose all 12 HP and confirm the defeat screen and R/A restart. Validate keyboard WASD + arrow fallback too.

**Known scope:** Procedural art only; no sprite animations. Test checklist is provided but not yet executed in-engine by the assistant.

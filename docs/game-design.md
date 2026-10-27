# Project Ottertron — v0.9 gameplay design

**Engine:** Godot 4.5.2. **Arena:** 1792×1792; camera 1280×800 at 0.85 zoom with hard room bounds.

## Enemies

- Wave 1–9: **8 Colins** — five regular yellow, two red explosive and one blue ranged.
- Wave 10: one oversized slow boss Colin with life drain, pencils and 40 starting HP, plus seven random minions.
- Additional Colins may be added by persistent Chaos modifiers; completion is after fully clearing wave 10, not a fixed kill count.
- All Colins **teleport into the arena** with a brief 0.7s glowing entry effect, during which their collisions and AI are disabled.
- Every defeated Colin leaves a **permanent bone pile** (no collision), whether death is from doughnuts, fire, pencils, spikes or red blasts. A red Colin's pile appears after its delayed damaging explosion, while all types also get a mushroom-cloud effect.

## Weapon boons

One of three randomized options is chosen after each even wave 2/4/6/8. Each boon grants a player benefit and a permanent enemy trade-off.

Existing: +25% more enemies/+25% doughnut damage, +30% enemy HP/+20% otter movement, +25% enemy damage/+25% doughnut speed.

New:
- **Tri-shot:** +10% enemy HP; shoots 45° left and right in addition to front.
- **Double-shot:** +15% enemies; duplicates every lane (single or triple) using slight lateral spacing.
- **Piercing:** +10% enemy damage; shots continue through multiple distinct Colins, hitting each once, but stop at rocks and intact bushes.
- **Front blast:** +15% enemy HP; front-lane shots burst for 40% damage (minimum 1) to *other* Colins within **57px** at any impact. They cannot pierce even with Piercing active. Diagonal shots continue to pierce.

A player may gain combinations of these upgrades, with existing projectile size, speed, damage and critical modifiers applied to each donut.

## Environmental rules

- Rocks cannot be destroyed. Bushes have exactly **three projectile hit points** (hits, not weapon damage). They shake for ~0.26s when shot and remain as low, non-blocking leaf piles when destroyed. Both pencils and doughnuts count as hits.
- Spike traps show only small dark holes while inactive. Entry by **any actor** triggers a ~0.12s pop-up which damages otter and Colins for 2 once each; spikes stay up while occupied and retract when the last occupant leaves. AI does not pathfind around traps.
- Fire pits apply a **five-second burn** to otter or Colin, one point every second. Burn spreads via physical contact from burning to unburned actors; contact does not continually reset ongoing burns. Burning Colins avoid neighbouring Colins but still pursue/target the otter. Player and enemy both show animated flames while burning.
- Healing pickups retain 3 HP restore with maximum player health cap.

## Next

Balance eight-enemy crowds, render effects with approved pixel assets, tune fire contagion, navigation around rocks, and add audio.

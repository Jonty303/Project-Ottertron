# Project Ottertron

A cute top-down twin-stick shoot-'em-up in **Godot 4.5.2-stable**. Play as a cuddly otter who fires glazed doughnuts at Colin, a slow, bald, rotund office worker in glasses and a yellow cardigan.

## Run

1. Install [Godot 4.5.2-stable](https://godotengine.org/download/archive/4.5.2-stable/) (standard version).
2. Clone or download this private repository.
3. Open `project.godot` in Godot's Project Manager.
4. Press **F5** to play.

| Action | Controller | Keyboard test |
| --- | --- | --- |
| Move | Left stick | WASD |
| Aim and shoot continuously | Right stick | Arrow keys |
| Restart after the round | A / Cross | R |

## Current playable mechanics

- Square room with blocking walls, camera follow and **static placeholder art**.
- **Otter:** 12 HP; overhead health bar and HUD.
- **Colin:** 2 HP; small overhead health bar; slowly approaches the otter.
- **Doughnuts:** 1 starting damage and 370px/second starting speed; automatically fire while the aim stick is pushed. A glowing pickup in the room increases damage to 2 and speed to 450px/second.
- **Colin's life drain:** Begins within **53px** and stops Colin moving while channelled. The wobbly purple aura ticks every **1 second** at damage 1, then ramps by 1 after each 3 completed ticks (max 4/tick). At more than **96px** separation, the channel breaks and its damage ramp resets. Colin can then approach again.
- **Floating combat text:** Doughnut hits, incoming life-drain damage, aura starting/breaking and pickup messages float upward.

Balancing knobs are exported on the player, Colin, doughnut and power-up scenes. The pickup demonstrates a power-up now; additional pickup types can follow.

## Source structure

- `project.godot` and `ENGINE_VERSION`: pinned target engine version (Godot configuration stores the 4.5 feature compatibility tag).
- `scenes/`: player, Colin, doughnut, pickup and game scene.
- `scripts/`: actors, projectile behaviour, aura, combat text, health bars and room.
- `docs/game-design.md`: gameplay and art specifications.
- `docs/roadmap.md`: next steps.

## Artwork

The current in-engine characters are procedural placeholders. The approved **64×64** pixel-art otter and Colin character reference remains the target, including the corrected otter UP-RIGHT directional view as the mirror of UP-LEFT. The reference concept image has not been imported as separate transparent 64×64 assets, and there is no animation in this prototype.

## Validation

Changes are checked into GitHub, but a full Godot 4.5.2 editor/controller regression test still needs to be run locally. Please report any parser errors or gameplay oddities from F5 so they can be corrected.

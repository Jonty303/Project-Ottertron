# Project Ottertron

A small top-down twin-stick shoot-'em-up built with **Godot 4.x**.

Play as a cuddly otter who fires glazed doughnuts at **Colin**, a bald, rotund office worker with glasses and a yellow cardigan.

## Run it

1. Install the standard Godot 4.x editor.
2. Clone or download this repository.
3. Import `project.godot` in Godot Project Manager.
4. Press **F5**.

The first playable prototype includes a square room with collision walls, analogue movement, directional doughnut shooting, chasing Colin, HP and restart.

| Input | Gamepad | Keyboard for development |
| --- | --- | --- |
| Move | Left stick | WASD |
| Aim and fire continuously | Right stick | Arrow keys |
| Restart after victory/defeat | A / Cross (south face button) | R |

Deflect the right stick to aim **and shoot**. Release it to stop shooting. Left and right sticks work independently.

## Project layout

- `project.godot` — Godot project configuration
- `scenes/` — reusable player, Colin, doughnut and entry scenes
- `scripts/` — movement, combat, art placeholders and room logic
- `docs/game-design.md` — agreed v0.1 mechanics and art direction
- `docs/roadmap.md` — progression toward the approved sprite artwork

## Art status

The prototype draws simple static characters directly in Godot so it runs without any imported image files. The approved otter/Colin 64×64 pixel-art character sheet from the design conversation is the **visual target**; the current procedural placeholders are **not** the final assets. There is no animation in v0.1.

## Scope and compatibility

Designed for Godot 4.x. This initial source drop has not been run in the Godot editor by the assistant; please use the editor to import and test on your controller.

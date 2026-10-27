# Project Ottertron — game design v0.1

## Premise

A lighthearted top-down shoot-'em-up. A cuddly, cute brown otter attacks office-worker enemies by firing small glazed doughnuts.

## Player — otter

- Art target: clear 64×64 static pixel sprite with rounded, cuddly silhouette, brown fur, cream muzzle/belly, big eyes and small whiskers.
- No animation initially; eight directional static views are the visual target.
- Movement: independent analogue left stick, full 360-degree direction.
- Shooting: aim and automatically shoot continuously while the right stick is deflected; release to stop.
- Can move and shoot in different directions simultaneously.

## Enemy — Colin

- Bald, rotund office worker; large dark glasses, mustard-yellow cardigan, shirt/tie, brown trousers.
- Static 64×64 pixel sprite, eight directional views target.
- Prototype AI: walks slowly towards the otter, then deals contact damage.
- Three doughnut hits to defeat in the prototype.

## Projectile — glazed doughnut

- Small round glazed pastry shot in the direction of right stick.
- Travels in a straight line until hitting an enemy, wall or reaching maximum lifetime.

## Environment

- Square rooms of varying sizes. First playable room: 960×960 world units.
- Solid walls and simple top-down camera.
- Subsequent work: configurable room sizes, multiple Colins and environmental variety.

## Input

- Gamepad left stick: movement.
- Gamepad right stick: aim + continuous shooting (aim deadzone 0.45).
- Optional keyboard fallback: WASD + arrows; R to restart.

## Design reference

The approved sprite concept is the revised conversation sheet in which **otter UP-RIGHT is a horizontal mirror of UP-LEFT**, with Colin's directional views otherwise unchanged. Character artwork is not yet imported as individual transparent production sprites; the current code draws provisional static placeholders.

## Explicit non-goals for v0.1

- No sprite animation.
- No multiplayer.
- No level editor, inventory, complex AI, or save system.

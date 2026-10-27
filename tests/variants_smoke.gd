extends SceneTree
## Headless deterministic tests for distinct Colin archetypes and pencil friendly-fire.

const GAME = preload("res://scenes/main.tscn")
const PENCIL = preload("res://scenes/pencil.tscn")
const PENCIL_SCRIPT = preload("res://scripts/pencil.gd")
var failures: int = 0

func _initialize() -> void:
    call_deferred("_run")

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error("OTTERTRON VARIANT TEST FAILED: " + description)

func _run() -> void:
    var game = GAME.instantiate()
    root.add_child(game)
    await process_frame
    var counts: Dictionary = {"normal": 0, "explosive": 0, "ranged": 0}
    var red: Node2D
    var blue: Node2D
    var yellow: Node2D
    for enemy in game.enemies:
        counts[enemy.variant] += 1
        check(enemy.max_health == 10, "All ordinary Colins have 10 HP")
        if enemy.variant == "normal":
            yellow = enemy
            check(is_zero_approx(enemy.explosion_chance), "Yellow Colin cannot explode")
            check(enemy._uses_aura and not enemy._shoots_pencils, "Yellow has aura only")
        elif enemy.variant == "explosive":
            red = enemy
            check(is_equal_approx(enemy.explosion_chance, 1.0), "Red always explodes")
            check(enemy._uses_aura and not enemy._shoots_pencils, "Red keeps life drain")
            check(enemy.get_node("Art").jumper_color == Color("#c3343c"), "Red jumper")
        elif enemy.variant == "ranged":
            blue = enemy
            check(is_zero_approx(enemy.explosion_chance), "Blue never explodes")
            check(not enemy._uses_aura and enemy._shoots_pencils, "Blue uses pencils, no aura")
            check(enemy.get_node("Art").jumper_color == Color("#377dc8"), "Blue jumper")
            check(is_equal_approx(enemy.pencil_interval, 1.0), "Blue fires every second")
    check(counts["normal"] == 3 and counts["explosive"] == 1 and counts["ranged"] == 1,
        "Each regular wave contains 3 yellow, 1 red, 1 blue")

    # The ranged enemy backs away when the player is too close.
    blue.set_physics_process(false)
    blue.position = game.player.position + Vector2(100, 0)
    blue._physics_process(0.1)
    check(blue.velocity.x > 0.0, "Blue retreats when otter approaches")
    blue.position = game.player.position + Vector2(400, 0)
    blue._physics_process(0.1)
    check(blue.velocity.x < 0.0, "Blue moves forward when out of firing comfort range")

    # Trigger a pencil emission from the blue Colin and test a fixed 5-damage hit.
    blue._physics_process(1.0)
    var fired: Array = get_nodes_in_group("projectiles").filter(
        func(projectile: Node) -> bool: return projectile.get_script() == PENCIL_SCRIPT)
    check(fired.size() >= 1, "Ranged Colin fires a pencil")
    if fired.size() >= 1:
        var projectile = fired.back()
        projectile.minimum_damage = 5
        projectile.maximum_damage = 5
        projectile._on_body_entered(game.player)
        check(game.player.health == 7, "Pencil deals 5 damage to the otter")

    # The shooter itself must be immune, but every other Colin can take damage.
    var friendly = PENCIL.instantiate()
    friendly.shooter = blue
    friendly.minimum_damage = 4
    friendly.maximum_damage = 4
    game.add_child(friendly)
    var snap_counter: Dictionary = {"value": 0}
    friendly.snapped.connect(func(_at: Vector2) -> void: snap_counter["value"] += 1)
    friendly._on_body_entered(blue)
    check(not friendly._spent, "Pencil does not snap on its own shooter")
    var previous_hp: int = yellow.health
    friendly._on_body_entered(yellow)
    check(yellow.health == previous_hp - 4, "Pencil damages another Colin")
    check(snap_counter["value"] == 1, "Pencil snaps exactly once on a hit")

    # Pencil also snaps on walls, without damage.
    var wall = StaticBody2D.new()
    game.add_child(wall)
    var wall_pencil = PENCIL.instantiate()
    game.add_child(wall_pencil)
    var wall_snap_counter: Dictionary = {"value": 0}
    wall_pencil.snapped.connect(func(_at: Vector2) -> void: wall_snap_counter["value"] += 1)
    wall_pencil._on_body_entered(wall)
    check(wall_snap_counter["value"] == 1, "Pencil snaps when striking a wall")

    # Red Colin leaves behind a timed, harmless-to-touch explosive corpse.
    red.set_physics_process(false)
    red.explosion_damage_min = 1
    red.explosion_damage_max = 1
    red.position = Vector2(350, 350)
    red.take_damage(red.max_health)
    check(game.pending_bombs.has(red), "Red Colin leaves a bomb corpse")
    check(red.health == 0 and red.collision_layer == 0, "Bomb corpse is dead and non-colliding")
    check(game.kills == 1, "Red Colin counts immediately as a kill")
    check(is_equal_approx(red.explosion_delay, 0.9), "Red fuse lasts 0.9 seconds")
    red._process(0.80)
    check(game.pending_bombs.has(red), "Red corpse still pulsing before 0.9 seconds")
    red._process(0.11)
    check(not game.pending_bombs.has(red), "Red corpse explodes after 0.9 seconds")

    game.queue_free()
    await process_frame
    if failures == 0:
        print("OTTERTRON VARIANT TEST PASSED: roles, colors, pencils, friendly fire, timed red blast")
    quit(0 if failures == 0 else 1)

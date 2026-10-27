extends SceneTree
## Headless logic regression for the 50-kill loop and three independent upgrades.

const GAME = preload("res://scenes/main.tscn")
const DOUGHNUT = preload("res://scenes/doughnut.tscn")
var failures: int = 0

func _initialize() -> void:
    call_deferred("_run")

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error("OTTERTRON TEST FAILED: " + description)

func _run() -> void:
    var game = GAME.instantiate()
    root.add_child(game)
    await process_frame

    check(game.wave == 1, "Starts on wave 1")
    check(game.enemies.size() == 5, "Starts with five Colins")
    check(game.kills == 0, "Starts at zero kills")
    check(game.player.health == 12, "Otter starts at twelve health")
    check(game.player.doughnut_speed == 315.0, "Shots start slower")
    check(is_equal_approx(game.player.doughnut_size, 0.78), "Shots start smaller")

    var kind_set: Dictionary = {}
    for pickup in get_nodes_in_group("power_ups"):
        kind_set[pickup.upgrade_kind] = true
    check(kind_set.has("damage") and kind_set.has("speed") and kind_set.has("size"),
        "All three pickups available in starting room")

    var first_enemy = game.enemies[0]
    first_enemy.take_damage(2)
    check(game.kills == 1, "One Colin death counts as one kill")
    check(game.enemies.size() == 4, "Enemy tracking removes the fallen Colin")
    check(game._wave_timer < 0.0, "Wave doesn't advance with enemies still alive")

    var powerup_values := {"damage": 1.0, "speed": 70.0, "size": 0.18}
    for kind in ["damage", "speed", "size"]:
        game._spawn_powerup(kind, Vector2(300, 210))
        var pickup = get_nodes_in_group("power_ups").back()
        pickup._on_body_entered(game.player)
    check(game.player.doughnut_damage == 2, "Damage pickup adds +1 damage")
    check(is_equal_approx(game.player.doughnut_speed, 385.0),
        "Speed pickup adds +70 pixels per second")
    check(is_equal_approx(game.player.doughnut_size, 0.96),
        "Size pickup adds +0.18 size multiplier")

    var shot = DOUGHNUT.instantiate()
    shot.size_multiplier = game.player.doughnut_size
    game.add_child(shot)
    var scaled_shape = shot.get_node("CollisionShape2D").shape as CircleShape2D
    check(is_equal_approx(shot.get_node("Art").scale.x, 0.96),
        "Size upgrade scales the artwork")
    check(is_equal_approx(scaled_shape.radius, 9.6),
        "Size upgrade scales the collision radius")
    shot.queue_free()

    for expected_wave in range(1, 11):
        check(game.wave == expected_wave, "Expected wave %d" % expected_wave)
        var enemies_this_wave = game.enemies.duplicate()
        var desired_count: int = 4 if expected_wave == 1 else 5
        check(enemies_this_wave.size() == desired_count,
            "Wave %d contains the expected remaining Colins" % expected_wave)
        for enemy in enemies_this_wave:
            enemy.take_damage(enemy.max_health)
        check(game.enemies.is_empty(), "All enemies cleared from wave %d" % expected_wave)
        check(game.kills == expected_wave * 5, "Cumulative kills after wave %d" % expected_wave)
        if expected_wave < 10:
            check(game._wave_timer > 0.0, "Next wave is scheduled after clearing wave %d" % expected_wave)
            game._wave_timer = 0.001
            await process_frame
            await process_frame
            check(game.enemies.size() == 5, "Exactly five more Colins spawned")
        else:
            check(game._round_finished and game._win, "50 kills ends the game in victory")
            check(game.kills == 50, "Victory occurs on exactly 50 kills")
            check(game._wave_timer <= 0.0, "No wave is scheduled after victory")
    game.queue_free()
    await process_frame

    var defeat_game = GAME.instantiate()
    root.add_child(defeat_game)
    await process_frame
    defeat_game.player.take_damage(12)
    check(defeat_game._round_finished and not defeat_game._win,
        "Otter death ends game in defeat")
    check(not defeat_game.player.is_physics_processing(),
        "Controls stop on defeat")
    var dead_game_kills: int = defeat_game.kills
    for enemy in defeat_game.enemies.duplicate():
        enemy.take_damage(enemy.max_health)
    check(defeat_game.kills == dead_game_kills, "Kills do not count after defeat")
    check(defeat_game._wave_timer < 0.0, "No new wave schedules after death")
    defeat_game.queue_free()
    await process_frame

    if failures == 0:
        print("OTTERTRON TEST PASSED: 10 waves / 50 kills, defeat, all three upgrades, scaled hitbox")
    quit(0 if failures == 0 else 1)

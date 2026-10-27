extends SceneTree
## Environment, hazard, healing and persistent Chaos boon regressions.

const GAME = preload("res://scenes/main.tscn")
const HEALTH = preload("res://scripts/health_pickup.gd")
var failures: int = 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("OTTERTRON ENVIRONMENT TEST FAILED: " + message)

func _run() -> void:
    print("ENV TRACE: starting hazard tests")
    var game = GAME.instantiate()
    root.add_child(game)
    await process_frame

    check(is_equal_approx(game.ROOM_SIDE, 1792.0), "Arena is 1792 by 1792")
    check(get_nodes_in_group("obstacles").size() >= 12, "Rocks and plants exist")
    check(get_nodes_in_group("hazards").size() >= 8, "Spike traps and fire pits exist")
    var obstacle = get_nodes_in_group("obstacles")[0]
    check(obstacle.collision_layer == 8, "Obstacles physically block projectiles and actors")
    var cameras: Array = game.player.get_children().filter(func(node: Node) -> bool: return node is Camera2D)
    check(cameras.size() == 1, "Player has a camera")
    if cameras.size() == 1:
        check(cameras[0].limit_right == 868, "Camera stays inside bigger walls")

    var spike = get_nodes_in_group("hazards").filter(
        func(node: Node) -> bool: return node.get_script().resource_path.ends_with("spike_trap.gd"))[0]
    var hp: int = game.player.health
    spike._on_body_entered(game.player)
    spike._on_body_entered(game.player)
    spike._process(0.14)
    check(game.player.health == hp - 2, "Spike pops for exactly 2 damage")
    check(game.player.last_damage_source == "Pop-up spike trap", "Spike death source recorded")
    spike._on_body_exited(game.player)
    spike._process(0.7)
    check(not spike.triggered, "Spikes retract after popping")

    var fire = get_nodes_in_group("hazards").filter(
        func(node: Node) -> bool: return node.get_script().resource_path.ends_with("fire_pit.gd"))[0]
    fire._on_body_entered(game.player)
    check(game.player.burn_ticks_left == 5, "Fire pit applies five tick burn")
    hp = game.player.health
    game.player._tick_burn(0.99)
    check(game.player.health == hp, "Burn deals no damage immediately")
    game.player._tick_burn(0.01)
    check(game.player.health == hp - 1, "Burn deals exactly one damage after second one")
    for i in range(4):
        game.player._tick_burn(1.0)
    check(game.player.health == hp - 5, "Burn deals exactly five damage")
    check(game.player.burn_ticks_left == 0, "Burn ends after fifth tick")
    check(game.player.last_damage_source == "Fire pit burn", "Burn has clear death source")
    game.player.apply_burn(5)
    game.player.get_node("BurnFX")._process(0.1)
    check(game.player.get_node("BurnFX").visible, "Burning otter has flame animation")
    game.player.burn_ticks_left = 0

    var health = HEALTH.new()
    game.add_child(health)
    hp = game.player.health
    health._on_body_entered(game.player)
    check(game.player.health == mini(12, hp + 3), "Health pickup restores three HP")
    game.player.heal(99)
    check(game.player.health == game.player.max_health, "Health cannot exceed maximum")

    print("ENV TRACE: hazard and healing assertions complete")
    game.queue_free()
    await process_frame

    # Drive two complete waves into a real boon selection.
    print("ENV TRACE: starting boon wave tests")
    var boon_game = GAME.instantiate()
    root.add_child(boon_game)
    await process_frame
    for enemy in boon_game.enemies.duplicate():
        enemy.explosion_chance = 0.0
        enemy.take_damage(enemy.max_health)
    check(boon_game.wave == 1, "First wave cleared")
    boon_game._wave_timer = 0.001
    await process_frame
    await process_frame
    print("ENV TRACE: spawned wave 2")
    check(boon_game.wave == 2, "Second wave spawned")
    for enemy in boon_game.enemies.duplicate():
        enemy.explosion_chance = 0.0
        enemy.take_damage(enemy.max_health)
    check(boon_game._boon_open and boon_game._boon_overlay.visible,
        "Second wave clear opens choice dialogue")
    check(boon_game._wave_timer < 0.0, "Wave pauses until boon is selected")
    check(boon_game.player.status_paused, "Player state pauses during choice")
    print("ENV TRACE: choosing swarm")
    boon_game._choose_boon("swarm")
    check(not boon_game._boon_open, "Selecting closes the modal")
    check(boon_game.boons_chosen.size() == 1, "Choice recorded permanently")
    check(is_equal_approx(boon_game.enemy_spawn_multiplier, 1.25), "Extra enemies +25%")
    check(is_equal_approx(boon_game.player.doughnut_damage_multiplier, 1.25),
        "Player damage +25%")
    boon_game._wave_timer = 0.001
    await process_frame
    await process_frame
    print("ENV TRACE: spawned wave 3")
    check(boon_game.wave == 3, "Third wave spawns after boon")
    check(boon_game.enemies.size() == 10, "Eight enemies increased by 25% to ten")

    # Further choices persist and affect subsequently spawned enemies.
    boon_game._offer_boon()
    boon_game._choose_boon("fortitude")
    check(is_equal_approx(boon_game.enemy_health_multiplier, 1.30),
        "Enemy health +30% globally")
    check(is_equal_approx(boon_game.player.movement_multiplier, 1.20),
        "Otter movement +20% permanently")
    boon_game._offer_boon()
    boon_game._choose_boon("ferocity")
    check(is_equal_approx(boon_game.enemy_damage_multiplier, 1.25),
        "Enemy damage +25% globally")
    check(is_equal_approx(boon_game.player.doughnut_speed_multiplier, 1.25),
        "Doughnut projectile speed +25% permanently")

    for enemy in boon_game.enemies.duplicate():
        enemy.explosion_chance = 0.0
        enemy.take_damage(enemy.max_health)
    boon_game._wave_timer = 0.001
    await process_frame
    await process_frame
    check(boon_game.wave == 4, "Wave controller continues after stacking boons")
    check(boon_game.enemies.size() == 10, "Extra enemies persist into later waves")
    for enemy in boon_game.enemies:
        var expected_base: int = 40 if enemy.variant == "boss" else 10
        check(enemy.max_health == ceili(float(expected_base) * 1.30),
            "New enemies inherit global extra health")
        check(is_equal_approx(enemy.damage_multiplier, 1.25),
            "New enemies inherit global extra damage")

    print("ENV TRACE: all assertions complete")
    boon_game.queue_free()
    await process_frame

    if failures == 0:
        print("OTTERTRON ENVIRONMENT TEST PASSED: big arena, terrain, traps, burn, healing, stacked boons")
    quit(0 if failures == 0 else 1)

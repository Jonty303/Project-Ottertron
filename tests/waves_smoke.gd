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
    check(game.enemies[0].max_health == 10, "Colin begins with ten HP")
    var red_count: int = 0
    for enemy in game.enemies:
        if enemy.variant == "explosive":
            red_count += 1
            check(is_equal_approx(enemy.explosion_chance, 1.0), "Red Colin always explodes")
        else:
            check(is_equal_approx(enemy.explosion_chance, 0.0), "Yellow and blue Colins never explode")
    check(red_count == 1, "Exactly one red Colin in each regular wave")
    check(game.enemies[0].explosion_damage_min == 1 and game.enemies[0].explosion_damage_max == 10,
        "Explosion damage ranges from one to ten")
    check(is_equal_approx(game.player.doughnut_critical_chance, 0.01),
        "Doughnut critical hit chance defaults to 1%")
    check(game.player.doughnut_speed == 315.0, "Shots start slower")
    check(is_equal_approx(game.player.doughnut_size, 0.78), "Shots start smaller")

    var kind_set: Dictionary = {}
    for pickup in get_nodes_in_group("power_ups"):
        kind_set[pickup.upgrade_kind] = true
    check(kind_set.has("damage") and kind_set.has("speed") and kind_set.has("size"),
        "All three pickups available in starting room")

    var first_enemy = game.enemies[0]
    first_enemy.explosion_chance = 0.0
    first_enemy.take_damage(10)
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
        var bosses: Array = game.enemies.filter(func(enemy: Node2D) -> bool: return enemy.variant == "boss")
        if expected_wave == 10:
            check(bosses.size() == 1, "Final wave has exactly one boss Colin")
            if bosses.size() == 1:
                check(bosses[0].max_health == 40, "Boss has four times the normal health")
                check(bosses[0].get_node("Art").scale.x >= 2.0, "Boss is at least twice as large")
                check(bosses[0]._uses_aura and bosses[0]._shoots_pencils, "Boss uses both attack types")
        else:
            check(bosses.is_empty(), "Only wave 10 has a boss")
        var enemies_this_wave = game.enemies.duplicate()
        var desired_count: int = 4 if expected_wave == 1 else 5
        check(enemies_this_wave.size() == desired_count,
            "Wave %d contains the expected remaining Colins" % expected_wave)
        for enemy in enemies_this_wave:
            enemy.explosion_chance = 0.0
            enemy.take_damage(enemy.max_health)
        check(game.enemies.is_empty(), "All enemies cleared from wave %d" % expected_wave)
        check(game.kills == expected_wave * 5, "Cumulative kills after wave %d" % expected_wave)
        if expected_wave < 10:
            if expected_wave % 2 == 0:
                check(game._boon_open, "Chaos boon offered after even wave %d" % expected_wave)
                check(game._wave_timer <= 0.0, "Wave pauses for the boon")
                game._choose_boon("fortitude")
                check(not game._boon_open, "Boon selection closes the choice")
            check(game._wave_timer > 0.0, "Next wave schedules after clearing wave %d" % expected_wave)
            game._wave_timer = 0.001
            await process_frame
            await process_frame
            check(game.enemies.size() == 5, "Five enemies spawn when extra-enemy boon not selected")
        else:
            check(game._round_finished and game._win, "50 kills ends the game in victory")
            check(game.kills == 50, "Victory occurs on exactly 50 kills")
            check(game._wave_timer <= 0.0, "No wave is scheduled after victory")
    game.queue_free()
    await process_frame

    var defeat_game = GAME.instantiate()
    root.add_child(defeat_game)
    await process_frame
    defeat_game.player.take_damage(12, "Blue Colin's pencil")
    check(defeat_game._round_finished and not defeat_game._win,
        "Otter death ends game in defeat")
    check(defeat_game.player.last_damage_source == "Blue Colin's pencil",
        "Death cause is recorded")
    check(defeat_game.player.art.is_dead, "Crossed eyes appear on death")
    check(defeat_game.player.death_animation_started, "Collapse animation begins")
    check(not defeat_game._game_over_overlay.visible,
        "Game-over dialog waits until the gravestone lands")
    defeat_game._death_sequence_remaining = 0.01
    defeat_game._process(0.02)
    check(is_instance_valid(defeat_game._tombstone), "Tombstone appears by the otter")
    if is_instance_valid(defeat_game._tombstone):
        defeat_game._tombstone.finish_drop()
        check(defeat_game._game_over_overlay.visible, "Game-over dialog appears after stone lands")
        check(defeat_game._game_over_details.text.contains("Blue Colin's pencil"),
            "Dialog explains what killed the otter")
        check(defeat_game._game_over_details.text.contains("Time survived:"),
            "Dialog shows survival time")
    check(not defeat_game.player.is_physics_processing(),
        "Controls stop on defeat")
    var dead_game_kills: int = defeat_game.kills
    for enemy in defeat_game.enemies.duplicate():
        enemy.explosion_chance = 0.0
        enemy.take_damage(enemy.max_health)
    check(defeat_game.kills == dead_game_kills, "Kills do not count after defeat")
    check(defeat_game._wave_timer < 0.0, "No new wave schedules after death")
    defeat_game.queue_free()
    await process_frame


    # Deterministic critical hit tests: force 100% and 0% rates on real projectiles.
    var combat_game = GAME.instantiate()
    root.add_child(combat_game)
    await process_frame
    var dummy = combat_game.enemies[0]
    dummy.explosion_chance = 0.0
    dummy.set_physics_process(false)
    var critical_shot = DOUGHNUT.instantiate()
    critical_shot.damage = 3
    critical_shot.critical_chance = 1.0
    combat_game.add_child(critical_shot)
    var critical_result: Dictionary = {}
    critical_shot.damage_dealt.connect(func(_at: Vector2, amount: int, critical: bool) -> void:
        critical_result["damage"] = amount
        critical_result["critical"] = critical
    )
    critical_shot._on_body_entered(dummy)
    check(dummy.health == 4, "Guaranteed crit deals twice 3 damage")
    check(critical_result.get("critical", false), "Critical hit is flagged for floating text")
    check(critical_result.get("damage", 0) == 6, "Critical hit reports the applied damage")

    var normal_shot = DOUGHNUT.instantiate()
    normal_shot.damage = 2
    normal_shot.critical_chance = 0.0
    combat_game.add_child(normal_shot)
    var normal_result: Dictionary = {}
    normal_shot.damage_dealt.connect(func(_at: Vector2, amount: int, critical: bool) -> void:
        normal_result["damage"] = amount
        normal_result["critical"] = critical
    )
    normal_shot._on_body_entered(dummy)
    check(dummy.health == 2, "Zero-percent crit deals normal damage")
    check(not normal_result.get("critical", true), "Ordinary shot is not marked critical")
    check(normal_result.get("damage", 0) == 2, "Normal hit reports applied damage")

    # Force a delayed explosion and a chain reaction, without depending on random chance.
    var bomb = combat_game.enemies[1]
    var nearby = combat_game.enemies[2]
    var chain = combat_game.enemies[3]
    bomb.position = Vector2(80, 0)
    nearby.position = Vector2(90, 0)
    chain.position = Vector2(110, 20)
    dummy.position = Vector2(-300, -300)
    combat_game.enemies[4].position = Vector2(320, 320)
    for colin in combat_game.enemies:
        colin.set_physics_process(false)
        colin.explosion_chance = 0.0
    bomb.explosion_chance = 1.0
    bomb.explosion_delay = 2.0
    bomb.explosion_damage_min = 4
    bomb.explosion_damage_max = 4
    chain.explosion_chance = 1.0
    chain.explosion_damage_min = 4
    chain.explosion_damage_max = 4
    chain.health = 4
    chain.health_bar.set_health(4, chain.max_health)
    var initial_player_hp: int = combat_game.player.health
    bomb.take_damage(10)
    check(combat_game.kills == 1, "The explosive Colin counts as killed immediately")
    check(combat_game.pending_bombs.size() == 1, "Dead bomb waits to explode")
    check(not bomb.is_in_group("enemies"), "A dead bomb cannot be damaged again")
    check(bomb.collision_layer == 0, "Dead bombs have no collision")
    check(combat_game.player.health == initial_player_hp, "No premature blast damage")
    bomb._process(1.9)
    check(combat_game.player.health == initial_player_hp, "Blast not triggered before two seconds")
    bomb._process(0.11)
    check(combat_game.player.health == initial_player_hp - 4, "Blast damages otter inside 128px")
    check(nearby.health == 6, "Blast damages a nearby living Colin")
    check(combat_game.kills == 2, "Blast kill of another Colin counts toward goal")
    check(combat_game.pending_bombs.size() == 1, "Blast kill can start another bomb")
    chain._process(2.01)
    check(combat_game.player.health == initial_player_hp - 8, "Chain blast damages otter once more")
    check(nearby.health == 2, "Chain blast damages other living Colins")
    check(combat_game.pending_bombs.is_empty(), "All explosions eventually resolve")
    check(dummy.health == 2, "Enemies outside the radius are unharmed")
    check(combat_game.get_children().any(func(node: Node) -> bool:
        return node.get_script() == preload("res://scripts/mushroom_cloud.gd")),
        "Enemy deaths create a mushroom cloud effect")
    combat_game.queue_free()
    await process_frame

    # Clearing the final enemy while it is still a bomb must NOT start the next wave.
    var delayed_game = GAME.instantiate()
    root.add_child(delayed_game)
    await process_frame
    var last_bomb = delayed_game.enemies.back()
    for enemy in delayed_game.enemies.duplicate():
        if enemy == last_bomb:
            continue
        enemy.explosion_chance = 0.0
        enemy.take_damage(enemy.max_health)
    last_bomb.explosion_chance = 1.0
    last_bomb.explosion_damage_min = 1
    last_bomb.explosion_damage_max = 1
    last_bomb.position = Vector2(340, 340)
    last_bomb.take_damage(last_bomb.max_health)
    check(delayed_game.enemies.is_empty(), "Wave's final Colin is defeated")
    check(delayed_game.pending_bombs.size() == 1, "Last defeated Colin is still a bomb")
    check(delayed_game._wave_timer < 0.0, "No next wave while a bomb remains")
    last_bomb._process(2.01)
    check(delayed_game.pending_bombs.is_empty(), "Last delayed explosion resolves")
    check(delayed_game._wave_timer > 0.0, "Next wave schedules after the final blast")
    delayed_game.queue_free()
    await process_frame

    if failures == 0:
        print("OTTERTRON TEST PASSED: 50 kills, defeat, upgrades, 1% critical setup, delayed blasts and chain reactions")
    quit(0 if failures == 0 else 1)

extends SceneTree
## Black Colin, delayed opening, flawless scaling, tombstones and edge-arrow checks.
const GAME = preload("res://scenes/main.tscn")
const BLACK_BOMB = preload("res://scripts/black_bomb.gd")
const TOMBSTONE = preload("res://scripts/tombstone.gd")
var failures: int = 0

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, label: String) -> void:
    if not value:
        failures += 1
        push_error("OTTERTRON V1.0 TEST FAILED: " + label)

func _run() -> void:
    var history = root.get_node("RunHistory")
    history.tombstones.clear()
    var game = GAME.instantiate()
    root.add_child(game)
    await process_frame
    check(game.player.health == 12 and game.enemies.size() == 8,
        "Otter appears at full HP before wave-one teleport")
    check(game.enemies.all(func(enemy: Node2D) -> bool:
        return enemy.spawn_delay > 2.0 and not enemy.get_node("HealthBar").visible),
        "No enemy appears in the first two seconds")
    var black_list = game.enemies.filter(func(enemy: Node2D) -> bool:
        return enemy.variant == "black")
    check(black_list.size() == 1, "One Black Colin in first wave")
    var black = black_list[0]
    check(black.get_node("Art").jumper_color == Color("#252630"), "Black jumper colour")
    black._process(3.3)
    black.position = game.player.position + Vector2(340, 0)
    black.set_physics_process(false)
    black._physics_process(2.2)
    var bombs = get_nodes_in_group("black_ordnance").filter(func(node: Node) -> bool:
        return node.kind == "bomb")
    check(bombs.size() >= 1, "Black Colin throws a timed bomb")
    if not bombs.is_empty():
        var bomb = bombs.back()
        check(is_equal_approx(bomb.fuse, 1.0), "Bomb detonates one second after throwing")
        bomb.min_damage = 3
        bomb.max_damage = 3
        var from: Vector2 = bomb.global_position
        bomb._process(0.5)
        check(bomb.is_queued_for_deletion() == false, "Bomb remains armed before the fuse")
        bomb._process(0.51)
        check(bomb.is_queued_for_deletion(), "Bomb explodes after one second")

    var mine_target: Vector2 = game.player.global_position + Vector2(180, 90)
    game._on_black_ordnance_requested(black.position, mine_target, true, black)
    var mines = get_nodes_in_group("armed_mines")
    check(mines.size() >= 1, "Black Colin deploys a mine")
    if not mines.is_empty():
        var mine = mines.back()
        check(is_equal_approx(mine.mine_radius, 180.0) and mine.mine_radius > mine.normal_radius,
            "Mine has a larger blast than a thrown bomb")
        mine.min_damage = 4
        mine.max_damage = 4
        mine._process(0.45)
        check(mine.armed and not mine.is_queued_for_deletion(),
            "Mine lands and waits for a passerby")
        black.position = mine.global_position + Vector2(50, 0)
        var steer: Vector2 = black._avoid_mines(Vector2.UP)
        check(steer.x > 0.1, "Enemy steers away from armed mines")
        var yellow = game.enemies.filter(func(enemy: Node2D) -> bool:
            return enemy.variant == "normal")[0]
        yellow.position = mine.global_position + Vector2(70, 0)
        yellow.spawn_delay = 0.0
        var before_enemy_hp: int = yellow.health
        var before_player_hp: int = game.player.health
        game.player.position = mine.global_position
        mine._process(0.02)
        check(mine.is_queued_for_deletion(), "Mine detonates on player contact")
        check(yellow.health == before_enemy_hp - 4, "Mine blast injures nearby Colins")
        check(game.player.health == before_player_hp - 4, "Mine blast injures the otter")
        check(game.player.last_damage_source == "Black Colin's mine",
            "Mine identifies the cause of player damage")

    var arrows = game._red_arrows
    for enemy in game.enemies:
        enemy.spawn_delay = 3.0
    black.spawn_delay = 0.0
    black.position = Vector2(840, 0)
    game.player.position = Vector2.ZERO
    var shown: Array[Dictionary] = arrows.indicators()
    check(shown.size() == 1, "One offscreen enemy produces one red arrow")
    if not shown.is_empty():
        var first: Dictionary = shown[0]
        check(first["direction"].x > 0.8, "Arrow points toward right-side enemy")
        check(first["position"].x < 1280.0, "Arrow stays within the viewport edge")
    black.position = Vector2.ZERO
    check(arrows.indicators().is_empty(), "Arrow disappears when enemy is onscreen")

    game.player.take_damage(12, "Test gravestone")
    game._death_sequence_remaining = 0.01
    game._process(0.02)
    check(is_instance_valid(game._tombstone), "Death sequence creates tombstone")
    if is_instance_valid(game._tombstone):
        game._tombstone.finish_drop()
    check(history.tombstones.size() == 1, "Landed gravestone recorded across runs")
    var saved: Vector2 = history.tombstones[0]
    game.queue_free()
    await process_frame
    var new_run = GAME.instantiate()
    root.add_child(new_run)
    await process_frame
    var stones = new_run.get_children().filter(func(child: Node) -> bool:
        return child.get_script() == TOMBSTONE)
    check(stones.any(func(stone: Node2D) -> bool:
        return stone.position == saved and stone.is_landed),
        "New game retains old tombstone beside the earlier corpse")
    new_run.queue_free()
    await process_frame
    history.tombstones.clear()

    var flawless = GAME.instantiate()
    root.add_child(flawless)
    await process_frame
    for enemy in flawless.enemies.duplicate():
        enemy.explosion_chance = 0.0
        enemy.take_damage(enemy.max_health)
    check(flawless._next_wave_flawless_bonus == 1,
        "Untouched otter earns secret extra enemy in next wave")
    flawless._wave_timer = -1.0
    flawless._spawn_wave()
    await process_frame
    check(flawless.wave == 2 and flawless.enemies.size() == 9,
        "Wave two silently contains nine instead of eight enemies")
    flawless.player.take_damage(1, "Test wound")
    for enemy in flawless.enemies.duplicate():
        enemy.explosion_chance = 0.0
        enemy.take_damage(enemy.max_health)
    check(flawless._next_wave_flawless_bonus == 0,
        "Taking damage prevents the hidden bonus")
    flawless.queue_free()
    await process_frame
    if failures == 0:
        print("OTTERTRON V1.0 TEST PASSED: bomb, mine, first-wave delay, flawless scaling, tombstones, arrows")
    quit(0 if failures == 0 else 1)

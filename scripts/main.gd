extends Node2D
## Wave survival: five Colins per wave, win at 50 defeats, or lose at zero HP.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const COLIN_SCENE: PackedScene = preload("res://scenes/colin.tscn")
const DOUGHNUT_SCENE: PackedScene = preload("res://scenes/doughnut.tscn")
const POWER_UP_SCENE: PackedScene = preload("res://scenes/power_up.tscn")
const FLOATING_TEXT = preload("res://scripts/floating_text.gd")

const ROOM_SIDE: float = 960.0
const WALL_THICKNESS: float = 28.0
const TARGET_KILLS: int = 50
const INITIAL_WAVE_SIZE: int = 5
const FOLLOWUP_WAVE_SIZE: int = 5
const WAVE_DELAY: float = 1.0
const ENEMY_SPAWN_PLAYER_DISTANCE: float = 225.0
const ENEMY_SPAWN_SEPARATION: float = 90.0

var player
var hud: Label
var enemies: Array[Node2D] = []
var kills: int = 0
var wave: int = 0
var _round_finished: bool = false
var _win: bool = false
var _wave_timer: float = -1.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    _rng.randomize()
    _create_wall(Vector2(0, -ROOM_SIDE / 2.0), Vector2(ROOM_SIDE, WALL_THICKNESS))
    _create_wall(Vector2(0, ROOM_SIDE / 2.0), Vector2(ROOM_SIDE, WALL_THICKNESS))
    _create_wall(Vector2(-ROOM_SIDE / 2.0, 0), Vector2(WALL_THICKNESS, ROOM_SIDE))
    _create_wall(Vector2(ROOM_SIDE / 2.0, 0), Vector2(WALL_THICKNESS, ROOM_SIDE))

    player = PLAYER_SCENE.instantiate()
    player.position = Vector2.ZERO
    add_child(player)
    player.fire_requested.connect(_on_player_fire)
    player.health_changed.connect(_on_health_changed)
    player.damage_taken.connect(_on_player_damage_taken)
    player.doughnut_stats_changed.connect(_on_doughnut_stats_changed)
    player.defeated.connect(_on_player_defeated)

    var camera := Camera2D.new()
    camera.zoom = Vector2.ONE
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0
    player.add_child(camera)
    camera.make_current()

    var interface := CanvasLayer.new()
    add_child(interface)
    hud = Label.new()
    hud.position = Vector2(24, 16)
    hud.add_theme_font_size_override("font_size", 20)
    hud.add_theme_color_override("font_outline_color", Color("#0b1218"))
    hud.add_theme_constant_override("outline_size", 3)
    interface.add_child(hud)

    var instructions := Label.new()
    instructions.text = "MOVE: left stick / WASD      FIRE: right stick / arrows      UPGRADES: D damage, S speed, + size"
    instructions.position = Vector2(24, 678)
    instructions.add_theme_font_size_override("font_size", 15)
    interface.add_child(instructions)

    # Make all three power-up types available immediately for testing.
    _spawn_powerup("damage", Vector2(-105, -125))
    _spawn_powerup("speed", Vector2(0, -155))
    _spawn_powerup("size", Vector2(105, -125))
    _spawn_wave()

func _draw() -> void:
    var start: float = -ROOM_SIDE / 2.0
    var finish: float = ROOM_SIDE / 2.0
    draw_rect(Rect2(start, start, ROOM_SIDE, ROOM_SIDE), Color("#263540"))
    for coordinate in range(int(start), int(finish), 64):
        draw_line(Vector2(coordinate, start), Vector2(coordinate, finish), Color("#30414a"), 1)
        draw_line(Vector2(start, coordinate), Vector2(finish, coordinate), Color("#30414a"), 1)
    draw_rect(Rect2(start, start, ROOM_SIDE, ROOM_SIDE), Color("#526575"), false, WALL_THICKNESS)

func _process(delta: float) -> void:
    if _round_finished:
        if Input.is_key_pressed(KEY_R) or _restart_button_pressed():
            get_tree().reload_current_scene()
        return
    if _wave_timer > 0.0:
        _wave_timer -= delta
        if _wave_timer <= 0.0:
            _wave_timer = -1.0
            _spawn_wave()

func _restart_button_pressed() -> bool:
    var pads: Array[int] = Input.get_connected_joypads()
    return not pads.is_empty() and Input.is_joy_button_pressed(pads[0], JOY_BUTTON_A)

func _create_wall(at: Vector2, wall_size: Vector2) -> void:
    var body := StaticBody2D.new()
    body.position = at
    body.collision_layer = 8
    body.collision_mask = 0
    var collider := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = wall_size
    collider.shape = rectangle
    body.add_child(collider)
    add_child(body)

func _spawn_wave() -> void:
    if _round_finished or kills >= TARGET_KILLS or not enemies.is_empty():
        return
    wave += 1
    var requested: int = INITIAL_WAVE_SIZE if wave == 1 else FOLLOWUP_WAVE_SIZE
    var count: int = mini(requested, TARGET_KILLS - kills)
    for i in range(count):
        var enemy = COLIN_SCENE.instantiate()
        enemy.position = _find_enemy_spawn()
        enemy.target = player
        add_child(enemy)
        enemies.append(enemy)
        enemy.defeated.connect(_on_enemy_defeated.bind(enemy))
        enemy.aura_started.connect(_on_aura_started.bind(enemy))
        enemy.aura_broken.connect(_on_aura_broken.bind(enemy))
        enemy.aura_tick.connect(_on_aura_tick.bind(enemy))
    _floating_text(player.global_position + Vector2(0, -78),
        "WAVE %d" % wave, Color("#fff0ac"))
    _update_hud()

func _find_enemy_spawn() -> Vector2:
    var inner_limit: float = ROOM_SIDE * 0.5 - WALL_THICKNESS - 46.0
    for attempt in range(100):
        var candidate: Vector2 = Vector2(
            _rng.randf_range(-inner_limit, inner_limit),
            _rng.randf_range(-inner_limit, inner_limit)
        )
        if _is_good_enemy_spawn(candidate):
            return candidate
    # A safe candidate is overwhelmingly likely with five enemies, but handle bad luck.
    for candidate in [
        Vector2(-inner_limit, -inner_limit), Vector2(inner_limit, -inner_limit),
        Vector2(-inner_limit, inner_limit), Vector2(inner_limit, inner_limit)
    ]:
        if _is_good_enemy_spawn(candidate):
            return candidate
    return Vector2(inner_limit, 0.0)

func _is_good_enemy_spawn(candidate: Vector2) -> bool:
    if candidate.distance_to(player.position) < ENEMY_SPAWN_PLAYER_DISTANCE:
        return false
    for enemy in enemies:
        if is_instance_valid(enemy) and candidate.distance_to(enemy.position) < ENEMY_SPAWN_SEPARATION:
            return false
    for item in get_tree().get_nodes_in_group("power_ups"):
        if candidate.distance_to(item.position) < 50.0:
            return false
    return true

func _on_enemy_defeated(enemy: Node2D) -> void:
    # Each Colin emits once; tracking prevents a simultaneous double-count.
    if _round_finished or not enemies.has(enemy):
        return
    enemies.erase(enemy)
    kills += 1
    if kills >= TARGET_KILLS:
        _end_round(true)
    elif enemies.is_empty():
        _wave_timer = WAVE_DELAY
        _floating_text(player.global_position + Vector2(0, -82),
            "WAVE CLEARED", Color("#c5f3b7"))
        _spawn_wave_reward()
    _update_hud()

func _spawn_wave_reward() -> void:
    # Rotate rewards so all three upgrade types recur throughout the run.
    var cycle := ["damage", "speed", "size"]
    var kind: String = cycle[(wave - 1) % cycle.size()]
    var point: Vector2 = _find_reward_position()
    _spawn_powerup(kind, point)

func _find_reward_position() -> Vector2:
    var inner_limit: float = ROOM_SIDE * 0.5 - WALL_THICKNESS - 45.0
    for attempt in range(40):
        var offset := Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU))
        var point: Vector2 = player.position + offset * _rng.randf_range(90.0, 140.0)
        point.x = clampf(point.x, -inner_limit, inner_limit)
        point.y = clampf(point.y, -inner_limit, inner_limit)
        var clear: bool = point.distance_to(player.position) > 55.0
        for other in get_tree().get_nodes_in_group("power_ups"):
            if point.distance_to(other.position) < 58.0:
                clear = false
        if clear:
            return point
    return Vector2(clampf(player.position.x + 120.0, -inner_limit, inner_limit),
        clampf(player.position.y - 120.0, -inner_limit, inner_limit))

func _spawn_powerup(kind: String, at: Vector2) -> void:
    var power_up = POWER_UP_SCENE.instantiate()
    power_up.upgrade_kind = kind
    power_up.position = at
    add_child(power_up)
    power_up.collected.connect(_on_powerup_collected)

func _on_player_fire(direction: Vector2) -> void:
    if _round_finished:
        return
    var shot = DOUGHNUT_SCENE.instantiate()
    shot.direction = direction
    shot.damage = player.doughnut_damage
    shot.speed = player.doughnut_speed
    shot.size_multiplier = player.doughnut_size
    shot.position = player.position + direction * (26.0 + 12.0 * player.doughnut_size)
    add_child(shot)
    shot.damage_dealt.connect(_on_doughnut_damage)

func _on_doughnut_damage(at: Vector2, amount: int) -> void:
    _floating_text(at + Vector2(0, -50), "-%d" % amount, Color("#ffd56b"))
    _update_hud()

func _on_player_damage_taken(amount: int) -> void:
    _floating_text(player.global_position + Vector2(0, -55), "-%d" % amount, Color("#ff7a91"))

func _on_health_changed(_current_health: int) -> void:
    _update_hud()

func _on_doughnut_stats_changed(_damage: int, _speed: float, _size: float) -> void:
    _update_hud()

func _on_powerup_collected(at: Vector2, kind: String, amount: float) -> void:
    var message: String = ""
    match kind:
        "damage":
            message = "+%d DONUT DMG" % roundi(amount)
        "speed":
            message = "+%d DONUT SPEED" % roundi(amount)
        "size":
            message = "+%.2f DONUT SIZE" % amount
    _floating_text(at + Vector2(0, -42), message, Color("#8fe7fa"))
    _update_hud()

func _on_aura_started(enemy: Node2D) -> void:
    if _round_finished:
        return
    _floating_text(enemy.global_position + Vector2(0, -65), "LIFE DRAIN", Color("#d3a7ff"))

func _on_aura_broken(enemy: Node2D) -> void:
    if _round_finished:
        return
    _floating_text(enemy.global_position + Vector2(0, -65), "DRAIN BROKEN", Color("#aeeada"))

func _on_aura_tick(_damage: int, _enemy: Node2D) -> void:
    _update_hud()

func _on_player_defeated() -> void:
    _end_round(false)

func _end_round(victory: bool) -> void:
    if _round_finished:
        return
    _round_finished = true
    _win = victory
    _wave_timer = -1.0
    player.set_physics_process(false)
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.set_physics_process(false)
            enemy.set_process(false)
    for projectile in get_tree().get_nodes_in_group("projectiles"):
        projectile.queue_free()
    _update_hud()

func _floating_text(at: Vector2, message: String, color: Color) -> void:
    var popup = FLOATING_TEXT.new()
    popup.configure(message, color)
    add_child(popup)
    popup.global_position = at

func _update_hud() -> void:
    if hud == null or not is_instance_valid(player):
        return
    var stats: String = "OTTER %d/%d HP   |   KILLS %d/%d   |   WAVE %d   |   LEFT %d\nDOUGHNUT %d DMG   |   %d px/s   |   %.2fx SIZE" % [
        player.health, player.max_health, kills, TARGET_KILLS,
        wave, enemies.size(), player.doughnut_damage, roundi(player.doughnut_speed), player.doughnut_size
    ]
    if _round_finished:
        hud.text = stats + ("\nVICTORY! 50 COLINS DEFEATED!" if _win else
            "\nDEFEAT! THE OTTER WAS DEFEATED!") + "   |   R or A/Cross to restart"
    elif _wave_timer > 0.0:
        hud.text = stats + "\nWAVE CLEAR — NEXT WAVE INCOMING"
    else:
        hud.text = stats

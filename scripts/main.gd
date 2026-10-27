extends Node2D
## Ten larger waves; persistent Chaos boons, teleport entry and permanent remains.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const COLIN_SCENE: PackedScene = preload("res://scenes/colin.tscn")
const DOUGHNUT_SCENE: PackedScene = preload("res://scenes/doughnut.tscn")
const PENCIL_SCENE: PackedScene = preload("res://scenes/pencil.tscn")
const PENCIL_SNAP = preload("res://scripts/pencil_snap.gd")
const POWER_UP_SCENE: PackedScene = preload("res://scenes/power_up.tscn")
const FLOATING_TEXT = preload("res://scripts/floating_text.gd")
const MUSHROOM_CLOUD = preload("res://scripts/mushroom_cloud.gd")
const TOMBSTONE = preload("res://scripts/tombstone.gd")
const TERRAIN_OBSTACLE = preload("res://scripts/terrain_obstacle.gd")
const SPIKE_TRAP = preload("res://scripts/spike_trap.gd")
const FIRE_PIT = preload("res://scripts/fire_pit.gd")
const HEALTH_PICKUP = preload("res://scripts/health_pickup.gd")
const TELEPORT_FX = preload("res://scripts/teleport_fx.gd")
const BONE_PILE = preload("res://scripts/bone_pile.gd")
const DOUGHNUT_BLAST_FX = preload("res://scripts/doughnut_blast_fx.gd")

const ROOM_SIDE: float = 1792.0
const WALL_THICKNESS: float = 28.0
const TARGET_KILLS: int = 80 # Base ten-wave target; bonus spawns raise kill count.
const LAST_WAVE: int = 10
const INITIAL_WAVE_SIZE: int = 8
const FOLLOWUP_WAVE_SIZE: int = 8
const WAVE_DELAY: float = 1.0
const ENEMY_SPAWN_PLAYER_DISTANCE: float = 225.0
const ENEMY_SPAWN_SEPARATION: float = 90.0

var player
var hud: Label
var _boon_overlay: ColorRect
var _boon_open: bool = false
var _boon_buttons: Array[Button] = []
var _boon_selection_index: int = 0
var _boon_stick_latched: bool = false
const BOON_POOL: Array[String] = ["swarm", "fortitude", "ferocity", "angle", "double", "pierce", "blast"]
var boon_order: Array[String] = ["swarm", "fortitude", "ferocity"]
const CAMERA_ZOOM: float = 0.85
var boons_chosen: Array[String] = []
var enemy_spawn_multiplier: float = 1.0
var enemy_health_multiplier: float = 1.0
var enemy_damage_multiplier: float = 1.0
var _game_over_overlay: ColorRect
var _game_over_title: Label
var _game_over_details: Label
var _tombstone: Node2D
var _elapsed_survival: float = 0.0
var _survival_at_end: float = 0.0
var _death_sequence_remaining: float = -1.0
var _death_cause: String = ""
var enemies: Array[Node2D] = []
var pending_bombs: Array[Node2D] = []
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
    _place_environment()

    var camera := Camera2D.new()
    camera.zoom = Vector2.ONE * CAMERA_ZOOM
    # Hard viewport limits: prevent camera smoothing/offset from exposing
    # the unrendered world outside the room on any edge or corner.
    camera.position_smoothing_enabled = false
    camera.limit_enabled = true
    camera.limit_smoothed = false
    camera.offset = Vector2.ZERO
    camera.limit_left = -int(ROOM_SIDE * 0.5) + int(WALL_THICKNESS)
    camera.limit_right = int(ROOM_SIDE * 0.5) - int(WALL_THICKNESS)
    camera.limit_top = -int(ROOM_SIDE * 0.5) + int(WALL_THICKNESS)
    camera.limit_bottom = int(ROOM_SIDE * 0.5) - int(WALL_THICKNESS)
    player.add_child(camera)
    camera.make_current()

    var interface := CanvasLayer.new()
    add_child(interface)
    hud = Label.new()
    hud.position = Vector2(24, 16)
    hud.add_theme_font_size_override("font_size", 17)
    hud.add_theme_color_override("font_outline_color", Color("#0b1218"))
    hud.add_theme_constant_override("outline_size", 3)
    interface.add_child(hud)

    var instructions := Label.new()
    instructions.text = "MOVE: left stick / WASD      FIRE: right stick / arrows      UPGRADES: D damage, S speed, + size"
    instructions.position = Vector2(24, 758)
    instructions.add_theme_font_size_override("font_size", 15)
    interface.add_child(instructions)
    _create_game_over_dialog(interface)
    _create_boon_dialog(interface)

    # Make all three power-up types available immediately for testing.
    _spawn_powerup("damage", Vector2(-105, -125))
    _spawn_powerup("speed", Vector2(0, -155))
    _spawn_powerup("size", Vector2(105, -125))
    _spawn_health_pickup(Vector2(-200, 180))
    _spawn_wave()


func _place_environment() -> void:
    # Avoid the central starting area; props collide with actors and projectiles.
    var rocks: Array[Vector2] = [
        Vector2(-580, -370), Vector2(-270, -570), Vector2(300, -540),
        Vector2(630, -260), Vector2(-590, 250), Vector2(380, 365),
        Vector2(640, 540)
    ]
    var plants: Array[Vector2] = [
        Vector2(-660, 0), Vector2(-350, 485), Vector2(90, 570),
        Vector2(560, 65), Vector2(150, -420), Vector2(-350, 365)
    ]
    for at in rocks:
        var obstacle = TERRAIN_OBSTACLE.new()
        obstacle.kind = "rock"
        obstacle.collision_radius = 35.0
        obstacle.position = at
        add_child(obstacle)
    for at in plants:
        var obstacle = TERRAIN_OBSTACLE.new()
        obstacle.kind = "plant"
        obstacle.collision_radius = 39.0
        obstacle.position = at
        add_child(obstacle)

    for at in [
        Vector2(-435, -145), Vector2(470, -405), Vector2(305, 610),
        Vector2(-640, 550), Vector2(685, 260)
    ]:
        var spikes = SPIKE_TRAP.new()
        spikes.position = at
        add_child(spikes)

    for at in [Vector2(-315, 80), Vector2(475, 245), Vector2(115, -655)]:
        var fire = FIRE_PIT.new()
        fire.position = at
        add_child(fire)

func _spawn_health_pickup(at: Vector2) -> void:
    var pickup = HEALTH_PICKUP.new()
    pickup.position = at
    add_child(pickup)
    pickup.collected.connect(_on_health_pickup_collected)

func _on_health_pickup_collected(at: Vector2, amount: int) -> void:
    _floating_text(at + Vector2(0, -40), "+%d HP" % amount, Color("#99f9ac"))
    _update_hud()

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
        if _death_sequence_remaining >= 0.0:
            _death_sequence_remaining -= delta
            if _death_sequence_remaining < 0.0:
                _start_tombstone_drop()
        elif _game_over_overlay.visible and (Input.is_key_pressed(KEY_R) or _restart_button_pressed()):
            get_tree().reload_current_scene()
        return
    if _boon_open:
        return
    _elapsed_survival += delta
    if _wave_timer > 0.0:
        _wave_timer -= delta
        if _wave_timer <= 0.0:
            _wave_timer = -1.0
            _spawn_wave()

func _physics_process(_delta: float) -> void:
    if _round_finished or _boon_open or not is_instance_valid(player) or player.health <= 0:
        return
    # Burning actors are contagious on physical contact. Newly infected actors
    # become burning sources; no timer refresh happens every frame.
    var living: Array[Node2D] = [player]
    for enemy in enemies:
        if is_instance_valid(enemy) and enemy.health > 0 and enemy.spawn_delay <= 0.0:
            living.append(enemy)
    for i in range(living.size()):
        for j in range(i + 1, living.size()):
            var a: Node2D = living[i]
            var b: Node2D = living[j]
            var reach: float = 84.0 if (a.is_in_group("enemies") and a.variant == "boss") or (b.is_in_group("enemies") and b.variant == "boss") else 47.0
            if a.global_position.distance_squared_to(b.global_position) > reach * reach:
                continue
            if a.burn_ticks_left > 0 and b.burn_ticks_left <= 0:
                b.receive_contagious_burn()
            elif b.burn_ticks_left > 0 and a.burn_ticks_left <= 0:
                a.receive_contagious_burn()

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
    if _round_finished or wave >= LAST_WAVE or _boon_open or not enemies.is_empty() or not pending_bombs.is_empty():
        return
    wave += 1
    var requested: int = INITIAL_WAVE_SIZE if wave == 1 else FOLLOWUP_WAVE_SIZE
    var roster: Array[String] = _build_wave_roster()
    var count: int = roster.size()
    for i in range(count):
        var enemy = COLIN_SCENE.instantiate()
        enemy.variant = roster[i]
        enemy.health_multiplier = enemy_health_multiplier
        enemy.damage_multiplier = enemy_damage_multiplier
        enemy.position = _find_enemy_spawn()
        enemy.target = player
        enemy.spawn_delay = 0.70
        add_child(enemy)
        var teleport = TELEPORT_FX.new()
        teleport.position = enemy.position
        add_child(teleport)
        enemies.append(enemy)
        enemy.defeated.connect(_on_enemy_defeated.bind(enemy))
        enemy.explosion_requested.connect(_on_explosion_requested.bind(enemy))
        enemy.pencil_requested.connect(_on_pencil_requested)
        enemy.aura_started.connect(_on_aura_started.bind(enemy))
        enemy.aura_broken.connect(_on_aura_broken.bind(enemy))
        enemy.aura_tick.connect(_on_aura_tick.bind(enemy))
    _floating_text(player.global_position + Vector2(0, -78),
        "WAVE %d" % wave, Color("#fff0ac"))
    _update_hud()

func _build_wave_roster() -> Array[String]:
    # Waves 1-9 are deliberately predictable in difficulty: mostly yellow,
    # 20% red explosives, 20% blue pencil throwers.
    var roster: Array[String] = []
    if wave == 10:
        roster.append("boss")
        for i in range(7):
            roster.append(_roll_minion_type())
    else:
        roster.assign(["normal", "normal", "normal", "normal", "normal", "explosive", "explosive", "ranged"])
    var extra: int = maxi(0, ceili(float(requested_wave_size()) * enemy_spawn_multiplier) - roster.size())
    for i in range(extra):
        roster.append(_roll_minion_type())
    roster.shuffle()
    return roster

func requested_wave_size() -> int:
    return INITIAL_WAVE_SIZE if wave == 1 else FOLLOWUP_WAVE_SIZE

func _roll_minion_type() -> String:
    var roll: float = _rng.randf()
    if roll < 0.55:
        return "normal"
    if roll < 0.80:
        return "explosive"
    return "ranged"

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
    for item in get_tree().get_nodes_in_group("obstacles"):
        if candidate.distance_to(item.position) < 94.0:
            return false
    for item in get_tree().get_nodes_in_group("hazards"):
        if candidate.distance_to(item.position) < 78.0:
            return false
    return true

func _on_enemy_defeated(enemy: Node2D) -> void:
    # Count each Colin once; keep pending bomb-corpses separate from living enemies.
    if _round_finished or not enemies.has(enemy):
        return
    enemies.erase(enemy)
    kills += 1
    if enemy.pending_explosion:
        pending_bombs.append(enemy)
    else:
        _spawn_mushroom_cloud(enemy.global_position, false, 0.0,
            1.55 if enemy.variant == "boss" else 1.0)
        _spawn_bones(enemy.global_position, 1.6 if enemy.variant == "boss" else 1.0)
    if not _round_finished and player.health < player.max_health and _rng.randf() < 0.20:
        _spawn_health_pickup(enemy.global_position)
    _maybe_clear_wave()
    _update_hud()

func _maybe_clear_wave() -> void:
    # Delayed explosions must resolve before another wave enters the room.
    if _round_finished or not enemies.is_empty() or not pending_bombs.is_empty():
        return
    if wave >= LAST_WAVE:
        _end_round(true)
        return
    if _wave_timer > 0.0 or _boon_open:
        return
    _floating_text(player.global_position + Vector2(0, -82),
        "WAVE CLEARED", Color("#c5f3b7"))
    _spawn_wave_reward()
    if wave % 2 == 0:
        _offer_boon()
    else:
        _wave_timer = WAVE_DELAY

func _on_explosion_requested(at: Vector2, radius: float, damage: int, bomb: Node2D) -> void:
    if not pending_bombs.has(bomb):
        return
    if not _round_finished:
        _spawn_mushroom_cloud(at, true, radius)
        _spawn_bones(at)
        damage = maxi(1, ceili(float(damage) * bomb.damage_multiplier))
        # A single random base 1-10 HP value, scaled by global enemy damage.
        # to each living target within 128px; the dead owner is excluded.
        if player.health > 0 and player.global_position.distance_to(at) <= radius:
            player.take_damage(damage, "Red Colin's explosion")
        if not _round_finished:
            for enemy in enemies.duplicate():
                if _round_finished:
                    break
                if is_instance_valid(enemy) and enemy.health > 0 and enemy.global_position.distance_to(at) <= radius:
                    var applied: int = enemy.take_damage(damage)
                    if applied > 0:
                        _floating_text(enemy.global_position + Vector2(0, -54),
                            "-%d" % applied, Color("#ff934b"))
    pending_bombs.erase(bomb)
    _maybe_clear_wave()
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
    if _round_finished or _boon_open:
        return
    # The front lane and both ±45 degree lanes share every weapon upgrade.
    var directions: Array[Vector2] = [direction.normalized()]
    if player.boon_angled:
        directions.append(direction.rotated(PI / 4.0).normalized())
        directions.append(direction.rotated(-PI / 4.0).normalized())
    for lane_index in range(directions.size()):
        var firing_direction: Vector2 = directions[lane_index]
        _launch_doughnut(firing_direction, lane_index == 0, -1 if player.boon_extra_shot else 0)
        if player.boon_extra_shot:
            _launch_doughnut(firing_direction, lane_index == 0, 1)

func _launch_doughnut(direction: Vector2, front: bool, lateral_side: int) -> void:
    var shot = DOUGHNUT_SCENE.instantiate()
    shot.direction = direction
    shot.damage = maxi(1, ceili(float(player.doughnut_damage) * player.doughnut_damage_multiplier))
    shot.speed = player.doughnut_speed * player.doughnut_speed_multiplier
    shot.size_multiplier = player.doughnut_size
    shot.critical_chance = player.doughnut_critical_chance
    shot.exploding_front = front and player.boon_front_explosion
    shot.piercing = player.boon_piercing and not shot.exploding_front
    var side: float = 0.0 if lateral_side == 0 else float(lateral_side) * 12.0
    # -1 denotes the initial single lane unless the extra-shot boon is active.
    if lateral_side == -1 and not player.boon_extra_shot:
        side = 0.0
    shot.position = player.position + direction * (26.0 + 12.0 * player.doughnut_size) + direction.orthogonal() * side
    add_child(shot)
    shot.damage_dealt.connect(_on_doughnut_damage)
    shot.splash_requested.connect(_on_doughnut_splash)

func _on_doughnut_splash(at: Vector2, direct_victim: Node2D, damage: int) -> void:
    if _round_finished:
        return
    var fx = DOUGHNUT_BLAST_FX.new()
    fx.position = at
    add_child(fx)
    for enemy in enemies.duplicate():
        if not is_instance_valid(enemy) or enemy == direct_victim or enemy.health <= 0:
            continue
        if enemy.global_position.distance_to(at) <= fx.radius:
            var applied: int = enemy.take_damage(damage)
            if applied > 0:
                _floating_text(enemy.global_position + Vector2(0, -47),
                    "-%d AOE" % applied, Color("#ffd18c"))

func _on_pencil_requested(at: Vector2, direction: Vector2, shooter: Node2D) -> void:
    if _round_finished:
        return
    var pencil = PENCIL_SCENE.instantiate()
    pencil.direction = direction
    pencil.shooter = shooter
    pencil.damage_multiplier = shooter.damage_multiplier
    pencil.global_position = at
    add_child(pencil)
    pencil.damage_dealt.connect(_on_pencil_damage_dealt)
    pencil.snapped.connect(_on_pencil_snapped.bind(direction.angle()))

func _on_pencil_damage_dealt(at: Vector2, amount: int, victim_is_player: bool) -> void:
    # Player damage already produces red floating text via the damage_taken signal.
    if not victim_is_player:
        _floating_text(at + Vector2(0, -51), "-%d" % amount, Color("#86c7ff"))
    _update_hud()

func _on_pencil_snapped(at: Vector2, heading: float) -> void:
    if _round_finished:
        return
    var bits = PENCIL_SNAP.new()
    bits.position = at
    bits.heading = heading
    add_child(bits)
 
func _on_doughnut_damage(at: Vector2, amount: int, critical: bool) -> void:
    if critical:
        _floating_text(at + Vector2(0, -50), "CRIT! -%d" % amount, Color("#ffed75"))
    else:
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
    _death_cause = player.last_damage_source
    _end_round(false)

func _end_round(victory: bool) -> void:
    if _round_finished:
        return
    _round_finished = true
    _win = victory
    _wave_timer = -1.0
    _boon_open = false
    if is_instance_valid(_boon_overlay):
        _boon_overlay.hide()
    _survival_at_end = _elapsed_survival
    player.set_physics_process(false)
    for enemy in enemies:
        if is_instance_valid(enemy):
            enemy.set_physics_process(false)
            enemy.set_process(false)
    for bomb in pending_bombs:
        if is_instance_valid(bomb):
            bomb.queue_free()
    pending_bombs.clear()
    for projectile in get_tree().get_nodes_in_group("projectiles"):
        projectile.queue_free()
    _update_hud()
    if victory:
        _show_game_over_dialog()
    else:
        _death_sequence_remaining = 0.52


func _spawn_bones(at: Vector2, size: float = 1.0) -> void:
    var bones = BONE_PILE.new()
    bones.position = at
    bones.size_multiplier = size
    add_child(bones)

func _spawn_mushroom_cloud(at: Vector2, deals_damage: bool, blast_radius: float,
        effect_scale: float = 1.0) -> void:
    var cloud = MUSHROOM_CLOUD.new()
    cloud.position = at
    cloud.hazardous = deals_damage
    cloud.radius = blast_radius
    cloud.scale_factor = effect_scale
    add_child(cloud)

func _start_tombstone_drop() -> void:
    if is_instance_valid(_tombstone):
        return
    _tombstone = TOMBSTONE.new()
    add_child(_tombstone)
    var room_edge: float = ROOM_SIDE / 2.0 - 56.0
    var grave_point: Vector2 = player.global_position + Vector2(74, 12)
    grave_point.x = clampf(grave_point.x, -room_edge, room_edge)
    grave_point.y = clampf(grave_point.y, -room_edge, room_edge)
    _tombstone.landed.connect(_show_game_over_dialog, CONNECT_ONE_SHOT)
    _tombstone.drop_to(grave_point)

func _format_survival(seconds: float) -> String:
    var total: int = maxi(0, int(floor(seconds)))
    return "%02d:%02d" % [total / 60, total % 60]



func _input(event: InputEvent) -> void:
    if not _boon_open:
        return
    # Consume controller UI input before the regular GUI and twin-stick controls.
    if event is InputEventJoypadButton and event.pressed:
        match event.button_index:
            JOY_BUTTON_DPAD_UP:
                _move_boon_selection(-1)
            JOY_BUTTON_DPAD_DOWN:
                _move_boon_selection(1)
            JOY_BUTTON_A:
                _confirm_boon_selection()
            _:
                return
        get_viewport().set_input_as_handled()
    elif event is InputEventJoypadMotion and event.axis == JOY_AXIS_LEFT_Y:
        var strength: float = event.axis_value
        if absf(strength) < 0.35:
            _boon_stick_latched = false
        elif absf(strength) > 0.65 and not _boon_stick_latched:
            _boon_stick_latched = true
            _move_boon_selection(1 if strength > 0.0 else -1)
            get_viewport().set_input_as_handled()
    elif event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_UP, KEY_W:
                _move_boon_selection(-1)
            KEY_DOWN, KEY_S:
                _move_boon_selection(1)
            KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
                _confirm_boon_selection()
            _:
                return
        get_viewport().set_input_as_handled()

func _move_boon_selection(direction: int) -> void:
    if not _boon_open or _boon_buttons.is_empty():
        return
    _boon_selection_index = posmod(_boon_selection_index + direction, _boon_buttons.size())
    _focus_boon_selection()

func _focus_boon_selection() -> void:
    if _boon_buttons.is_empty():
        return
    _boon_buttons[_boon_selection_index].grab_focus()

func _confirm_boon_selection() -> void:
    if not _boon_open or _boon_selection_index < 0 or _boon_selection_index >= boon_order.size():
        return
    _choose_boon(boon_order[_boon_selection_index])

func _boon_label(kind: String) -> String:
    match kind:
        "swarm": return "More Colins (+25%)  /  Doughnut damage +25%"
        "fortitude": return "Enemy HP +30%  /  Otter speed +20%"
        "ferocity": return "Enemy damage +25%  /  Doughnut speed +25%"
        "angle": return "Enemy HP +10%  /  Add shots at ±45 degrees"
        "double": return "Enemies +15%  /  Add one donut to every firing lane"
        "pierce": return "Enemy damage +10%  /  Donuts pierce enemies"
        "blast": return "Enemy HP +15%  /  Front donuts get small AOE blasts"
    return kind

func _choose_boon_by_index(index: int) -> void:
    if not _boon_open or index < 0 or index >= boon_order.size():
        return
    _boon_selection_index = index
    _choose_boon(boon_order[index])

func _create_boon_dialog(layer: CanvasLayer) -> void:
    _boon_overlay = ColorRect.new()
    _boon_overlay.color = Color(0.045, 0.035, 0.085, 0.87)
    _boon_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _boon_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.add_child(_boon_overlay)
    _boon_overlay.hide()

    var panel := PanelContainer.new()
    panel.position = (get_viewport().get_visible_rect().size - Vector2(742, 466)) / 2.0
    panel.custom_minimum_size = Vector2(742, 466)
    panel.size = Vector2(742, 466)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#202238")
    style.border_color = Color("#cda3f2")
    style.set_border_width_all(3)
    style.set_corner_radius_all(15)
    style.set_content_margin_all(24)
    panel.add_theme_stylebox_override("panel", style)
    _boon_overlay.add_child(panel)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 13)
    panel.add_child(content)
    var heading := Label.new()
    heading.text = "A CHAOS BOON"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 31)
    heading.add_theme_color_override("font_color", Color("#e5bcff"))
    content.add_child(heading)
    var subtitle := Label.new()
    subtitle.text = "Choose one gift with a price. Both effects last until this run ends."
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 17)
    content.add_child(subtitle)

    var controls := Label.new()
    controls.text = "D-pad / left stick: choose       A / Cross: confirm"
    controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    controls.add_theme_font_size_override("font_size", 16)
    controls.add_theme_color_override("font_color", Color("#d7c0ed"))
    content.add_child(controls)

    _boon_buttons.clear()
    for i in range(3):
        var button := Button.new()
        button.text = _boon_label(boon_order[i])
        button.custom_minimum_size = Vector2(648, 73)
        button.add_theme_font_size_override("font_size", 17)
        button.pressed.connect(_choose_boon_by_index.bind(i))
        content.add_child(button)
        button.focus_mode = Control.FOCUS_ALL
        _boon_buttons.append(button)

func _offer_boon() -> void:
    if _round_finished or _boon_open:
        return
    _boon_open = true
    _wave_timer = -1.0
    player.status_paused = true
    for projectile in get_tree().get_nodes_in_group("projectiles"):
        projectile.queue_free()
    _boon_selection_index = 0
    _boon_stick_latched = false
    var offered: Array[String] = BOON_POOL.duplicate()
    offered.shuffle()
    boon_order.assign(offered.slice(0, 3))
    for i in range(_boon_buttons.size()):
        _boon_buttons[i].text = _boon_label(boon_order[i])
    _boon_overlay.show()
    _focus_boon_selection()
    _update_hud()

func _choose_boon(kind: String) -> void:
    if not _boon_open or _round_finished:
        return
    match kind:
        "swarm":
            enemy_spawn_multiplier *= 1.25
            player.doughnut_damage_multiplier *= 1.25
        "fortitude":
            enemy_health_multiplier *= 1.30
            player.movement_multiplier *= 1.20
        "ferocity":
            enemy_damage_multiplier *= 1.25
            player.doughnut_speed_multiplier *= 1.25
        "angle":
            enemy_health_multiplier *= 1.10
            player.boon_angled = true
        "double":
            enemy_spawn_multiplier *= 1.15
            player.boon_extra_shot = true
        "pierce":
            enemy_damage_multiplier *= 1.10
            player.boon_piercing = true
        "blast":
            enemy_health_multiplier *= 1.15
            player.boon_front_explosion = true
        _:
            return
    boons_chosen.append(kind)
    _boon_open = false
    _boon_overlay.hide()
    _boon_stick_latched = false
    if _boon_buttons.size() > 0:
        _boon_buttons[_boon_selection_index].release_focus()
    player.status_paused = false
    _wave_timer = WAVE_DELAY
    _update_hud()

func _create_game_over_dialog(layer: CanvasLayer) -> void:
    _game_over_overlay = ColorRect.new()
    _game_over_overlay.color = Color(0.05, 0.07, 0.10, 0.69)
    _game_over_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _game_over_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.add_child(_game_over_overlay)
    _game_over_overlay.hide()

    var panel := PanelContainer.new()
    panel.position = (get_viewport().get_visible_rect().size - Vector2(560, 290)) / 2.0
    panel.custom_minimum_size = Vector2(560, 290)
    panel.size = Vector2(560, 290)
    var box_style := StyleBoxFlat.new()
    box_style.bg_color = Color("#24313c")
    box_style.border_color = Color("#e2c18a")
    box_style.set_border_width_all(3)
    box_style.set_corner_radius_all(13)
    box_style.set_content_margin_all(28)
    panel.add_theme_stylebox_override("panel", box_style)
    _game_over_overlay.add_child(panel)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 18)
    panel.add_child(content)

    _game_over_title = Label.new()
    _game_over_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _game_over_title.add_theme_font_size_override("font_size", 33)
    _game_over_title.add_theme_color_override("font_color", Color("#f2d7ac"))
    content.add_child(_game_over_title)

    _game_over_details = Label.new()
    _game_over_details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _game_over_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _game_over_details.add_theme_font_size_override("font_size", 19)
    content.add_child(_game_over_details)

    var restart := Button.new()
    restart.text = "Try again     (A / R)"
    restart.custom_minimum_size = Vector2(260, 48)
    restart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    restart.pressed.connect(func() -> void: get_tree().reload_current_scene())
    content.add_child(restart)

func _show_game_over_dialog() -> void:
    if not is_instance_valid(_game_over_overlay):
        return
    if _win:
        _game_over_title.text = "VICTORY!"
        _game_over_details.text = "Boss defeated; all 10 waves cleared!\nEnemies defeated: %d (base goal %d)\nTime survived: %s" % [
            kills, TARGET_KILLS, _format_survival(_survival_at_end)]
    else:
        _game_over_title.text = "GAME OVER"
        _game_over_details.text = "Cause of death: %s\nTime survived: %s\nColins defeated: %d / %d" % [
            _death_cause, _format_survival(_survival_at_end), kills, TARGET_KILLS]
    _game_over_overlay.show()

func _floating_text(at: Vector2, message: String, color: Color) -> void:
    var popup = FLOATING_TEXT.new()
    popup.configure(message, color)
    add_child(popup)
    popup.global_position = at

func _update_hud() -> void:
    if hud == null or not is_instance_valid(player):
        return
    var stats: String = "OTTER %d/%d HP | KILLS %d (BASE %d) | WAVE %d/%d | LEFT %d | BOONS %d\nDOUGHNUT %d DMG | %d px/s | %.2fx SIZE | CRIT 1%% | BOMBS %d" % [
        player.health, player.max_health, kills, TARGET_KILLS, wave, LAST_WAVE,
        enemies.size(), boons_chosen.size(),
        maxi(1, ceili(float(player.doughnut_damage) * player.doughnut_damage_multiplier)),
        roundi(player.doughnut_speed * player.doughnut_speed_multiplier),
        player.doughnut_size, pending_bombs.size()
    ]
    if _round_finished:
        hud.text = stats
    elif _boon_open:
        hud.text = stats + "\nCHOOSE YOUR CHAOS BOON"
    elif _wave_timer > 0.0:
        hud.text = stats + "\nWAVE CLEAR — NEXT WAVE INCOMING"
    else:
        hud.text = stats

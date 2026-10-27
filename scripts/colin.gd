extends CharacterBody2D
## Colin: slow chase, escalating drain, and optional delayed explosive death.

signal defeated
signal aura_started
signal aura_broken
signal aura_tick(damage: int)
signal explosion_requested(at: Vector2, radius: float, damage: int)
signal pencil_requested(at: Vector2, direction: Vector2, shooter: Node2D)
signal ordnance_requested(at: Vector2, destination: Vector2, mine: bool, shooter: Node2D)

@export_enum("normal", "explosive", "ranged", "black", "boss") var variant: String = "normal"
@export var max_health: int = 10
@export var health_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export var move_speed: float = 68.0
@export var drain_start_range: float = 53.0
@export var drain_break_range: float = 96.0
@export var drain_tick_interval: float = 1.0
@export var drain_base_damage: int = 1
@export var drain_ramp_every_ticks: int = 3
@export var drain_max_damage: int = 4

@export_range(0.0, 1.0, 0.01) var explosion_chance: float = 0.0
@export var pencil_interval: float = 1.0
@export var bomb_interval: float = 2.1
@export var mine_interval: float = 8.0
@export var bomb_range: float = 770.0
@export var pencil_range: float = 680.0
@export var ranged_preferred_distance: float = 270.0
@export var ranged_minimum_distance: float = 190.0
@export var explosion_delay: float = 0.9
@export var explosion_radius: float = 128.0
@export var explosion_damage_min: int = 1
@export var explosion_damage_max: int = 10

var health: int = 10
var target
var aura_active: bool = false
var pending_explosion: bool = false
var _explosion_remaining: float = 0.0
var _drain_elapsed: float = 0.0
var _ticks_completed: int = 0
var _aura_phase: float = 0.0
var _glow_time: float = 0.0
var _pencil_elapsed: float = 0.0
var _bomb_elapsed: float = 0.0
var _mine_elapsed: float = 0.0
var _shoots_pencils: bool = false
var _uses_aura: bool = true
var _boss_size: float = 2.2
var burn_ticks_left: int = 0
var _burn_elapsed: float = 0.0
var spawn_delay: float = 0.0
var _arrival_complete: bool = false

@onready var art = $Art
@onready var health_bar = $HealthBar

func _ready() -> void:
    _configure_variant()
    max_health = maxi(1, ceili(float(max_health) * health_multiplier))
    health = max_health
    health_bar.set_health(health, max_health)
    add_to_group("enemies")
    _arrival_complete = spawn_delay <= 0.0
    health_bar.visible = _arrival_complete
    if not _arrival_complete:
        art.modulate.a = 0.0
        collision_layer = 0
        collision_mask = 0
        $CollisionShape2D.set_deferred("disabled", true)
    var flames = preload("res://scripts/burn_fx.gd").new()
    flames.name = "BurnFX"
    add_child(flames)

func _configure_variant() -> void:
    # All variants share death tracking and damage, but each has a distinct role.
    # Using colours rather than new sprites keeps the current placeholder artwork.
    match variant:
        "explosive":
            explosion_chance = 1.0
            art.jumper_color = Color("#c3343c")
            move_speed = 62.0
        "ranged":
            explosion_chance = 0.0
            _uses_aura = false
            _shoots_pencils = true
            pencil_interval = 1.0
            move_speed = 58.0
            art.jumper_color = Color("#377dc8")
        "black":
            explosion_chance = 0.0
            _uses_aura = false
            _shoots_pencils = false
            move_speed = 50.0
            ranged_minimum_distance = 230.0
            ranged_preferred_distance = 355.0
            art.jumper_color = Color("#252630")
            _mine_elapsed = randf_range(0.0, 1.4)
        "boss":
            explosion_chance = 0.0
            max_health = 40
            move_speed = 33.0
            _shoots_pencils = true
            _uses_aura = true
            pencil_interval = 1.1
            pencil_range = 730.0
            drain_start_range = 88.0
            drain_break_range = 145.0
            art.jumper_color = Color("#8b568f")
            art.scale = Vector2.ONE * _boss_size
            health_bar.position.y = -95.0
            health_bar.width = 78.0
            var collision := CircleShape2D.new()
            collision.radius = 42.0
            $CollisionShape2D.shape = collision
        _:
            variant = "normal"
            explosion_chance = 0.0
            art.jumper_color = Color("#e4ae37")
    if _shoots_pencils:
        _pencil_elapsed = 0.0

func _process(delta: float) -> void:
    if not _arrival_complete and health > 0:
        spawn_delay -= delta
        art.modulate.a = clampf(1.0 - spawn_delay / 0.70, 0.0, 1.0)
        if spawn_delay <= 0.0:
            _arrival_complete = true
            art.modulate.a = 1.0
            health_bar.show()
            collision_layer = 2
            collision_mask = 9
            $CollisionShape2D.set_deferred("disabled", false)
    if pending_explosion:
        _explosion_remaining -= delta
        _glow_time += delta
        var pulse: float = 0.5 + 0.5 * sin(_glow_time * 23.0)
        art.modulate = Color(1.0, 0.08 + pulse * 0.23, 0.08 + pulse * 0.23)
        queue_redraw()
        if _explosion_remaining <= 0.0:
            pending_explosion = false
            var low: int = maxi(1, mini(explosion_damage_min, explosion_damage_max))
            var high: int = maxi(low, maxi(explosion_damage_min, explosion_damage_max))
            var blast_damage: int = randi_range(low, high)
            explosion_requested.emit(global_position, explosion_radius, blast_damage)
            queue_free()
        return
    if aura_active:
        _aura_phase += delta
        queue_redraw()

func _physics_process(delta: float) -> void:
    if spawn_delay > 0.0:
        velocity = Vector2.ZERO
        return
    _tick_burn(delta)
    if not is_instance_valid(target) or health <= 0:
        velocity = Vector2.ZERO
        return
    var separation: Vector2 = target.global_position - global_position
    var distance: float = separation.length()
    if variant == "black" and distance <= bomb_range and distance > 0.01:
        _bomb_elapsed += delta
        _mine_elapsed += delta
        if _bomb_elapsed >= bomb_interval:
            _bomb_elapsed -= bomb_interval
            var aim: Vector2 = separation.rotated(randf_range(-0.22, 0.22))
            var bomb_landing: Vector2 = global_position + aim.limit_length(560.0)
            ordnance_requested.emit(global_position, bomb_landing, false, self)
            art.set_facing(separation)
        if _mine_elapsed >= mine_interval:
            _mine_elapsed = 0.0
            var angle: float = randf_range(0.0, TAU)
            var distance_to_mine: float = randf_range(170.0, 390.0)
            var mine_landing: Vector2 = global_position + Vector2.RIGHT.rotated(angle) * distance_to_mine
            ordnance_requested.emit(global_position, mine_landing, true, self)
    if _shoots_pencils and distance <= pencil_range and distance > 0.01:
        _pencil_elapsed += delta
        if _pencil_elapsed >= maxf(0.1, pencil_interval):
            _pencil_elapsed -= maxf(0.1, pencil_interval)
            var muzzle_offset: float = 72.0 if variant == "boss" else 38.0
            pencil_requested.emit(global_position + separation.normalized() * muzzle_offset,
                separation.normalized(), self)
            art.set_facing(separation)

    if aura_active:
        if distance > drain_break_range:
            _stop_aura()
        else:
            velocity = Vector2.ZERO
            _drain_elapsed += delta
            var interval: float = maxf(0.05, drain_tick_interval)
            while _drain_elapsed >= interval and aura_active:
                _drain_elapsed -= interval
                var ramp_every: int = maxi(1, drain_ramp_every_ticks)
                var increase: int = int(floor(float(_ticks_completed) / float(ramp_every)))
                var damage: int = maxi(1, ceili(float(mini(drain_max_damage, drain_base_damage + increase)) * damage_multiplier))
                _ticks_completed += 1
                var applied: int = target.take_damage(damage, _drain_damage_source())
                if applied > 0:
                    aura_tick.emit(applied)
                if target.health <= 0:
                    _stop_aura()
            return

    if _uses_aura and distance <= drain_start_range:
        _start_aura()
        velocity = Vector2.ZERO
    elif variant == "ranged" or variant == "black":
        # Ranged Colin tries to maintain space rather than running into melee.
        var desired_motion := Vector2.ZERO
        if distance < ranged_minimum_distance:
            desired_motion = -separation.normalized()
        elif distance > ranged_preferred_distance:
            desired_motion = separation.normalized()
        velocity = _avoid_mines(_avoid_burning_neighbours(desired_motion)) * move_speed
        if velocity != Vector2.ZERO:
            move_and_slide()
        art.set_facing(separation)
    elif distance > (70.0 if variant == "boss" else 40.0):
        velocity = _avoid_mines(_avoid_burning_neighbours(separation.normalized())) * move_speed
        art.set_facing(separation)
        move_and_slide()
    else:
        velocity = Vector2.ZERO

func _start_aura() -> void:
    if aura_active:
        return
    aura_active = true
    _drain_elapsed = 0.0
    _ticks_completed = 0
    aura_started.emit()
    queue_redraw()

func _stop_aura() -> void:
    if not aura_active:
        return
    aura_active = false
    _drain_elapsed = 0.0
    _ticks_completed = 0
    aura_broken.emit()
    queue_redraw()

func take_damage(amount: int) -> int:
    if health <= 0 or amount <= 0:
        return 0
    var applied: int = mini(amount, health)
    health -= applied
    health_bar.set_health(health, max_health)
    if health <= 0:
        _die()
    return applied

func _die() -> void:
    # Decide whether to explode BEFORE notifying the wave controller.
    # Dying is counted once; the corpse cannot receive further damage.
    if aura_active:
        aura_active = false
        queue_redraw()
    pending_explosion = randf() < clampf(explosion_chance, 0.0, 1.0)
    _explosion_remaining = maxf(0.01, explosion_delay)
    velocity = Vector2.ZERO
    remove_from_group("enemies")
    collision_layer = 0
    collision_mask = 0
    $CollisionShape2D.set_deferred("disabled", true)
    set_physics_process(false)
    defeated.emit()
    if not pending_explosion:
        queue_free()

func _draw() -> void:
    if pending_explosion:
        var pulse: float = 0.5 + 0.5 * sin(_glow_time * 23.0)
        var glow_color := Color(1.0, 0.04, 0.03, 0.20 + pulse * 0.38)
        draw_circle(Vector2.ZERO, 39.0 + pulse * 15.0, glow_color)
        draw_arc(Vector2.ZERO, 39.0 + pulse * 10.0, 0.0, TAU, 64, Color(1.0, 0.14, 0.08, 0.85), 4.0, true)
        return
    if not aura_active:
        return
    for ring in range(2):
        var outline := PackedVector2Array()
        for i in range(49):
            var theta: float = TAU * float(i) / 48.0
            var radius: float = 28.0 + float(ring) * 9.0 + sin(theta * 6.0 + _aura_phase * 8.0 + ring) * 4.0
            outline.append(Vector2(cos(theta), sin(theta)) * radius)
        draw_polyline(outline, Color(0.71, 0.51, 1.0, 0.60 - float(ring) * 0.15), 2.0, true)

    if is_instance_valid(target):
        var destination: Vector2 = to_local(target.global_position)
        var beam := PackedVector2Array()
        var perp: Vector2 = destination.normalized().orthogonal()
        for i in range(17):
            var t: float = float(i) / 16.0
            var wobble: float = sin(t * 19.0 + _aura_phase * 10.0) * 6.0 * sin(PI * t)
            beam.append(destination * t + perp * wobble)
        draw_polyline(beam, Color(0.71, 0.55, 1.0, 0.68), 3.0, true)

func _drain_damage_source() -> String:
    match variant:
        "boss":
            return "Boss Colin's life-drain aura"
        "explosive":
            return "Red Colin's life-drain aura"
        _:
            return "Colin's life-drain aura"

func apply_burn(ticks: int = 5) -> void:
    if health <= 0:
        return
    burn_ticks_left = maxi(0, ticks)
    _burn_elapsed = 0.0

func receive_contagious_burn() -> void:
    if burn_ticks_left <= 0 and health > 0:
        apply_burn(5)

func _tick_burn(delta: float) -> void:
    if burn_ticks_left <= 0 or health <= 0:
        return
    _burn_elapsed += delta
    while _burn_elapsed >= 1.0 and burn_ticks_left > 0 and health > 0:
        _burn_elapsed -= 1.0
        burn_ticks_left -= 1
        take_damage(1)

func _avoid_burning_neighbours(direction: Vector2) -> Vector2:
    if burn_ticks_left <= 0:
        return direction
    var escape := Vector2.ZERO
    for other in get_tree().get_nodes_in_group("enemies"):
        if other == self or not is_instance_valid(other) or other.health <= 0:
            continue
        var away: Vector2 = global_position - other.global_position
        if away.length() < 122.0 and away.length_squared() > 0.001:
            escape += away.normalized() * (1.0 - away.length() / 122.0) * 2.2
    # Otter is never an avoidance target.
    var combined: Vector2 = direction + escape
    return combined.normalized() if combined != Vector2.ZERO else direction

func _avoid_mines(direction: Vector2) -> Vector2:
    var repel := Vector2.ZERO
    for node in get_tree().get_nodes_in_group("armed_mines"):
        if not is_instance_valid(node) or not node.armed:
            continue
        var away: Vector2 = global_position - node.global_position
        var distance: float = away.length()
        if distance < 165.0 and distance > 0.001:
            repel += away / distance * 3.0 * (1.0 - distance / 165.0)
    var combined: Vector2 = direction + repel
    return combined.normalized() if combined.length_squared() > 0.01 else Vector2.ZERO

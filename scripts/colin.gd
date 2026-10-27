extends CharacterBody2D
## Colin: slow chase, escalating drain, and optional delayed explosive death.

signal defeated
signal aura_started
signal aura_broken
signal aura_tick(damage: int)
signal explosion_requested(at: Vector2, radius: float, damage: int)

@export var max_health: int = 10
@export var move_speed: float = 68.0
@export var drain_start_range: float = 53.0
@export var drain_break_range: float = 96.0
@export var drain_tick_interval: float = 1.0
@export var drain_base_damage: int = 1
@export var drain_ramp_every_ticks: int = 3
@export var drain_max_damage: int = 4

@export_range(0.0, 1.0, 0.01) var explosion_chance: float = 0.25
@export var explosion_delay: float = 2.0
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

@onready var art = $Art
@onready var health_bar = $HealthBar

func _ready() -> void:
    health = max_health
    health_bar.set_health(health, max_health)
    add_to_group("enemies")

func _process(delta: float) -> void:
    if pending_explosion:
        _explosion_remaining -= delta
        _glow_time += delta
        var pulse: float = 0.5 + 0.5 * sin(_glow_time * 14.0)
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
    if not is_instance_valid(target) or health <= 0:
        velocity = Vector2.ZERO
        return
    var separation: Vector2 = target.global_position - global_position
    var distance: float = separation.length()

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
                var damage: int = mini(drain_max_damage, drain_base_damage + increase)
                _ticks_completed += 1
                var applied: int = target.take_damage(damage)
                if applied > 0:
                    aura_tick.emit(applied)
                if target.health <= 0:
                    _stop_aura()
            return

    if distance <= drain_start_range:
        _start_aura()
        velocity = Vector2.ZERO
    elif distance > 40.0:
        velocity = separation.normalized() * move_speed
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
        var pulse: float = 0.5 + 0.5 * sin(_glow_time * 14.0)
        var glow_color := Color(1.0, 0.07, 0.05, 0.18 + pulse * 0.23)
        draw_circle(Vector2.ZERO, 39.0 + pulse * 8.0, glow_color)
        draw_arc(Vector2.ZERO, 37.0 + pulse * 5.0, 0.0, TAU, 64, Color(1.0, 0.2, 0.12, 0.72), 3.0, true)
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

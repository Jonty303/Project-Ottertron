extends CharacterBody2D
## Slow pursuer: short-range, escalating 1-second life drain with range hysteresis.

signal defeated
signal aura_started
signal aura_broken
signal aura_tick(damage: int)

@export var max_health: int = 2
@export var move_speed: float = 68.0
@export var drain_start_range: float = 53.0
@export var drain_break_range: float = 96.0
@export var drain_tick_interval: float = 1.0
@export var drain_base_damage: int = 1
@export var drain_ramp_every_ticks: int = 3
@export var drain_max_damage: int = 4

var health: int = 2
var target
var aura_active: bool = false
var _drain_elapsed: float = 0.0
var _ticks_completed: int = 0
var _aura_phase: float = 0.0

@onready var art = $Art
@onready var health_bar = $HealthBar

func _ready() -> void:
    health = max_health
    health_bar.set_health(health, max_health)
    add_to_group("enemies")

func _process(delta: float) -> void:
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
    elif distance < 700.0 and distance > 40.0:
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
        aura_active = false
        defeated.emit()
        queue_free()
    return applied

func _draw() -> void:
    if not aura_active:
        return
    # Wobbling rings and a living, swaying tether to the otter.
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

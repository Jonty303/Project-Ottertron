extends CharacterBody2D
## Controller movement, directional fire, and independently upgradeable projectile stats.

signal fire_requested(direction: Vector2)
signal health_changed(current_health: int)
signal damage_taken(amount: int)
signal doughnut_stats_changed(damage: int, speed: float, size_multiplier: float)
signal defeated

const MOVE_SPEED: float = 210.0
const AIM_DEADZONE: float = 0.45
const MOVE_DEADZONE: float = 0.18
const FIRE_INTERVAL: float = 0.20

@export var max_health: int = 12
@export var movement_multiplier: float = 1.0
@export var doughnut_damage_multiplier: float = 1.0
@export var doughnut_speed_multiplier: float = 1.0
@export var doughnut_damage: int = 1
@export_range(0.0, 1.0, 0.001) var doughnut_critical_chance: float = 0.01
@export var doughnut_speed: float = 315.0
@export var doughnut_size: float = 0.78
@export var maximum_doughnut_size: float = 2.0

var health: int = 12
var last_damage_source: String = "Unknown cause"
var death_animation_started: bool = false
var _fire_cooldown: float = 0.0
var burn_ticks_left: int = 0
var _burn_elapsed: float = 0.0
var status_paused: bool = false
var boon_angled: bool = false
var boon_extra_shot: bool = false
var boon_piercing: bool = false
var boon_front_explosion: bool = false

@onready var art = $Art
@onready var health_bar = $HealthBar

func _ready() -> void:
    add_to_group("player")
    health = max_health
    health_bar.set_health(health, max_health)

func _physics_process(delta: float) -> void:
    if health <= 0 or status_paused:
        velocity = Vector2.ZERO
        return
    _tick_burn(delta)
    if health <= 0:
        velocity = Vector2.ZERO
        return
    _fire_cooldown = maxf(0.0, _fire_cooldown - delta)

    var movement: Vector2 = _stick(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
    if movement.length() < MOVE_DEADZONE:
        movement = Vector2.ZERO
    if movement == Vector2.ZERO:
        movement = Vector2(
            float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
            float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
        ).normalized()

    velocity = movement.limit_length(1.0) * MOVE_SPEED * movement_multiplier
    move_and_slide()

    var aim: Vector2 = _stick(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
    if aim.length() < AIM_DEADZONE:
        aim = Vector2.ZERO
    if aim == Vector2.ZERO:
        aim = Vector2(
            float(Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_LEFT)),
            float(Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_UP))
        ).normalized()

    if aim != Vector2.ZERO:
        art.set_facing(aim)
        if _fire_cooldown <= 0.0:
            fire_requested.emit(aim.normalized())
            _fire_cooldown = FIRE_INTERVAL
    elif movement != Vector2.ZERO:
        art.set_facing(movement)

func _stick(horizontal_axis: JoyAxis, vertical_axis: JoyAxis) -> Vector2:
    var pads: Array[int] = Input.get_connected_joypads()
    if pads.is_empty():
        return Vector2.ZERO
    var device: int = pads[0]
    return Vector2(
        Input.get_joy_axis(device, horizontal_axis),
        Input.get_joy_axis(device, vertical_axis)
    ).limit_length(1.0)

func take_damage(amount: int, source: String = "Unknown cause") -> int:
    if health <= 0 or amount <= 0:
        return 0
    var applied: int = mini(amount, health)
    health -= applied
    last_damage_source = source
    health_bar.set_health(health, max_health)
    damage_taken.emit(applied)
    health_changed.emit(health)
    if health <= 0:
        begin_death_animation()
        defeated.emit()
    return applied

func apply_doughnut_upgrade(kind: String, amount: float) -> void:
    match kind:
        "damage":
            doughnut_damage += maxi(1, roundi(amount))
        "speed":
            doughnut_speed += maxf(1.0, amount)
        "size":
            doughnut_size = minf(maximum_doughnut_size, doughnut_size + maxf(0.01, amount))
        _:
            return
    doughnut_stats_changed.emit(doughnut_damage, doughnut_speed, doughnut_size)

func begin_death_animation() -> void:
    if death_animation_started:
        return
    death_animation_started = true
    health_bar.hide()
    art.set_facing(Vector2.DOWN)
    art.is_dead = true
    art.queue_redraw()
    # Tilt and squash the otter into a sprawled position.
    var collapse := create_tween().set_parallel(true)
    collapse.tween_property(art, "rotation", 1.40, 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    collapse.tween_property(art, "scale", Vector2(1.12, 0.62), 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    collapse.tween_property(art, "position", Vector2(0, 17), 0.48).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func receive_contagious_burn() -> void:
    if burn_ticks_left <= 0:
        apply_burn(5)

func apply_burn(ticks: int = 5) -> void:
    if health <= 0:
        return
    burn_ticks_left = maxi(0, ticks)
    _burn_elapsed = 0.0

func _tick_burn(delta: float) -> void:
    if burn_ticks_left <= 0:
        return
    _burn_elapsed += delta
    while _burn_elapsed >= 1.0 and burn_ticks_left > 0 and health > 0:
        _burn_elapsed -= 1.0
        burn_ticks_left -= 1
        take_damage(1, "Fire pit burn")

func heal(amount: int) -> int:
    if health <= 0 or amount <= 0:
        return 0
    var restored: int = mini(amount, max_health - health)
    health += restored
    health_bar.set_health(health, max_health)
    if restored > 0:
        health_changed.emit(health)
    return restored

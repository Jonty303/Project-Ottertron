extends CharacterBody2D
## Independent analogue movement and directional automatic firing.

signal fire_requested(direction: Vector2)
signal health_changed(current_health: int)
signal defeated

const MOVE_SPEED: float = 210.0
const AIM_DEADZONE: float = 0.45
const MOVE_DEADZONE: float = 0.18
const FIRE_INTERVAL: float = 0.20
const INVULNERABLE_TIME: float = 0.85

var max_health: int = 3
var health: int = 3
var _fire_cooldown: float = 0.0
var _invulnerability: float = 0.0

@onready var art = $Art

func _physics_process(delta: float) -> void:
    if health <= 0:
        velocity = Vector2.ZERO
        return

    _fire_cooldown = maxf(0.0, _fire_cooldown - delta)
    _invulnerability = maxf(0.0, _invulnerability - delta)

    var movement: Vector2 = _stick(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
    if movement.length() < MOVE_DEADZONE:
        movement = Vector2.ZERO

    # Keyboard testing fallback; controller movement takes precedence.
    if movement == Vector2.ZERO:
        movement = Vector2(
            float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
            float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
        ).normalized()

    velocity = movement.limit_length(1.0) * MOVE_SPEED
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

func take_damage(amount: int) -> void:
    if health <= 0 or _invulnerability > 0.0:
        return
    health = maxi(health - amount, 0)
    _invulnerability = INVULNERABLE_TIME
    health_changed.emit(health)
    if health == 0:
        defeated.emit()

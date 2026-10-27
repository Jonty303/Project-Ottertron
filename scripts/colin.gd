extends CharacterBody2D
## Colin's initial AI: slowly follow the otter until within contact range.

signal defeated

const MOVE_SPEED: float = 72.0
const STOP_DISTANCE: float = 41.0
const ACTIVATION_DISTANCE: float = 700.0

var health: int = 3
var target: Node2D

@onready var art = $Art

func _ready() -> void:
    add_to_group("enemies")

func _physics_process(_delta: float) -> void:
    if not is_instance_valid(target) or health <= 0:
        velocity = Vector2.ZERO
        return
    var difference: Vector2 = target.global_position - global_position
    var distance: float = difference.length()
    if distance > STOP_DISTANCE and distance < ACTIVATION_DISTANCE:
        velocity = difference.normalized() * MOVE_SPEED
        art.set_facing(velocity)
    else:
        velocity = Vector2.ZERO
    move_and_slide()

func take_damage(amount: int) -> void:
    if health <= 0:
        return
    health = maxi(health - amount, 0)
    if health == 0:
        defeated.emit()
        queue_free()

extends Area2D
## One simple glazed doughnut shot. Stops on walls or enemies.

const SHOT_SPEED: float = 470.0
const LIFETIME: float = 1.55

var direction: Vector2 = Vector2.RIGHT
var _time_remaining: float = LIFETIME
var _consumed: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    global_position += direction.normalized() * SHOT_SPEED * delta
    _time_remaining -= delta
    if _time_remaining <= 0.0:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if _consumed:
        return
    _consumed = true
    if body.is_in_group("enemies") and body.has_method("take_damage"):
        body.take_damage(1)
    queue_free()

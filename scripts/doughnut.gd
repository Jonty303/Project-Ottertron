extends Area2D
## Upgradable doughnut speed/damage, independent of visual appearance.

signal damage_dealt(at: Vector2, amount: int)

const LIFETIME: float = 1.55

@export var damage: int = 1
@export var speed: float = 370.0

var direction: Vector2 = Vector2.RIGHT
var _remaining: float = LIFETIME
var _consumed: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    global_position += direction.normalized() * speed * delta
    _remaining -= delta
    if _remaining <= 0.0:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if _consumed:
        return
    _consumed = true
    if body.is_in_group("enemies") and body.has_method("take_damage"):
        var applied: int = int(body.call("take_damage", damage))
        if applied > 0:
            damage_dealt.emit(body.global_position, applied)
    queue_free()

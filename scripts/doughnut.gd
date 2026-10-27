extends Area2D
## Shots inherit size, speed and damage from the player at fire time.

signal damage_dealt(at: Vector2, amount: int)

const LIFETIME: float = 1.55
const BASE_COLLISION_RADIUS: float = 10.0

@export var damage: int = 1
@export var speed: float = 315.0
@export_range(0.5, 2.5, 0.01) var size_multiplier: float = 0.78

var direction: Vector2 = Vector2.RIGHT
var _remaining: float = LIFETIME
var _consumed: bool = false

func _ready() -> void:
    add_to_group("projectiles")
    $Art.scale = Vector2.ONE * size_multiplier
    # Give each projectile its own shape, and scale the hitbox with its artwork.
    var shape := CircleShape2D.new()
    shape.radius = BASE_COLLISION_RADIUS * size_multiplier
    $CollisionShape2D.shape = shape
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

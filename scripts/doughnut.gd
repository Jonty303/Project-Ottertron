extends Area2D
## Pierces multiple distinct living Colins, but never rocks or intact bushes.
## Explosive front shots are intentionally NOT piercing.

signal damage_dealt(at: Vector2, amount: int, critical: bool)
signal splash_requested(at: Vector2, direct_victim: Node2D, damage: int)

const LIFETIME: float = 1.55
const BASE_COLLISION_RADIUS: float = 10.0

@export var damage: int = 1
@export var speed: float = 315.0
@export_range(0.5, 2.5, 0.01) var size_multiplier: float = 0.78
@export_range(0.0, 1.0, 0.001) var critical_chance: float = 0.01

var direction: Vector2 = Vector2.RIGHT
var piercing: bool = false
var exploding_front: bool = false
var _remaining: float = LIFETIME
var _consumed: bool = false
var _already_hit: Array[Node2D] = []

func _ready() -> void:
    add_to_group("projectiles")
    $Art.scale = Vector2.ONE * size_multiplier
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
    if _consumed or _already_hit.has(body):
        return
    if body.is_in_group("enemies") and body.has_method("take_damage"):
        _already_hit.append(body)
        var critical: bool = randf() < clampf(critical_chance, 0.0, 1.0)
        var attempted_damage: int = maxi(1, damage) * (2 if critical else 1)
        var applied: int = int(body.call("take_damage", attempted_damage))
        if applied > 0:
            damage_dealt.emit(body.global_position, applied, critical)
        if exploding_front:
            splash_requested.emit(global_position, body, maxi(1, ceili(float(damage) * 0.40)))
        if piercing and not exploding_front:
            return
    elif body.is_in_group("obstacles") and body.has_method("take_projectile_hit"):
        body.take_projectile_hit()
        if exploding_front:
            splash_requested.emit(global_position, null, maxi(1, ceili(float(damage) * 0.40)))
    elif exploding_front:
        splash_requested.emit(global_position, null, maxi(1, ceili(float(damage) * 0.40)))
    _consumed = true
    queue_free()

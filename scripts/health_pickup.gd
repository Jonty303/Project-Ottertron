extends Area2D
## Green heart pickup. Heals 3 HP, never exceeds the player's maximum.

signal collected(at: Vector2, amount: int)
@export var healing: int = 3
var _used: bool = false
var _phase: float = 0.0

func _ready() -> void:
    collision_layer = 0
    collision_mask = 1
    add_to_group("health_pickups")
    var shape := CircleShape2D.new()
    shape.radius = 19.0
    var collider := CollisionShape2D.new()
    collider.shape = shape
    add_child(collider)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if _used or not body.is_in_group("player") or not body.has_method("heal"):
        return
    var restored: int = body.heal(healing)
    if restored <= 0:
        return
    _used = true
    collected.emit(global_position, restored)
    queue_free()

func _process(delta: float) -> void:
    _phase += delta * 2.4
    queue_redraw()

func _draw() -> void:
    var bob := Vector2(0, sin(_phase) * 4)
    draw_circle(bob, 19, Color(0.18, 0.85, 0.45, 0.18))
    draw_circle(bob, 15, Color("#256747"))
    draw_circle(bob + Vector2(-6, -4), 7, Color("#8ff2a1"))
    draw_circle(bob + Vector2(6, -4), 7, Color("#8ff2a1"))
    draw_colored_polygon(PackedVector2Array([
        bob + Vector2(-13, -3), bob + Vector2(13, -3), bob + Vector2(0, 14)
    ]), Color("#69e58b"))
    draw_line(bob + Vector2(-5, 1), bob + Vector2(4, 9), Color.WHITE, 2.0)

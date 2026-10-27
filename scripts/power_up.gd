extends Area2D
## One test pickup demonstrates configurable projectile damage and speed upgrades.

signal collected(at: Vector2, added_damage: int, added_speed: float)

@export var added_damage: int = 1
@export var added_speed: float = 80.0

var _picked_up: bool = false
var _phase: float = 0.0

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    _phase += delta * 2.6
    queue_redraw()

func _draw() -> void:
    var bob: Vector2 = Vector2(0, sin(_phase) * 3.0)
    draw_circle(bob, 19.0, Color(0.26, 0.72, 0.86, 0.22))
    draw_circle(bob, 14.0, Color("#70451f"))
    draw_circle(bob, 11.0, Color("#ffd178"))
    draw_circle(bob, 5.0, Color("#70451f"))
    draw_line(bob + Vector2(1, -17), bob + Vector2(1, -23), Color("#ffffff"), 2.0)
    draw_line(bob + Vector2(-2, -20), bob + Vector2(4, -20), Color("#ffffff"), 2.0)

func _on_body_entered(body: Node2D) -> void:
    if _picked_up or not body.has_method("apply_doughnut_upgrade"):
        return
    _picked_up = true
    body.call("apply_doughnut_upgrade", added_damage, added_speed)
    collected.emit(global_position, added_damage, added_speed)
    queue_free()

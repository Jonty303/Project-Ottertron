extends Area2D
## Entering applies an independently ticking five-second burn (no immediate hit).

var _phase: float = 0.0

func _ready() -> void:
    collision_layer = 0
    collision_mask = 1
    add_to_group("hazards")
    var area_shape := CircleShape2D.new()
    area_shape.radius = 30.0
    var collider := CollisionShape2D.new()
    collider.shape = area_shape
    add_child(collider)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and body.has_method("apply_burn"):
        body.apply_burn(5)

func _process(delta: float) -> void:
    _phase += delta
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 40, Color("#27201c"))
    draw_circle(Vector2.ZERO, 34, Color("#604037"))
    draw_circle(Vector2.ZERO, 28, Color("#cc471e"))
    draw_circle(Vector2.ZERO, 20, Color("#f57f22"))
    for i in range(5):
        var theta: float = TAU * float(i) / 5.0 + _phase * 0.8
        var offset := Vector2(cos(theta), sin(theta)) * 13.0
        var lift: float = 7.0 * sin(_phase * 8.0 + i)
        draw_colored_polygon(PackedVector2Array([
            offset + Vector2(-7, 9),
            offset + Vector2(7, 9),
            offset + Vector2(0, -18 - lift)
        ]), Color("#ffcc4a"))
    draw_circle(Vector2.ZERO, 10, Color("#fff2a4"))

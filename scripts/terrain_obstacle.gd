extends StaticBody2D
## Round collision obstacles for both actors and projectiles.

@export_enum("rock", "plant") var kind: String = "rock"
@export var collision_radius: float = 35.0

func _ready() -> void:
    collision_layer = 8
    collision_mask = 0
    add_to_group("obstacles")
    var shape := CircleShape2D.new()
    shape.radius = collision_radius
    var collider := CollisionShape2D.new()
    collider.shape = shape
    add_child(collider)
    queue_redraw()

func _draw() -> void:
    if kind == "rock":
        draw_circle(Vector2(0, 9), 39, Color(0, 0, 0, 0.19))
        draw_colored_polygon(PackedVector2Array([
            Vector2(-36, 14), Vector2(-31, -16), Vector2(-14, -34),
            Vector2(18, -30), Vector2(37, -5), Vector2(32, 19), Vector2(2, 31)
        ]), Color("#687b83"))
        draw_colored_polygon(PackedVector2Array([
            Vector2(-31, -16), Vector2(-14, -34), Vector2(18, -30),
            Vector2(4, -8), Vector2(-24, 0)
        ]), Color("#9cacb2"))
        draw_line(Vector2(4, -8), Vector2(21, 8), Color("#52636b"), 3.0)
    else:
        draw_circle(Vector2(0, 13), 42, Color(0, 0, 0, 0.13))
        draw_circle(Vector2(-19, 4), 25, Color("#326c50"))
        draw_circle(Vector2(17, 9), 27, Color("#2e6945"))
        draw_circle(Vector2(-1, -15), 28, Color("#4a9258"))
        draw_circle(Vector2(3, 6), 19, Color("#61a765"))
        draw_circle(Vector2(-11, -19), 10, Color("#77b47a"))
        draw_circle(Vector2(12, -16), 5, Color("#a6cb77"))

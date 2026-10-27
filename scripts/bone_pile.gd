extends Node2D
## Permanent, non-blocking battlefield remains. These deliberately never queue_free.
var size_multiplier: float = 1.0
var _shade: Color = Color("#f0e4cb")

func _ready() -> void:
    z_index = -2
    scale = Vector2.ONE * size_multiplier
    queue_redraw()

func _draw() -> void:
    draw_ellipse_shadow(Vector2(0, 9), 24, 8)
    for item in [Vector2(-15, -1), Vector2(12, 4), Vector2(-2, 12)]:
        draw_line(item + Vector2(-7, -3), item + Vector2(7, 3), _shade, 4.0)
        draw_circle(item + Vector2(-8, -4), 3.4, _shade)
        draw_circle(item + Vector2(8, 4), 3.4, _shade)
    draw_circle(Vector2(0, -4), 12, _shade)
    draw_circle(Vector2(-5, -5), 3, Color("#505261"))
    draw_circle(Vector2(5, -5), 3, Color("#505261"))
    draw_rect(Rect2(-7, 3, 14, 5), Color("#dbcaa8"))
    for x in [-4, 0, 4]:
        draw_line(Vector2(x, 4), Vector2(x, 8), Color("#796d65"), 1.0)

func draw_ellipse_shadow(centre: Vector2, wide: float, tall: float) -> void:
    draw_set_transform(centre, 0.0, Vector2(wide, tall))
    draw_circle(Vector2.ZERO, 1.0, Color(0.0, 0.0, 0.0, 0.20))
    draw_set_transform(Vector2.ZERO)

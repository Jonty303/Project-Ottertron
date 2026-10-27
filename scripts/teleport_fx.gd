extends Node2D
## Brief entry shimmer for each newly summoned Colin.
var duration: float = 0.70
var _elapsed: float = 0.0

func _ready() -> void:
    z_index = 9

func _process(delta: float) -> void:
    _elapsed += delta
    queue_redraw()
    if _elapsed >= duration:
        queue_free()

func _draw() -> void:
    var t: float = clampf(_elapsed / duration, 0.0, 1.0)
    var alpha: float = (1.0 - t) * 0.80
    for i in range(3):
        var radius: float = 14.0 + t * 37.0 + float(i) * 10.0
        draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48,
            Color(0.50, 0.78, 1.0, alpha * (1.0 - float(i) * 0.18)), 2.3, true)
    for i in range(9):
        var angle: float = TAU * float(i) / 9.0 + t * 3.0
        var offset := Vector2.RIGHT.rotated(angle) * (41.0 * (1.0 - t))
        draw_circle(offset, 3.5 * (1.0 - t), Color(0.80, 0.91, 1.0, alpha))

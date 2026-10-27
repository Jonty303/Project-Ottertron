extends Node2D
## Non-damaging display of the small AOE delivered by a front doughnut.
var radius: float = 57.0
var duration: float = 0.26
var _elapsed: float = 0.0

func _process(delta: float) -> void:
    _elapsed += delta
    queue_redraw()
    if _elapsed >= duration:
        queue_free()

func _draw() -> void:
    var t: float = clampf(_elapsed / duration, 0.0, 1.0)
    var r: float = radius * t
    draw_circle(Vector2.ZERO, r, Color(1.0, 0.57, 0.22, (1.0 - t) * 0.23))
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(1.0, 0.90, 0.54, 1.0 - t), 3.0, true)

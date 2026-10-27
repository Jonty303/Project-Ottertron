extends Node2D
## Two wooden pencil halves peel apart briefly when the projectile snaps.

var _elapsed: float = 0.0
var duration: float = 0.38
var heading: float = 0.0

func _process(delta: float) -> void:
    _elapsed += delta
    queue_redraw()
    if _elapsed >= duration:
        queue_free()

func _draw() -> void:
    var fraction: float = clampf(_elapsed / duration, 0.0, 1.0)
    var opacity: float = 1.0 - fraction
    var spread: float = fraction * 24.0
    var upper := Vector2(0, -spread).rotated(heading)
    var lower := Vector2(0, spread).rotated(heading)
    var ink := Color(1.0, 0.80, 0.30, opacity)
    draw_line(upper + Vector2(-15, -4).rotated(heading), upper + Vector2(-2, -3).rotated(heading), ink, 4.0)
    draw_line(lower + Vector2(2, 3).rotated(heading), lower + Vector2(15, 4).rotated(heading), ink, 4.0)
    draw_circle(Vector2.ZERO, 3.0 * opacity, Color(1.0, 0.9, 0.6, opacity))

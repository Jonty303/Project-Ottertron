extends Node2D
## Brief radial flash visualising Colin's explosion radius (damage resolved separately).

var radius: float = 128.0
var duration: float = 0.42
var _elapsed: float = 0.0

func _ready() -> void:
    z_index = 7

func _process(delta: float) -> void:
    _elapsed += delta
    queue_redraw()
    if _elapsed >= duration:
        queue_free()

func _draw() -> void:
    var fraction: float = clampf(_elapsed / maxf(duration, 0.01), 0.0, 1.0)
    var current_radius: float = radius * fraction
    draw_circle(Vector2.ZERO, current_radius, Color(1.0, 0.20, 0.07, (1.0 - fraction) * 0.23))
    draw_arc(Vector2.ZERO, current_radius, 0.0, TAU, 64,
        Color(1.0, 0.54, 0.24, 0.95 * (1.0 - fraction)), 5.0, true)

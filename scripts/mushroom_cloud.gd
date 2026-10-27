extends Node2D
## Transient hand-drawn mushroom-cloud death effect; purely visual.
## Hazardous red Colin blasts additionally draw a shockwave out to the damage radius.

@export var duration: float = 0.68
var radius: float = 50.0
var hazardous: bool = false
var scale_factor: float = 1.0
var _elapsed: float = 0.0

func _ready() -> void:
    z_index = 8
    scale = Vector2.ONE * scale_factor

func _process(delta: float) -> void:
    _elapsed += delta
    queue_redraw()
    if _elapsed >= duration:
        queue_free()

func _draw() -> void:
    var t: float = clampf(_elapsed / maxf(duration, 0.01), 0.0, 1.0)
    var alpha: float = minf(1.0, t * 9.0) * (1.0 - pow(t, 2.0))
    var warm := Color(1.0, 0.41, 0.14, alpha)
    var smoke := Color(0.37, 0.36, 0.41, alpha * 0.90)
    var shadow := Color(0.18, 0.19, 0.23, alpha * 0.67)
    var rise: float = t * 34.0
    # Mushroom-cloud silhouette: thin rising stem, overlapping bulbous cap.
    draw_circle(Vector2(0, 3), 13.0 + 12.0 * t, warm)
    draw_rect(Rect2(-8.0 - 3.0 * t, -rise * 0.55, 16.0 + 6.0 * t,
        17.0 + rise * 0.55), smoke)
    var cap_center := Vector2(0.0, -15.0 - rise)
    var cap_radius: float = 13.0 + t * 21.0
    draw_circle(cap_center + Vector2(-0.55 * cap_radius, 6), cap_radius * 0.73, shadow)
    draw_circle(cap_center + Vector2(0.55 * cap_radius, 6), cap_radius * 0.73, shadow)
    draw_circle(cap_center, cap_radius, smoke)
    draw_circle(cap_center + Vector2(-6.0, -7.0), cap_radius * 0.45,
        Color(1.0, 0.72, 0.39, alpha * 0.7))
    if hazardous:
        # The damage is instantaneous, but this ring shows its 128px footprint.
        var ring_radius: float = radius * minf(1.0, t * 2.8)
        draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 72,
            Color(1.0, 0.25, 0.10, alpha * 0.85), 3.0, true)

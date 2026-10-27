extends Node2D
## Flickering flames and ember rings surrounding a burning otter.

var _elapsed: float = 0.0

func _process(delta: float) -> void:
    _elapsed += delta
    var owner_actor = get_parent()
    visible = is_instance_valid(owner_actor) and owner_actor.burn_ticks_left > 0 and owner_actor.health > 0
    if visible:
        queue_redraw()

func _draw() -> void:
    for i in range(7):
        var theta: float = TAU * float(i) / 7.0
        var offset := Vector2(cos(theta), sin(theta)) * 23.0
        var bob := sin(_elapsed * 12.0 + float(i) * 1.8) * 6.0
        var tip := offset + Vector2(0, -23 - bob)
        draw_colored_polygon(PackedVector2Array([
            offset + Vector2(-5, 8),
            offset + Vector2(5, 8),
            tip
        ]), Color(1.0, 0.37 + 0.23 * absf(sin(_elapsed * 5.0)), 0.06, 0.86))
        draw_circle(offset + Vector2(0, -8), 3, Color("#ffe373"))

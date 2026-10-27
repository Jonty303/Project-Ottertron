extends Control
## Red arrows at viewport edges pointing toward living, offscreen Colins.
var tracked_game: Node2D
var margin: float = 32.0
var arrow_color: Color = Color("#f54646")

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta: float) -> void:
    if is_instance_valid(tracked_game) and not tracked_game._round_finished and not tracked_game._boon_open:
        queue_redraw()
    elif visible:
        queue_redraw()

func indicators() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if not is_instance_valid(tracked_game) or tracked_game._round_finished or tracked_game._boon_open:
        return result
    var screen_size: Vector2 = get_viewport_rect().size
    var centre: Vector2 = screen_size / 2.0
    for enemy in tracked_game.enemies:
        if not is_instance_valid(enemy) or enemy.health <= 0 or enemy.spawn_delay > 0.0:
            continue
        var projected: Vector2 = get_viewport().get_canvas_transform() * enemy.global_position
        if Rect2(Vector2.ZERO, screen_size).has_point(projected):
            continue
        var direction: Vector2 = projected - centre
        if direction.length_squared() < 0.01:
            continue
        var safe_half: Vector2 = centre - Vector2.ONE * margin
        var factor: float = minf(
            safe_half.x / maxf(0.001, absf(direction.x)),
            safe_half.y / maxf(0.001, absf(direction.y))
        )
        result.append({"position": centre + direction * factor,
            "direction": direction.normalized()})
    return result

func _draw() -> void:
    for indicator in indicators():
        var at: Vector2 = indicator["position"]
        var direction: Vector2 = indicator["direction"]
        var sideways: Vector2 = direction.orthogonal()
        draw_colored_polygon(PackedVector2Array([
            at + direction * 13.0,
            at - direction * 9.0 + sideways * 8.0,
            at - direction * 9.0 - sideways * 8.0
        ]), arrow_color)
        draw_circle(at - direction * 10.0, 3.0, Color("#692328"))

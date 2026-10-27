extends Node2D
## A little stone falling from overhead before the game-over dialog appears.
signal landed

var landing_point: Vector2
var is_landed: bool = false
var _impact_age: float = 0.0

func drop_to(at: Vector2) -> void:
    landing_point = at
    position = at + Vector2(0.0, -380.0)
    z_index = 12
    var tween := create_tween()
    tween.tween_property(self, "position", landing_point, 0.80).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
    tween.tween_callback(finish_drop)

func finish_drop() -> void:
    if is_landed:
        return
    is_landed = true
    position = landing_point
    _impact_age = 0.0
    queue_redraw()
    landed.emit()

func _process(delta: float) -> void:
    if is_landed:
        _impact_age += delta
        if _impact_age < 0.55:
            queue_redraw()

func _draw() -> void:
    var stone := Color("#8d939b")
    var edge := Color("#525a66")
    var engraved := Color("#3b4653")
    draw_ellipse_placeholder(Vector2(0, 26), Vector2(40, 10), Color(0, 0, 0, 0.28))
    draw_rect(Rect2(-19, -13, 38, 39), edge)
    draw_circle(Vector2(0, -13), 19, edge)
    draw_rect(Rect2(-16, -13, 32, 36), stone)
    draw_circle(Vector2(0, -13), 16, stone)
    draw_string(ThemeDB.fallback_font, Vector2(-13, 7), "RIP",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 16, engraved)
    draw_rect(Rect2(-25, 23, 50, 7), edge)
    if is_landed and _impact_age < 0.55:
        var t: float = _impact_age / 0.55
        var dust := Color(0.75, 0.70, 0.62, (1.0 - t) * 0.65)
        draw_circle(Vector2(-21 - 24.0 * t, 24), 6 + 8 * t, dust)
        draw_circle(Vector2(21 + 24.0 * t, 24), 6 + 8 * t, dust)

func draw_ellipse_placeholder(center: Vector2, size: Vector2, color: Color) -> void:
    draw_set_transform(center, 0.0, Vector2(size.x / 2.0, size.y / 2.0))
    draw_circle(Vector2.ZERO, 1, color)
    draw_set_transform(Vector2.ZERO)

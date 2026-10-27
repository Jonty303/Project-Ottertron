extends Node2D
## Tiny overhead health bar; reused by both player and enemy.

@export var bar_fill: Color = Color("#76c87a")
@export var width: float = 46.0
@export var height: float = 7.0

var maximum: int = 1
var current: int = 1

func set_health(amount: int, max_amount: int) -> void:
    maximum = maxi(1, max_amount)
    current = clampi(amount, 0, maximum)
    queue_redraw()

func _draw() -> void:
    var left: float = -width / 2.0
    draw_rect(Rect2(left - 2.0, -2.0, width + 4.0, height + 4.0), Color("#17212a"))
    draw_rect(Rect2(left, 0.0, width, height), Color("#633945"))
    var filled: float = width * float(current) / float(maximum)
    if filled > 0.0:
        draw_rect(Rect2(left, 0.0, filled, height), bar_fill)

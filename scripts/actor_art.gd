extends Node2D
## Deliberately simple static 64x64 placeholders. Replace with approved sprites later.

@export_enum("otter", "colin", "doughnut") var kind: String = "otter"
var facing: Vector2 = Vector2.DOWN

func set_facing(direction: Vector2) -> void:
    if direction.length_squared() > 0.01:
        facing = direction.normalized()
        queue_redraw()

func _draw() -> void:
    match kind:
        "otter":
            _draw_otter()
        "colin":
            _draw_colin()
        "doughnut":
            _draw_doughnut()

func _draw_otter() -> void:
    var brown := Color("#986244")
    var dark_brown := Color("#57372e")
    var cream := Color("#f8e1b7")
    var blush := Color("#e99586")
    var eyes := Color("#221b20")
    var facing_back: bool = facing.y < -0.40
    var shift: float = clampf(facing.x, -1.0, 1.0) * 5.0

    # Rounded head and stocky cuddly body in a 64x64 footprint.
    draw_circle(Vector2(0, 12), 21, dark_brown)
    draw_circle(Vector2(0, 11), 19, brown)
    draw_circle(Vector2(-16, -17), 8, dark_brown)
    draw_circle(Vector2(16, -17), 8, dark_brown)
    draw_circle(Vector2(-16, -17), 6, brown)
    draw_circle(Vector2(16, -17), 6, brown)
    draw_circle(Vector2(0, -8), 23, dark_brown)
    draw_circle(Vector2(0, -8), 21, brown)
    draw_circle(Vector2(-15, 14), 7, brown)
    draw_circle(Vector2(15, 14), 7, brown)
    draw_circle(Vector2(-13, 28), 6, dark_brown)
    draw_circle(Vector2(13, 28), 6, dark_brown)
    if facing_back:
        draw_circle(Vector2(3, 21), 9, dark_brown)
        draw_circle(Vector2(3, 21), 7, brown)
        return

    draw_circle(Vector2(0, 9), 15, cream)
    draw_circle(Vector2(shift, -8), 15, cream)
    draw_circle(Vector2(-9 + shift, -10), 4, eyes)
    draw_circle(Vector2(9 + shift, -10), 4, eyes)
    draw_circle(Vector2(-10 + shift, -11), 1.5, Color.WHITE)
    draw_circle(Vector2(8 + shift, -11), 1.5, Color.WHITE)
    draw_circle(Vector2(shift, -1), 4.5, dark_brown)
    draw_circle(Vector2(shift, 6), 3.5, blush)
    draw_line(Vector2(-2 + shift, 4), Vector2(shift, 6), eyes, 1.6)
    draw_line(Vector2(shift, 6), Vector2(2 + shift, 4), eyes, 1.6)
    for side in [-1, 1]:
        var x: float = float(side) * 9.0 + shift
        draw_line(Vector2(x, 3), Vector2(x + float(side) * 12.0, 1), cream, 1.4)
        draw_line(Vector2(x, 6), Vector2(x + float(side) * 12.0, 8), cream, 1.4)

func _draw_colin() -> void:
    var cardigan := Color("#e4ae37")
    var cardigan_dark := Color("#ac751f")
    var skin := Color("#fac9ad")
    var outline := Color("#59382d")
    var trousers := Color("#57453d")
    var facing_back: bool = facing.y < -0.40
    var shift: float = clampf(facing.x, -1.0, 1.0) * 4.5

    draw_circle(Vector2(0, 17), 20, outline)
    draw_circle(Vector2(0, 15), 19, trousers)
    draw_rect(Rect2(-21, -1, 42, 26), cardigan_dark)
    draw_rect(Rect2(-19, 0, 38, 22), cardigan)
    draw_circle(Vector2(-22, 12), 7, cardigan)
    draw_circle(Vector2(22, 12), 7, cardigan)
    draw_circle(Vector2(-22, 18), 4.5, skin)
    draw_circle(Vector2(22, 18), 4.5, skin)
    draw_rect(Rect2(-16, 26, 12, 5), outline)
    draw_rect(Rect2(4, 26, 12, 5), outline)
    draw_circle(Vector2(0, -12), 23, outline)
    draw_circle(Vector2(0, -12), 21, skin)
    draw_circle(Vector2(-20, -9), 5, skin)
    draw_circle(Vector2(20, -9), 5, skin)
    if facing_back:
        draw_line(Vector2(-14, 0), Vector2(14, 0), cardigan_dark, 2)
        return

    # A recognisable large pair of dark square glasses.
    draw_rect(Rect2(-18 + shift, -17, 16, 13), outline, false, 2.5)
    draw_rect(Rect2(2 + shift, -17, 16, 13), outline, false, 2.5)
    draw_line(Vector2(-2 + shift, -12), Vector2(2 + shift, -12), outline, 2)
    draw_circle(Vector2(-10 + shift, -10), 2, outline)
    draw_circle(Vector2(10 + shift, -10), 2, outline)
    draw_circle(Vector2(shift, -3), 3.5, Color("#ea9f88"))
    draw_line(Vector2(-4 + shift, 3), Vector2(4 + shift, 3), outline, 1.5)
    draw_rect(Rect2(-6, -1, 12, 6), Color("#f5eee6"))
    draw_rect(Rect2(-3, 0, 6, 9), Color("#333d47"))
    draw_circle(Vector2(0, 10), 2, outline)
    draw_circle(Vector2(0, 17), 2, outline)

func _draw_doughnut() -> void:
    var crust := Color("#b15d21")
    var dough := Color("#ea9c50")
    var glaze := Color("#f9dfbc")
    draw_circle(Vector2.ZERO, 11, crust)
    draw_circle(Vector2.ZERO, 9, dough)
    draw_circle(Vector2(0, -1), 7.5, glaze)
    draw_circle(Vector2.ZERO, 4, crust)
    draw_circle(Vector2(-6, -4), 1.2, Color.WHITE)
    draw_circle(Vector2(5, 5), 1.2, Color.WHITE)

extends Area2D
## Three separate, persistent, stackable upgrades: damage, speed and size.

signal collected(at: Vector2, kind: String, amount: float)

@export_enum("damage", "speed", "size") var upgrade_kind: String = "damage"
@export var damage_bonus: float = 1.0
@export var speed_bonus: float = 70.0
@export var size_bonus: float = 0.18

var _picked_up: bool = false
var _phase: float = 0.0

func _ready() -> void:
    add_to_group("power_ups")
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    _phase += delta * 2.6
    queue_redraw()

func _draw() -> void:
    var bob: Vector2 = Vector2(0, sin(_phase) * 3.0)
    var highlight: Color = Color("#ff907b")
    var symbol: String = "D"
    match upgrade_kind:
        "speed":
            highlight = Color("#77dcff")
            symbol = "S"
        "size":
            highlight = Color("#cb9dff")
            symbol = "+"
    draw_circle(bob, 22.0, Color(highlight.r, highlight.g, highlight.b, 0.20))
    draw_circle(bob, 16.0, Color("#70451f"))
    draw_circle(bob, 13.0, highlight)
    draw_circle(bob, 6.0, Color("#70451f"))
    draw_string(ThemeDB.fallback_font, bob + Vector2(-5, 5), symbol,
        HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color.WHITE)
    draw_line(bob + Vector2(2, -20), bob + Vector2(2, -25), Color.WHITE, 2.0)

func _on_body_entered(body: Node2D) -> void:
    if _picked_up or not body.has_method("apply_doughnut_upgrade"):
        return
    _picked_up = true
    var amount: float = 1.0
    match upgrade_kind:
        "damage":
            amount = damage_bonus
        "speed":
            amount = speed_bonus
        "size":
            amount = size_bonus
    body.call("apply_doughnut_upgrade", upgrade_kind, amount)
    collected.emit(global_position, upgrade_kind, amount)
    queue_free()

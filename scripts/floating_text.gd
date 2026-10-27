extends Node2D
## World-space damage and status popups, drifting up and fading out.

@export var lifetime: float = 0.95
@export var rise_speed: float = 43.0

var _text: String = ""
var _text_color: Color = Color.WHITE
var _remaining: float = 0.95

func configure(message: String, color: Color) -> void:
    _text = message
    _text_color = color

func _ready() -> void:
    _remaining = lifetime
    z_index = 10
    var label := Label.new()
    label.text = _text
    label.position = Vector2(-95, -16)
    label.size = Vector2(190, 36)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 20)
    label.add_theme_color_override("font_color", _text_color)
    label.add_theme_color_override("font_outline_color", Color("#10151b"))
    label.add_theme_constant_override("outline_size", 4)
    add_child(label)

func _process(delta: float) -> void:
    position.y -= rise_speed * delta
    _remaining -= delta
    modulate.a = clampf(_remaining / lifetime, 0.0, 1.0)
    if _remaining <= 0.0:
        queue_free()

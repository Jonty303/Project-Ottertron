extends Area2D
## Pop-up trap: 2 damage on triggering, resets after the player leaves and cooldown.

@export var damage: int = 2
@export var trigger_delay: float = 0.12
@export var pop_duration: float = 0.68
@export var reset_seconds: float = 2.8

var triggered: bool = false
var pop_fraction: float = 0.0
var _age: float = 0.0
var _cooldown: float = 0.0
var _occupant: Node2D
var _damage_dealt: bool = false

func _ready() -> void:
    collision_layer = 0
    collision_mask = 1
    add_to_group("hazards")
    var area_shape := CircleShape2D.new()
    area_shape.radius = 30.0
    var collider := CollisionShape2D.new()
    collider.shape = area_shape
    add_child(collider)
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player") or triggered or _cooldown > 0.0:
        return
    triggered = true
    _occupant = body
    _age = 0.0
    _damage_dealt = false
    queue_redraw()

func _on_body_exited(body: Node2D) -> void:
    if body == _occupant:
        _occupant = null

func _process(delta: float) -> void:
    if _cooldown > 0.0:
        _cooldown = maxf(0.0, _cooldown - delta)
    if triggered:
        _age += delta
        pop_fraction = clampf((_age - trigger_delay * 0.35) / 0.18, 0.0, 1.0)
        if not _damage_dealt and _age >= trigger_delay:
            _damage_dealt = true
            if is_instance_valid(_occupant) and _occupant.has_method("take_damage"):
                _occupant.take_damage(damage, "Pop-up spike trap")
        if _age >= pop_duration:
            triggered = false
            pop_fraction = 0.0
            _cooldown = reset_seconds
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 32, Color("#35383b"))
    draw_circle(Vector2.ZERO, 28, Color("#a3815b"))
    draw_circle(Vector2.ZERO, 24, Color("#423c35"))
    for i in range(8):
        var theta: float = TAU * float(i) / 8.0
        var centre := Vector2(cos(theta), sin(theta)) * 15.0
        draw_colored_polygon(PackedVector2Array([
            centre + Vector2(-6, 4), centre + Vector2(6, 4),
            centre + Vector2(0, -3.0 - 19.0 * pop_fraction)
        ]), Color("#b5bec2" if triggered else "#787c7c"))

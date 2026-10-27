extends Area2D
## Enemy pencil projectile: breaks on first impact, hurts player or other Colins.

signal snapped(at: Vector2)
signal damage_dealt(at: Vector2, amount: int, victim_is_player: bool)

@export var flight_speed: float = 390.0
@export var lifetime: float = 2.5
@export var minimum_damage: int = 1
@export var maximum_damage: int = 10
@export var damage_multiplier: float = 1.0

var direction: Vector2 = Vector2.RIGHT
var shooter: Node2D
var _spent: bool = false
var _remaining: float = 2.5

func _ready() -> void:
    add_to_group("projectiles")
    _remaining = lifetime
    if direction.length_squared() > 0.01:
        direction = direction.normalized()
    rotation = direction.angle()
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    position += direction * flight_speed * delta
    _remaining -= delta
    if _remaining <= 0.0:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if _spent or body == shooter:
        return
    _spent = true
    if body.has_method("take_damage"):
        var low: int = maxi(1, mini(minimum_damage, maximum_damage))
        var high: int = maxi(low, maxi(minimum_damage, maximum_damage))
        var attempted: int = maxi(1, ceili(float(randi_range(low, high)) * damage_multiplier))
        var applied: int = 0
        if body.is_in_group("player"):
            var source: String = "Boss Colin's pencil" if is_instance_valid(shooter) and shooter.variant == "boss" else "Blue Colin's pencil"
            applied = int(body.call("take_damage", attempted, source))
        else:
            applied = int(body.call("take_damage", attempted))
        if applied > 0:
            damage_dealt.emit(body.global_position, applied, body.is_in_group("player"))
    snapped.emit(global_position)
    queue_free()

func _draw() -> void:
    # Horizontal, sharpened pencil aimed by rotating the projectile node.
    draw_rect(Rect2(-16, -3.5, 23, 7), Color("#d2a42e"))
    draw_rect(Rect2(-15, -2, 20, 4), Color("#f7d95b"))
    draw_rect(Rect2(-20, -3.5, 4, 7), Color("#a7b1b8"))
    draw_rect(Rect2(-24, -3, 4, 6), Color("#ef7793"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(7, -3.5), Vector2(17, 0), Vector2(7, 3.5)
    ]), Color("#d8b387"))
    draw_colored_polygon(PackedVector2Array([
        Vector2(13.5, -1.3), Vector2(17, 0), Vector2(13.5, 1.3)
    ]), Color("#363338"))

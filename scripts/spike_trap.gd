extends Area2D
## A faint ground hole. Spikes pop when ANY living actor steps on the plate,
## damaging every occupant once. They retract as soon as the last one leaves.

@export var damage: int = 2
@export var trigger_delay: float = 0.12
@export var reset_seconds: float = 0.45

var triggered: bool = false
var pop_fraction: float = 0.0
var _age: float = 0.0
var _cooldown: float = 0.0
var _occupants: Array[Node2D] = []
var _damaged: Array[Node2D] = []

func _ready() -> void:
    collision_layer = 0
    collision_mask = 3
    add_to_group("hazards")
    var shape := CircleShape2D.new()
    shape.radius = 30.0
    var collider := CollisionShape2D.new()
    collider.shape = shape
    add_child(collider)
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if not (body.is_in_group("player") or body.is_in_group("enemies")):
        return
    if _occupants.has(body):
        return
    _occupants.append(body)
    if _cooldown <= 0.0 and not triggered:
        triggered = true
        _age = 0.0
        _damaged.clear()
    elif triggered and _age >= trigger_delay:
        _damage_occupant(body)
    queue_redraw()

func _on_body_exited(body: Node2D) -> void:
    _occupants.erase(body)
    if _occupants.is_empty() and triggered:
        triggered = false
        pop_fraction = 0.0
        _cooldown = reset_seconds
        _damaged.clear()
    queue_redraw()

func _damage_occupant(actor: Node2D) -> void:
    if not is_instance_valid(actor) or _damaged.has(actor) or not actor.has_method("take_damage"):
        return
    _damaged.append(actor)
    if actor.is_in_group("player"):
        actor.take_damage(damage, "Pop-up spike trap")
    else:
        actor.take_damage(damage)

func _process(delta: float) -> void:
    if _cooldown > 0.0:
        _cooldown = maxf(0.0, _cooldown - delta)
    _occupants = _occupants.filter(func(actor: Node2D) -> bool:
        return is_instance_valid(actor) and (actor.is_in_group("player") or actor.is_in_group("enemies")))
    if triggered:
        _age += delta
        pop_fraction = clampf((_age - trigger_delay * 0.35) / 0.15, 0.0, 1.0)
        if _age >= trigger_delay:
            for actor in _occupants.duplicate():
                _damage_occupant(actor)
        if _occupants.is_empty():
            triggered = false
            pop_fraction = 0.0
            _cooldown = reset_seconds
            _damaged.clear()
    elif _cooldown <= 0.0 and not _occupants.is_empty():
        triggered = true
        _age = 0.0
        _damaged.clear()
    queue_redraw()

func _draw() -> void:
    # Quiet, dark pinholes until stepped on; no permanent raised spikes.
    for i in range(7):
        var a: float = TAU * float(i) / 7.0
        draw_circle(Vector2.RIGHT.rotated(a) * 15.0, 4.0, Color("#1d2727"))
    if not triggered:
        return
    for i in range(8):
        var theta: float = TAU * float(i) / 8.0
        var centre := Vector2(cos(theta), sin(theta)) * 15.0
        draw_colored_polygon(PackedVector2Array([
            centre + Vector2(-6, 4), centre + Vector2(6, 4),
            centre + Vector2(0, -3 - 19 * pop_fraction)
        ]), Color("#ccd4d6"))

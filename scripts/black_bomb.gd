extends Node2D
## Black Colin's thrown bomb or proximity mine. Bombs detonate one second after launch.
signal exploded(at: Vector2, radius: float, damage: int, cause: String)

@export_enum("bomb", "mine") var kind: String = "bomb"
@export var fuse: float = 1.0
@export var flight_duration: float = 0.42
@export var normal_radius: float = 112.0
@export var mine_radius: float = 180.0
@export var trigger_radius: float = 29.0
@export var min_damage: int = 1
@export var max_damage: int = 10
var destination: Vector2
var damage_multiplier: float = 1.0
var shooter: Node2D
var armed: bool = false
var _elapsed: float = 0.0
var _detonated: bool = false

func _ready() -> void:
    add_to_group("black_ordnance")
    if kind == "mine":
        add_to_group("armed_mines")
    z_index = 5

func _process(delta: float) -> void:
    if _detonated:
        return
    _elapsed += delta
    if _elapsed <= flight_duration:
        # Flight is a little arc, with the shadow remaining at landing position.
        var t: float = clampf(_elapsed / maxf(0.01, flight_duration), 0.0, 1.0)
        global_position = global_position.lerp(destination, t)
    else:
        global_position = destination
        armed = true
    if kind == "bomb":
        if _elapsed >= fuse:
            detonate()
    elif armed:
        for actor in get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("enemies"):
            if not is_instance_valid(actor) or actor.health <= 0:
                continue
            if actor.global_position.distance_squared_to(global_position) <= trigger_radius * trigger_radius:
                detonate()
                break
    queue_redraw()

func detonate() -> void:
    if _detonated:
        return
    _detonated = true
    var radius: float = mine_radius if kind == "mine" else normal_radius
    var rolled: int = randi_range(min_damage, maxi(min_damage, max_damage))
    var damage: int = maxi(1, ceili(float(rolled) * damage_multiplier))
    exploded.emit(global_position, radius, damage,
        "Black Colin's mine" if kind == "mine" else "Black Colin's bomb")
    remove_from_group("armed_mines")
    queue_free()

func _draw() -> void:
    var airborne: bool = _elapsed < flight_duration
    var wobble: float = 5.0 * sin(_elapsed * 15.0)
    if kind == "mine":
        draw_circle(Vector2.ZERO, 18, Color("#26262c"))
        draw_circle(Vector2.ZERO, 13, Color("#4b4854"))
        draw_circle(Vector2.ZERO, 5, Color("#ed6554" if armed else "#bdab75"))
        if armed:
            draw_arc(Vector2.ZERO, trigger_radius, 0, TAU, 40,
                Color(1.0, 0.26, 0.18, 0.18 + 0.12 * absf(sin(_elapsed * 4.0))), 1.2)
    else:
        draw_circle(Vector2(0, 7), 14, Color(0.0, 0.0, 0.0, 0.22))
        draw_circle(Vector2(0, -wobble if airborne else 0), 15, Color("#292731"))
        draw_circle(Vector2(-5, -6 - (wobble if airborne else 0)), 5, Color("#676778"))
        draw_line(Vector2(0, -16), Vector2(4, -24), Color("#d9aa58"), 2.0)
        if _elapsed > fuse - 0.32:
            draw_circle(Vector2(6, -21), 3, Color("#ffab4e"))

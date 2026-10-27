extends Node2D
## Initial square-room prototype; all runtime nodes are intentionally simple.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const COLIN_SCENE: PackedScene = preload("res://scenes/colin.tscn")
const DOUGHNUT_SCENE: PackedScene = preload("res://scenes/doughnut.tscn")

const ROOM_SIDE: float = 960.0
const WALL_THICKNESS: float = 28.0
const CONTACT_DISTANCE: float = 42.0

var player
var colin
var hud: Label
var _round_finished: bool = false
var _win: bool = false

func _ready() -> void:
    _create_wall(Vector2(0, -ROOM_SIDE / 2.0), Vector2(ROOM_SIDE, WALL_THICKNESS))
    _create_wall(Vector2(0, ROOM_SIDE / 2.0), Vector2(ROOM_SIDE, WALL_THICKNESS))
    _create_wall(Vector2(-ROOM_SIDE / 2.0, 0), Vector2(WALL_THICKNESS, ROOM_SIDE))
    _create_wall(Vector2(ROOM_SIDE / 2.0, 0), Vector2(WALL_THICKNESS, ROOM_SIDE))

    player = PLAYER_SCENE.instantiate()
    player.position = Vector2(-150, 0)
    add_child(player)
    player.fire_requested.connect(_on_player_fire)
    player.health_changed.connect(_on_health_changed)
    player.defeated.connect(_on_player_defeated)

    colin = COLIN_SCENE.instantiate()
    colin.position = Vector2(170, 45)
    colin.target = player
    add_child(colin)
    colin.defeated.connect(_on_colin_defeated)

    var camera := Camera2D.new()
    camera.zoom = Vector2(1.0, 1.0)
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0
    player.add_child(camera)
    camera.make_current()

    var interface := CanvasLayer.new()
    add_child(interface)
    hud = Label.new()
    hud.position = Vector2(24, 20)
    hud.add_theme_font_size_override("font_size", 21)
    interface.add_child(hud)

    var instructions := Label.new()
    instructions.text = "Left stick: move     Right stick: aim + fire     |     Keyboard: WASD + arrows"
    instructions.position = Vector2(24, 678)
    instructions.add_theme_font_size_override("font_size", 16)
    interface.add_child(instructions)
    _update_hud()

func _draw() -> void:
    draw_rect(Rect2(-ROOM_SIDE / 2.0, -ROOM_SIDE / 2.0, ROOM_SIDE, ROOM_SIDE), Color("#263540"))
    var start: int = -int(ROOM_SIDE / 2.0)
    var finish: int = int(ROOM_SIDE / 2.0)
    for coordinate in range(start, finish, 64):
        draw_line(Vector2(coordinate, start), Vector2(coordinate, finish), Color("#30414a"), 1)
        draw_line(Vector2(start, coordinate), Vector2(finish, coordinate), Color("#30414a"), 1)
    draw_rect(Rect2(-ROOM_SIDE / 2.0, -ROOM_SIDE / 2.0, ROOM_SIDE, ROOM_SIDE), Color("#526575"), false, WALL_THICKNESS)

func _process(_delta: float) -> void:
    if _round_finished:
        if Input.is_key_pressed(KEY_R) or _restart_button_pressed():
            get_tree().reload_current_scene()
        return

    if is_instance_valid(colin) and player.global_position.distance_to(colin.global_position) < CONTACT_DISTANCE:
        player.take_damage(1)

func _restart_button_pressed() -> bool:
    var pads: Array[int] = Input.get_connected_joypads()
    return not pads.is_empty() and Input.is_joy_button_pressed(pads[0], JOY_BUTTON_A)

func _create_wall(at: Vector2, wall_size: Vector2) -> void:
    var body := StaticBody2D.new()
    body.position = at
    body.collision_layer = 8
    body.collision_mask = 0
    var shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = wall_size
    shape.shape = rectangle
    body.add_child(shape)
    add_child(body)

func _on_player_fire(direction: Vector2) -> void:
    if _round_finished:
        return
    var shot = DOUGHNUT_SCENE.instantiate()
    shot.direction = direction
    shot.global_position = player.global_position + direction * 36.0
    add_child(shot)

func _on_health_changed(_current_health: int) -> void:
    _update_hud()

func _on_player_defeated() -> void:
    _round_finished = true
    _win = false
    _update_hud()

func _on_colin_defeated() -> void:
    _round_finished = true
    _win = true
    _update_hud()

func _update_hud() -> void:
    if hud == null:
        return
    if _round_finished:
        hud.text = ("COLIN DEFEATED!" if _win else "THE OTTER WAS DEFEATED!") + "  |  Press R or A/Cross to restart"
    else:
        hud.text = "OTTER  HP %d/3     |     COLIN HP %d/3" % [player.health, (colin.health if is_instance_valid(colin) else 0)]

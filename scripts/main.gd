extends Node2D
## Square combat room, one Colin, one collectible weapon upgrade and floating text.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const COLIN_SCENE: PackedScene = preload("res://scenes/colin.tscn")
const DOUGHNUT_SCENE: PackedScene = preload("res://scenes/doughnut.tscn")
const POWER_UP_SCENE: PackedScene = preload("res://scenes/power_up.tscn")
const FLOATING_TEXT = preload("res://scripts/floating_text.gd")

const ROOM_SIDE: float = 960.0
const WALL_THICKNESS: float = 28.0

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
    player.damage_taken.connect(_on_player_damage_taken)
    player.doughnut_stats_changed.connect(_on_doughnut_stats_changed)
    player.defeated.connect(_on_player_defeated)

    colin = COLIN_SCENE.instantiate()
    colin.position = Vector2(170, 45)
    colin.target = player
    add_child(colin)
    colin.defeated.connect(_on_colin_defeated)
    colin.aura_started.connect(_on_aura_started)
    colin.aura_broken.connect(_on_aura_broken)
    colin.aura_tick.connect(_on_aura_tick)

    # Prototype pickup; collecting it raises damage and projectile speed.
    var power_up = POWER_UP_SCENE.instantiate()
    power_up.position = Vector2(-30, -160)
    add_child(power_up)
    power_up.collected.connect(_on_powerup_collected)

    var camera := Camera2D.new()
    camera.zoom = Vector2.ONE
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0
    player.add_child(camera)
    camera.make_current()

    var interface := CanvasLayer.new()
    add_child(interface)
    hud = Label.new()
    hud.position = Vector2(24, 16)
    hud.add_theme_font_size_override("font_size", 20)
    hud.add_theme_color_override("font_outline_color", Color("#0b1218"))
    hud.add_theme_constant_override("outline_size", 3)
    interface.add_child(hud)

    var instructions := Label.new()
    instructions.text = "MOVE: left stick / WASD      FIRE: right stick / arrows      PICK UP: glowing doughnut"
    instructions.position = Vector2(24, 678)
    instructions.add_theme_font_size_override("font_size", 16)
    interface.add_child(instructions)
    _update_hud()

func _draw() -> void:
    var start: float = -ROOM_SIDE / 2.0
    var finish: float = ROOM_SIDE / 2.0
    draw_rect(Rect2(start, start, ROOM_SIDE, ROOM_SIDE), Color("#263540"))
    for coordinate in range(int(start), int(finish), 64):
        draw_line(Vector2(coordinate, start), Vector2(coordinate, finish), Color("#30414a"), 1)
        draw_line(Vector2(start, coordinate), Vector2(finish, coordinate), Color("#30414a"), 1)
    draw_rect(Rect2(start, start, ROOM_SIDE, ROOM_SIDE), Color("#526575"), false, WALL_THICKNESS)

func _process(_delta: float) -> void:
    if _round_finished and (Input.is_key_pressed(KEY_R) or _restart_button_pressed()):
        get_tree().reload_current_scene()

func _restart_button_pressed() -> bool:
    var pads: Array[int] = Input.get_connected_joypads()
    return not pads.is_empty() and Input.is_joy_button_pressed(pads[0], JOY_BUTTON_A)

func _create_wall(at: Vector2, wall_size: Vector2) -> void:
    var body := StaticBody2D.new()
    body.position = at
    body.collision_layer = 8
    body.collision_mask = 0
    var collider := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = wall_size
    collider.shape = rectangle
    body.add_child(collider)
    add_child(body)

func _on_player_fire(direction: Vector2) -> void:
    if _round_finished:
        return
    var shot = DOUGHNUT_SCENE.instantiate()
    shot.direction = direction
    shot.damage = player.doughnut_damage
    shot.speed = player.doughnut_speed
    shot.position = player.position + direction * 36.0
    add_child(shot)
    shot.damage_dealt.connect(_on_doughnut_damage)

func _on_doughnut_damage(at: Vector2, amount: int) -> void:
    _floating_text(at + Vector2(0, -50), "-%d" % amount, Color("#ffd56b"))
    _update_hud()

func _on_player_damage_taken(amount: int) -> void:
    _floating_text(player.global_position + Vector2(0, -55), "-%d" % amount, Color("#ff7a91"))

func _on_health_changed(_current_health: int) -> void:
    _update_hud()

func _on_doughnut_stats_changed(_damage: int, _speed: float) -> void:
    _update_hud()

func _on_powerup_collected(at: Vector2, added_damage: int, added_speed: float) -> void:
    _floating_text(at + Vector2(0, -42), "POWER UP!  +%d DMG  +%d SPEED" % [added_damage, roundi(added_speed)], Color("#8fe7fa"))
    _update_hud()

func _on_aura_started() -> void:
    _floating_text(colin.global_position + Vector2(0, -65), "LIFE DRAIN", Color("#d3a7ff"))
    _update_hud()

func _on_aura_broken() -> void:
    if is_instance_valid(colin) and not _round_finished:
        _floating_text(colin.global_position + Vector2(0, -65), "DRAIN BROKEN", Color("#aeeada"))
    _update_hud()

func _on_aura_tick(_damage: int) -> void:
    _update_hud()

func _on_player_defeated() -> void:
    _round_finished = true
    _win = false
    if is_instance_valid(colin):
        colin.set_physics_process(false)
        colin.set_process(false)
    _update_hud()

func _on_colin_defeated() -> void:
    _round_finished = true
    _win = true
    _update_hud()

func _floating_text(at: Vector2, message: String, color: Color) -> void:
    var popup = FLOATING_TEXT.new()
    popup.configure(message, color)
    add_child(popup)
    popup.global_position = at

func _update_hud() -> void:
    if hud == null or not is_instance_valid(player):
        return
    if _round_finished:
        hud.text = ("COLIN DEFEATED!" if _win else "THE OTTER WAS DEFEATED!") + "   |   R or A/Cross to restart"
        return
    var colin_health: int = colin.health if is_instance_valid(colin) else 0
    var aura_state: String = "CHANNELING" if is_instance_valid(colin) and colin.aura_active else "OFF"
    hud.text = "OTTER  %d/%d HP     COLIN  %d/2 HP\nDOUGHNUT  %d damage  |  %d speed     AURA  %s" % [
        player.health, player.max_health, colin_health,
        player.doughnut_damage, roundi(player.doughnut_speed), aura_state
    ]

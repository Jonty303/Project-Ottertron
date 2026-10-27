extends SceneTree
## Verify boon joypad selection and camera world bounds in Godot 4.5.2.

const GAME = preload("res://scenes/main.tscn")
var failures: int = 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error("OTTERTRON CAMERA/CONTROLLER TEST FAILED: " + reason)

func _pad_button(index: JoyButton) -> InputEventJoypadButton:
    var event := InputEventJoypadButton.new()
    event.button_index = index
    event.pressed = true
    return event

func _stick_vertical(strength: float) -> InputEventJoypadMotion:
    var event := InputEventJoypadMotion.new()
    event.axis = JOY_AXIS_LEFT_Y
    event.axis_value = strength
    return event

func _run() -> void:
    var game = GAME.instantiate()
    root.add_child(game)
    await process_frame

    var viewport_size: Vector2 = game.get_viewport().get_visible_rect().size
    check(viewport_size == Vector2(1280, 800), "Viewport resolution is 1280x800")

    var cameras: Array = game.player.get_children().filter(
        func(node: Node) -> bool: return node is Camera2D)
    check(cameras.size() == 1, "Exactly one camera follows the otter")
    if cameras.size() == 1:
        var camera = cameras[0]
        check(is_equal_approx(camera.zoom.x, 0.85) and is_equal_approx(camera.zoom.y, 0.85),
            "Camera shows more world by using 0.85x zoom")
        check(camera.limit_enabled, "Camera world limits are on")
        check(not camera.position_smoothing_enabled and not camera.limit_smoothed,
            "Smoothing cannot move the viewport beyond world limits")
        check(camera.offset == Vector2.ZERO, "No camera offset can override world limits")
        var half_visible: Vector2 = viewport_size / (camera.zoom * 2.0)
        check(half_visible.x * 2.0 < float(camera.limit_right - camera.limit_left),
            "Visible world fits inside the arena horizontally")
        check(half_visible.y * 2.0 < float(camera.limit_bottom - camera.limit_top),
            "Visible world fits inside the arena vertically")

        for corner in [
            Vector2(0.0, 0.0),
            Vector2(-855.0, -855.0),
            Vector2(855.0, 855.0),
            Vector2(-855.0, 855.0),
            Vector2(855.0, -855.0)
        ]:
            game.player.position = corner
            camera.force_update_scroll()
            await process_frame
            var centre: Vector2 = camera.get_screen_center_position()
            check(centre.x - half_visible.x >= float(camera.limit_left) - 2.0,
                "Camera never shows outside left boundary at " + str(corner))
            check(centre.x + half_visible.x <= float(camera.limit_right) + 2.0,
                "Camera never shows outside right boundary at " + str(corner))
            check(centre.y - half_visible.y >= float(camera.limit_top) - 2.0,
                "Camera never shows outside top boundary at " + str(corner))
            check(centre.y + half_visible.y <= float(camera.limit_bottom) + 2.0,
                "Camera never shows outside bottom boundary at " + str(corner))

    game._offer_boon()
    check(game._boon_open and game._boon_overlay.visible,
        "Boon overlay opens for controller input")
    check(game._boon_buttons.size() == 3, "Three focusable boon buttons")
    check(game._boon_selection_index == 0, "First boon selected initially")
    check(game.player.status_paused, "Movement and burn paused during boon menu")

    game._input(_pad_button(JOY_BUTTON_DPAD_DOWN))
    check(game._boon_selection_index == 1, "D-pad down selects second boon")
    game._input(_pad_button(JOY_BUTTON_DPAD_UP))
    check(game._boon_selection_index == 0, "D-pad up selects previous boon")

    game._input(_stick_vertical(0.95))
    check(game._boon_selection_index == 1, "Left stick down selects next boon")
    game._input(_stick_vertical(0.95))
    check(game._boon_selection_index == 1, "Holding the stick does not skip boons")
    game._input(_stick_vertical(0.0))
    game._input(_stick_vertical(0.95))
    check(game._boon_selection_index == 2, "Re-centering stick enables next move")
    game._input(_stick_vertical(0.0))

    game._input(_pad_button(JOY_BUTTON_A))
    check(not game._boon_open, "A/Cross confirms the selected boon")
    check(game.boons_chosen.size() == 1 and game.boons_chosen[0] == "ferocity",
        "A/Cross chooses the correct highlighted boon")
    check(is_equal_approx(game.enemy_damage_multiplier, 1.25),
        "Chosen boon applies enemy trade-off")
    check(is_equal_approx(game.player.doughnut_speed_multiplier, 1.25),
        "Chosen boon applies otter benefit")
    check(not game.player.status_paused, "Game resumes after choice")

    game.queue_free()
    await process_frame
    if failures == 0:
        print("OTTERTRON CAMERA/CONTROLLER TEST PASSED: bounded viewport and joypad boon selection")
    quit(0 if failures == 0 else 1)

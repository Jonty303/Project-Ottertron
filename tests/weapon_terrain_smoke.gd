extends SceneTree
## New weapon/teleport/remains/environment regressions.
const GAME = preload("res://scenes/main.tscn")
const DOUGHNUT = preload("res://scenes/doughnut.tscn")
var failures: int = 0

func _initialize() -> void:
    call_deferred("_run")

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error("OTTERTRON V0.9 TEST FAILED: " + description)

func _run() -> void:
    var game = GAME.instantiate()
    root.add_child(game)
    await process_frame
    check(game.wave == 1 and game.enemies.size() == 8, "Eight Colins appear in starting wave")
    check(game.boon_order.size() == 3, "Exactly three boon options are available")
    check(game.BOON_POOL.size() == 7, "Seven possible boon types exist")
    check(get_nodes_in_group("enemies").size() == 8, "All enemies registered")
    var colin = game.enemies[0]
    check(colin.spawn_delay > 0.0, "New enemies arrive via teleport delay")
    var teleport_script = load("res://scripts/teleport_fx.gd")
    check(game.get_children().any(func(child: Node) -> bool:
        return child.get_script() == teleport_script), "Wave creates teleport effects")

    # Pick all four new boons independently, check their combined effect.
    for boon in ["angle", "double", "pierce", "blast"]:
        game._offer_boon()
        game._choose_boon(boon)
    check(game.player.boon_angled and game.player.boon_extra_shot, "Angled and double shot upgrades stack")
    check(game.player.boon_piercing and game.player.boon_front_explosion,
        "Piercing and front blast boons can coexist")

    game._on_player_fire(Vector2.RIGHT)
    var projectiles = get_nodes_in_group("projectiles").filter(
        func(node: Node) -> bool: return node.get_script() == load("res://scripts/doughnut.gd"))
    check(projectiles.size() == 6, "One front lane and two diagonals all double to six projectiles")
    var burst: int = 0
    var piercing: int = 0
    for shot in projectiles:
        if shot.exploding_front:
            burst += 1
            check(not shot.piercing, "Explosive front shot never pierces")
        if shot.piercing:
            piercing += 1
    check(burst == 2 and piercing == 4, "Two front blasts and four piercing diagonals")

    # A piercing doughnut strikes two enemies exactly once each.
    var pierce_shot = DOUGHNUT.instantiate()
    pierce_shot.piercing = true
    pierce_shot.critical_chance = 0.0
    game.add_child(pierce_shot)
    var victim_a = game.enemies[0]
    var victim_b = game.enemies[1]
    victim_a.explosion_chance = 0.0
    victim_b.explosion_chance = 0.0
    pierce_shot._on_body_entered(victim_a)
    pierce_shot._on_body_entered(victim_a)
    pierce_shot._on_body_entered(victim_b)
    check(victim_a.health == 9 and victim_b.health == 9,
        "Piercing hits two Colins but never the same enemy twice")
    check(not pierce_shot._consumed, "Piercing doughnut persists across enemy hits")

    # A shrub takes three projectile collisions and leaves permanent, non-solid leaves.
    var plants = get_nodes_in_group("obstacles").filter(
        func(node: Node) -> bool: return node.kind == "plant")
    check(plants.size() > 0, "Arena contains bushes")
    if not plants.is_empty():
        var bush = plants[0]
        for hit in range(3):
            var projectile = DOUGHNUT.instantiate()
            projectile.piercing = true
            game.add_child(projectile)
            projectile._on_body_entered(bush)
            check(bush.bush_hits == hit + 1, "Bush counts each projectile impact")
        check(bush.destroyed, "Bush collapses after third hit")
        check(bush.collision_layer == 0 and not bush.is_in_group("obstacles"),
            "Destroyed bush no longer blocks shots or movement")
        check(is_instance_valid(bush) and not bush.is_queued_for_deletion(),
            "Leaf pile is permanent")

    # Enemy death creates permanent bone piles.
    var bones_script = load("res://scripts/bone_pile.gd")
    victim_a.take_damage(10)
    check(game.get_children().any(func(child: Node) -> bool:
        return child.get_script() == bones_script), "Enemy death leaves bone pile")
    check(game.get_children().any(func(child: Node) -> bool:
        return child.get_script() == bones_script and not child.is_queued_for_deletion()),
        "Bones persist after death")

    # Finish teleport arrival before testing contact between active combatants.
    for arriving in game.enemies:
        if is_instance_valid(arriving) and arriving.health > 0:
            arriving.spawn_delay = 0.71
            arriving._process(0.72)
    # Enemy fire is contagious; burning targets don't have timers reset every frame.
    var living = game.enemies.filter(func(enemy: Node2D) -> bool: return enemy.health > 0)
    check(living.size() >= 2, "Two living Colins remain")
    if living.size() >= 2:
        var burning = living[0]
        var other = living[1]
        burning.position = Vector2(200, 250)
        other.position = burning.position + Vector2(38, 0)
        burning.apply_burn(5)
        game._physics_process(0.016)
        check(other.burn_ticks_left == 5, "Burning Colin ignites nearby Colin")
        other._tick_burn(1.0)
        game._physics_process(0.016)
        check(other.burn_ticks_left == 4, "Contact does not perpetually refresh burn")
        game.player.position = burning.position + Vector2(0, 36)
        game._physics_process(0.016)
        check(game.player.burn_ticks_left == 5, "Burning Colin ignites the otter")
        other.position = Vector2(400, 400)
        burning.position = Vector2(420, 400)
        var avoidance: Vector2 = burning._avoid_burning_neighbours(Vector2.UP)
        check(avoidance.x > 0.05, "Burning Colin steers sideways away from another Colin")

    game.queue_free()
    await process_frame
    if failures == 0:
        print("OTTERTRON V0.9 TEST PASSED: wave teleport, shot boons, bush hits, bones and contagious fire")
    quit(0 if failures == 0 else 1)

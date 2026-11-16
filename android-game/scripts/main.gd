extends Node3D

var hero
var slime
var boss
var game_state
var move_vector := Vector2.ZERO
var joystick: Control
var knob: Panel
var camera_node: Camera3D
var camera_pivot: Node3D
var camera_touch_index := -1
var camera_last_touch := Vector2.ZERO
var camera_mouse_drag := false
var attack_button: Button
var clone_button: Button
var shadow_clones: Array[Node3D] = []
var clone_attack_timers: Array[float] = []
var clone_time_left := 0.0
var hp_text: Label
var stats_text: Label
var enemy_text: Label
var slime_health_bar: ProgressBar
var boss_health_bar: ProgressBar
var quest_text: Label
var inventory_text: Label
var notice_text: Label
var inventory_panel: PanelContainer
var autosave_timer := 0.0
const SAVE_INTERVAL := 5.0
const START_POSITION := Vector3(0, 0.1, 4)

func _ready() -> void:
    game_state = Node.new()
    game_state.name = "GameState"
    game_state.set_script(load("res://scripts/game_state.gd"))
    add_child(game_state)
    _make_world()
    _make_hud()

func _make_world() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.43, 0.65, 0.82)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.75, 0.79, 0.9)
    env.ambient_light_energy = 0.8
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

    var ground := StaticBody3D.new()
    var ground_mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(70, 70)
    ground_mesh.mesh = plane
    var grass := StandardMaterial3D.new()
    grass.albedo_color = Color(0.20, 0.36, 0.23)
    ground_mesh.material_override = grass
    ground.add_child(ground_mesh)
    var ground_collision := CollisionShape3D.new()
    var ground_shape := BoxShape3D.new()
    ground_shape.size = Vector3(70, 0.2, 70)
    ground_collision.shape = ground_shape
    ground_collision.position.y = -0.1
    ground.add_child(ground_collision)
    add_child(ground)

    for i in range(10):
        var a := TAU * float(i) / 10.0
        var pillar := MeshInstance3D.new()
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.35
        mesh.bottom_radius = 0.5
        mesh.height = 2.8
        pillar.mesh = mesh
        var stone := StandardMaterial3D.new()
        stone.albedo_color = Color(0.38, 0.41, 0.46)
        pillar.material_override = stone
        pillar.position = Vector3(cos(a) * 15.0, 1.4, sin(a) * 15.0)
        add_child(pillar)

    hero = CharacterBody3D.new()
    hero.name = "Hero"
    hero.set_script(load("res://scripts/player.gd"))
    hero.position = game_state.player_position if game_state.has_player_save else START_POSITION
    add_child(hero)
    hero.hp = game_state.player_hp if game_state.has_player_save else 100

    slime = CharacterBody3D.new()
    slime.name = "Slime"
    slime.set_script(load("res://scripts/enemy.gd"))
    slime.position = Vector3(0, 0.1, -5)
    add_child(slime)
    if game_state.quest_completed:
        slime.hp = 0
        slime.visible = false
        hero.slime_reward_claimed = true
    _spawn_dream_crystals()
    if game_state.dream_crystal_quest_completed:
        _spawn_boss()

    camera_pivot = Node3D.new()
    camera_pivot.name = "CameraPivot"
    camera_pivot.position = Vector3(0, 1.1, 0)
    hero.add_child(camera_pivot)
    camera_node = Camera3D.new()
    camera_node.position = Vector3(0, 4.4, 9)
    camera_node.rotation_degrees.x = -23.0
    camera_node.current = true
    camera_pivot.add_child(camera_node)

func _spawn_dream_crystals() -> void:
    if not game_state.quest_completed or game_state.dream_crystal_quest_completed:
        return
    var spots := [
        Vector3(-7.0, 0.0, -3.0),
        Vector3(7.0, 0.0, -6.0),
        Vector3(0.0, 0.0, -12.0)
    ]
    for i in range(game_state.dream_crystals_collected, 3):
        var crystal := Area3D.new()
        crystal.name = "DreamCrystal%d" % i
        crystal.position = spots[i]
        var visual := MeshInstance3D.new()
        var crystal_mesh := SphereMesh.new()
        crystal_mesh.radius = 0.38
        crystal_mesh.height = 0.82
        visual.mesh = crystal_mesh
        var glow := StandardMaterial3D.new()
        glow.albedo_color = Color(0.25, 0.9, 1.0)
        glow.emission_enabled = true
        glow.emission = Color(0.08, 0.65, 1.0)
        glow.emission_energy_multiplier = 1.4
        visual.material_override = glow
        visual.position.y = 0.85
        crystal.add_child(visual)
        var collision := CollisionShape3D.new()
        var shape := SphereShape3D.new()
        shape.radius = 1.0
        collision.shape = shape
        collision.position.y = 0.85
        crystal.add_child(collision)
        crystal.body_entered.connect(_on_dream_crystal_body_entered.bind(crystal))
        add_child(crystal)

func _on_dream_crystal_body_entered(body: Node3D, crystal: Area3D) -> void:
    if body != hero or not is_instance_valid(crystal):
        return
    game_state.collect_dream_crystal()
    crystal.queue_free()
    if game_state.dream_crystal_quest_completed:
        _spawn_boss()

func _spawn_boss() -> void:
    if is_instance_valid(boss):
        return
    boss = CharacterBody3D.new()
    boss.name = "DreamBoss"
    boss.set_script(load("res://scripts/boss.gd"))
    boss.position = Vector3(0.0, 0.1, -9.0)
    add_child(boss)
    if game_state.boss_defeated:
        boss.hp = 0
        boss.visible = false

func _make_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var title := Label.new()
    title.text = "DUNIA DI BALIK MIMPI"
    title.position = Vector2(22, 16)
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
    layer.add_child(title)

    hp_text = Label.new()
    hp_text.position = Vector2(24, 54)
    hp_text.add_theme_font_size_override("font_size", 20)
    layer.add_child(hp_text)

    stats_text = Label.new()
    stats_text.position = Vector2(24, 84)
    stats_text.add_theme_font_size_override("font_size", 18)
    layer.add_child(stats_text)

    enemy_text = Label.new()
    enemy_text.position = Vector2(24, 112)
    enemy_text.add_theme_font_size_override("font_size", 18)
    layer.add_child(enemy_text)

    slime_health_bar = _make_health_bar(layer, Vector2(24, 140), 70.0, Color(0.24, 0.82, 0.42))
    boss_health_bar = _make_health_bar(layer, Vector2(24, 164), 350.0, Color(0.72, 0.28, 0.95))
    boss_health_bar.visible = false

    quest_text = Label.new()
    quest_text.position = Vector2(24, 198)
    quest_text.size = Vector2(420, 55)
    quest_text.add_theme_font_size_override("font_size", 16)
    layer.add_child(quest_text)

    notice_text = Label.new()
    notice_text.position = Vector2(24, 258)
    notice_text.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))
    layer.add_child(notice_text)

    var inventory_button := Button.new()
    inventory_button.text = "TAS"
    inventory_button.position = Vector2(-160, 18)
    inventory_button.size = Vector2(130, 52)
    inventory_button.anchor_left = 1.0
    inventory_button.anchor_right = 1.0
    inventory_button.add_theme_font_size_override("font_size", 18)
    inventory_button.pressed.connect(_toggle_inventory)
    layer.add_child(inventory_button)

    inventory_panel = PanelContainer.new()
    inventory_panel.position = Vector2(-285, 82)
    inventory_panel.size = Vector2(255, 150)
    inventory_panel.anchor_left = 1.0
    inventory_panel.anchor_right = 1.0
    inventory_panel.visible = false
    layer.add_child(inventory_panel)

    var inventory_box := VBoxContainer.new()
    inventory_panel.add_child(inventory_box)

    inventory_text = Label.new()
    inventory_text.text = "Inventaris kosong"
    inventory_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    inventory_box.add_child(inventory_text)

    var use_potion := Button.new()
    use_potion.text = "Gunakan Ramuan (+30 HP)"
    use_potion.pressed.connect(_use_potion)
    inventory_box.add_child(use_potion)

    joystick = Control.new()
    joystick.position = Vector2(38, -198)
    joystick.size = Vector2(170, 170)
    joystick.anchor_top = 1.0
    joystick.anchor_bottom = 1.0
    joystick.gui_input.connect(_on_joystick_input)
    layer.add_child(joystick)

    var base := Panel.new()
    base.position = Vector2(5, 5)
    base.size = Vector2(160, 160)
    var base_style := StyleBoxFlat.new()
    base_style.bg_color = Color(0.05, 0.08, 0.15, 0.48)
    base_style.corner_radius_top_left = 80
    base_style.corner_radius_top_right = 80
    base_style.corner_radius_bottom_left = 80
    base_style.corner_radius_bottom_right = 80
    base_style.border_width_left = 3
    base_style.border_width_top = 3
    base_style.border_width_right = 3
    base_style.border_width_bottom = 3
    base_style.border_color = Color(0.75, 0.84, 1.0, 0.65)
    base.add_theme_stylebox_override("panel", base_style)
    base.mouse_filter = Control.MOUSE_FILTER_IGNORE
    joystick.add_child(base)

    knob = Panel.new()
    knob.position = Vector2(60, 60)
    knob.size = Vector2(50, 50)
    var knob_style := StyleBoxFlat.new()
    knob_style.bg_color = Color(0.86, 0.91, 1.0, 0.92)
    knob_style.corner_radius_top_left = 25
    knob_style.corner_radius_top_right = 25
    knob_style.corner_radius_bottom_left = 25
    knob_style.corner_radius_bottom_right = 25
    knob_style.border_width_left = 2
    knob_style.border_width_top = 2
    knob_style.border_width_right = 2
    knob_style.border_width_bottom = 2
    knob_style.border_color = Color(1, 1, 1, 0.85)
    knob.add_theme_stylebox_override("panel", knob_style)
    knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    joystick.add_child(knob)

    attack_button = Button.new()
    attack_button.text = "SERANG"
    attack_button.position = Vector2(-174, -158)
    attack_button.size = Vector2(138, 118)
    attack_button.anchor_left = 1.0
    attack_button.anchor_right = 1.0
    attack_button.anchor_top = 1.0
    attack_button.anchor_bottom = 1.0
    attack_button.add_theme_font_size_override("font_size", 21)
    var attack_style := StyleBoxFlat.new()
    attack_style.bg_color = Color(0.68, 0.12, 0.18, 0.9)
    attack_style.corner_radius_top_left = 28
    attack_style.corner_radius_top_right = 28
    attack_style.corner_radius_bottom_left = 28
    attack_style.corner_radius_bottom_right = 28
    attack_button.add_theme_stylebox_override("normal", attack_style)
    attack_button.pressed.connect(hero.attack)
    layer.add_child(attack_button)

    clone_button = Button.new()
    clone_button.text = "KAGE\nBUNSHIN"
    clone_button.position = Vector2(-330, -145)
    clone_button.size = Vector2(126, 100)
    clone_button.anchor_left = 1.0
    clone_button.anchor_right = 1.0
    clone_button.anchor_top = 1.0
    clone_button.anchor_bottom = 1.0
    clone_button.add_theme_font_size_override("font_size", 17)
    var clone_style := StyleBoxFlat.new()
    clone_style.bg_color = Color(0.18, 0.25, 0.55, 0.92)
    clone_style.corner_radius_top_left = 24
    clone_style.corner_radius_top_right = 24
    clone_style.corner_radius_bottom_left = 24
    clone_style.corner_radius_bottom_right = 24
    clone_button.add_theme_stylebox_override("normal", clone_style)
    clone_button.pressed.connect(_activate_shadow_clones)
    layer.add_child(clone_button)

func _make_health_bar(layer: CanvasLayer, bar_position: Vector2, max_health: float, fill_color: Color) -> ProgressBar:
    var bar := ProgressBar.new()
    bar.position = bar_position
    bar.size = Vector2(300, 15)
    bar.min_value = 0.0
    bar.max_value = max_health
    bar.value = max_health
    bar.show_percentage = false
    var background := StyleBoxFlat.new()
    background.bg_color = Color(0.035, 0.045, 0.075, 0.88)
    background.corner_radius_top_left = 7
    background.corner_radius_top_right = 7
    background.corner_radius_bottom_left = 7
    background.corner_radius_bottom_right = 7
    bar.add_theme_stylebox_override("background", background)
    var fill := StyleBoxFlat.new()
    fill.bg_color = fill_color
    fill.corner_radius_top_left = 7
    fill.corner_radius_top_right = 7
    fill.corner_radius_bottom_left = 7
    fill.corner_radius_bottom_right = 7
    bar.add_theme_stylebox_override("fill", fill)
    layer.add_child(bar)
    return bar

func _activate_shadow_clones() -> void:
    if not is_instance_valid(hero):
        return
    _clear_shadow_clones()
    clone_time_left = 8.0
    var offsets := [Vector3(-1.8, 0.0, 0.8), Vector3(1.8, 0.0, 0.8), Vector3(0.0, 0.0, -2.0)]
    for i in range(3):
        var shadow := Node3D.new()
        shadow.name = "KageBunshin%d" % (i + 1)
        add_child(shadow)
        for child in hero.get_children():
            if child is MeshInstance3D:
                var ghost_mesh := child.duplicate() as MeshInstance3D
                ghost_mesh.material_override = _make_shadow_material()
                shadow.add_child(ghost_mesh)
            elif child is Node3D and child != camera_pivot:
                var ghost_part := child.duplicate() as Node3D
                for ghost_mesh in ghost_part.find_children("*", "MeshInstance3D", true, false):
                    ghost_mesh.material_override = _make_shadow_material()
                shadow.add_child(ghost_part)
        shadow.position = hero.global_position + offsets[i]
        shadow.rotation = hero.rotation
        shadow_clones.append(shadow)
        clone_attack_timers.append(0.0)
    game_state.last_notice = "KAGE BUNSHIN! Tiga bayangan muncul selama 8 detik!"

func _make_shadow_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.24, 0.72, 1.0, 0.48)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.emission_enabled = true
    material.emission = Color(0.08, 0.42, 1.0)
    material.emission_energy_multiplier = 1.6
    return material

func _clear_shadow_clones() -> void:
    for shadow in shadow_clones:
        if is_instance_valid(shadow):
            shadow.queue_free()
    shadow_clones.clear()
    clone_attack_timers.clear()

func _toggle_inventory() -> void:
    inventory_panel.visible = not inventory_panel.visible
    _refresh_inventory()

func _use_potion() -> void:
    if hero.hp >= 100:
        notice_text.text = "HP masih penuh."
    elif game_state.use_item("Ramuan Kecil"):
        hero.hp = mini(100, hero.hp + 30)
        notice_text.text = "Ramuan digunakan: HP +30"
    else:
        notice_text.text = "Ramuan tidak tersedia."
    _refresh_inventory()

func _refresh_inventory() -> void:
    var items: Dictionary = game_state.inventory
    var lines := ["INVENTARIS"]
    if items.is_empty():
        lines.append("Belum ada barang.")
    else:
        for item in items:
            lines.append("%s x%d" % [item, items[item]])
    inventory_text.text = "\n".join(lines)

func _on_joystick_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _set_joystick(event.position)
        else:
            move_vector = Vector2.ZERO
            knob.position = joystick.size * 0.5 - knob.size * 0.5
    elif event is InputEventScreenDrag:
        _set_joystick(event.position)

func _set_joystick(pos: Vector2) -> void:
    var center := joystick.size * 0.5
    var delta := pos - center
    if delta.length() > 52.0:
        delta = delta.normalized() * 52.0
    move_vector = Vector2(delta.x / 52.0, delta.y / 52.0)
    knob.position = center - knob.size * 0.5 + delta

func _is_control_touch(pos: Vector2) -> bool:
    if joystick and joystick.get_global_rect().has_point(pos):
        return true
    if attack_button and attack_button.get_global_rect().has_point(pos):
        return true
    if clone_button and clone_button.get_global_rect().has_point(pos):
        return true
    if inventory_panel and inventory_panel.visible and inventory_panel.get_global_rect().has_point(pos):
        return true
    return false

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            if not _is_control_touch(event.position):
                camera_touch_index = event.index
                camera_last_touch = event.position
        elif event.index == camera_touch_index:
            camera_touch_index = -1
    elif event is InputEventScreenDrag and event.index == camera_touch_index:
        _rotate_camera(event.position - camera_last_touch)
        camera_last_touch = event.position
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        camera_mouse_drag = event.pressed and not _is_control_touch(event.position)
    elif event is InputEventMouseMotion and camera_mouse_drag:
        _rotate_camera(event.relative)

func _rotate_camera(delta: Vector2) -> void:
    if not is_instance_valid(camera_pivot):
        return
    camera_pivot.rotation.y -= delta.x * 0.006
    camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - delta.y * 0.004, deg_to_rad(-0.15), deg_to_rad(0.55))

func _shadow_clone_attack(delta: float) -> void:
    for i in range(shadow_clones.size()):
        if i >= clone_attack_timers.size():
            continue
        clone_attack_timers[i] = maxf(0.0, clone_attack_timers[i] - delta)
        if clone_attack_timers[i] > 0.0:
            continue
        var target: Node3D = null
        var target_name := ""
        if is_instance_valid(boss) and boss.hp > 0 and shadow_clones[i].global_position.distance_to(boss.global_position) < 4.8:
            target = boss
            target_name = "DreamBoss"
        elif is_instance_valid(slime) and slime.hp > 0 and shadow_clones[i].global_position.distance_to(slime.global_position) < 4.0:
            target = slime
            target_name = "Slime"
        if target != null:
            var damage := maxi(1, int(round(12.0 * game_state.player_strength)))
            target.take_damage(damage)
            clone_attack_timers[i] = 0.8
            game_state.last_notice = "Bayangan Kage Bunshin menyerang %s (-%d HP)!" % [target_name, damage]
            if target.hp <= 0:
                if target_name == "Slime":
                    game_state.complete_slime_quest()
                    hero.slime_reward_claimed = true
                else:
                    game_state.defeat_boss()

func _process(delta: float) -> void:
    if clone_time_left > 0.0:
        clone_time_left -= delta
        if is_instance_valid(hero):
            var offsets := [Vector3(-1.8, 0.0, 0.8), Vector3(1.8, 0.0, 0.8), Vector3(0.0, 0.0, -2.0)]
            for i in range(shadow_clones.size()):
                var shadow := shadow_clones[i]
                if is_instance_valid(shadow):
                    var target_pos: Vector3 = hero.global_position + offsets[i].rotated(Vector3.UP, hero.rotation.y)
                    shadow.global_position = shadow.global_position.lerp(target_pos, minf(1.0, delta * 7.0))
                    shadow.rotation.y = hero.rotation.y
                    for limb_name in ["LeftArm", "RightArm", "LeftLeg", "RightLeg"]:
                        var hero_limb := hero.get_node_or_null(limb_name)
                        var shadow_limb := shadow.get_node_or_null(limb_name)
                        if hero_limb and shadow_limb:
                            shadow_limb.rotation = hero_limb.rotation
                    var hero_body := hero.get_node_or_null("BodyVisual")
                    var shadow_body := shadow.get_node_or_null("BodyVisual")
                    if hero_body and shadow_body:
                        shadow_body.position.y = hero_body.position.y
            _shadow_clone_attack(delta)
        if clone_time_left <= 0.0:
            _clear_shadow_clones()
    if is_instance_valid(clone_button):
        clone_button.disabled = false
        clone_button.text = "KAGE\nBUNSHIN"
    if is_instance_valid(hero):
        hero.mobile_move = move_vector
        if hero.hp <= 0:
            hero.hp = 100
            hero.global_position = START_POSITION
            hero.velocity = Vector3.ZERO
            game_state.last_notice = "Kamu pingsan! Kembali ke titik awal dengan HP penuh."
            game_state.save_player_state(hero.hp, hero.global_position)
        autosave_timer += delta
        if autosave_timer >= SAVE_INTERVAL:
            autosave_timer = 0.0
            game_state.save_player_state(hero.hp, hero.global_position)
        hp_text.text = "HP: %d / 100" % hero.hp
        stats_text.text = "Level: %d  |  Kekuatan: %.2f" % [game_state.player_level, game_state.player_strength]
    var enemy_lines := []
    if is_instance_valid(slime):
        enemy_lines.append("Slime HP: %d" % slime.hp if slime.hp > 0 else "Slime dikalahkan!")
    if is_instance_valid(boss):
        enemy_lines.append("BOS MIMPI HP: %d / 350" % boss.hp if boss.hp > 0 else "Bos Mimpi dikalahkan!")
    enemy_text.text = "  •  ".join(enemy_lines)
    if is_instance_valid(slime_health_bar) and is_instance_valid(slime):
        slime_health_bar.value = maxf(0.0, float(slime.hp))
        slime_health_bar.visible = slime.hp > 0
    if is_instance_valid(boss_health_bar) and is_instance_valid(boss):
        boss_health_bar.value = maxf(0.0, float(boss.hp))
        boss_health_bar.visible = boss.hp > 0
    quest_text.text = game_state.get_quest_text()
    if inventory_panel.visible:
        _refresh_inventory()
    if game_state.last_notice != "":
        notice_text.text = game_state.last_notice
        game_state.last_notice = ""

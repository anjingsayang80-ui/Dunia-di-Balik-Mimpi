extends Node3D

var hero
var slime
var boss
var game_state
var move_vector := Vector2.ZERO
var joystick: Control
var knob: ColorRect
var hp_text: Label
var stats_text: Label
var enemy_text: Label
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

    var camera := Camera3D.new()
    camera.position = Vector3(0, 5.5, 9)
    camera.rotation_degrees = Vector3(-23, 0, 0)
    hero.add_child(camera)
    camera.current = true

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

    quest_text = Label.new()
    quest_text.position = Vector2(24, 146)
    quest_text.size = Vector2(420, 55)
    quest_text.add_theme_font_size_override("font_size", 16)
    layer.add_child(quest_text)

    notice_text = Label.new()
    notice_text.position = Vector2(24, 208)
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
    joystick.position = Vector2(35, -185)
    joystick.size = Vector2(155, 155)
    joystick.anchor_top = 1.0
    joystick.anchor_bottom = 1.0
    joystick.gui_input.connect(_on_joystick_input)
    layer.add_child(joystick)

    var base := ColorRect.new()
    base.size = Vector2(150, 150)
    base.color = Color(0.06, 0.08, 0.13, 0.42)
    base.mouse_filter = Control.MOUSE_FILTER_IGNORE
    joystick.add_child(base)

    knob = ColorRect.new()
    knob.position = Vector2(45, 45)
    knob.size = Vector2(60, 60)
    knob.color = Color(0.82, 0.87, 0.98, 0.8)
    knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    joystick.add_child(knob)

    var attack := Button.new()
    attack.text = "SERANG"
    attack.position = Vector2(-175, -145)
    attack.size = Vector2(140, 100)
    attack.anchor_left = 1.0
    attack.anchor_right = 1.0
    attack.anchor_top = 1.0
    attack.anchor_bottom = 1.0
    attack.add_theme_font_size_override("font_size", 21)
    attack.pressed.connect(hero.attack)
    layer.add_child(attack)

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
            knob.position = Vector2(45, 45)
    elif event is InputEventScreenDrag:
        _set_joystick(event.position)

func _set_joystick(pos: Vector2) -> void:
    var center := joystick.size * 0.5
    var delta := pos - center
    if delta.length() > 55.0:
        delta = delta.normalized() * 55.0
    move_vector = Vector2(delta.x / 55.0, delta.y / 55.0)
    knob.position = Vector2(45, 45) + delta

func _process(delta: float) -> void:
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
    quest_text.text = game_state.get_quest_text()
    if inventory_panel.visible:
        _refresh_inventory()
    if game_state.last_notice != "":
        notice_text.text = game_state.last_notice
        game_state.last_notice = ""

extends Node3D

var hero: CharacterBody3D
var slime: CharacterBody3D
var move_vector := Vector2.ZERO
var joystick: Control
var knob: ColorRect
var hp_text: Label
var enemy_text: Label

func _ready() -> void:
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
    hero.position = Vector3(0, 0.1, 4)
    add_child(hero)

    slime = CharacterBody3D.new()
    slime.name = "Slime"
    slime.set_script(load("res://scripts/enemy.gd"))
    slime.position = Vector3(0, 0.1, -5)
    add_child(slime)

    var camera := Camera3D.new()
    camera.position = Vector3(0, 5.5, 9)
    camera.rotation_degrees = Vector3(-23, 0, 0)
    hero.add_child(camera)
    camera.current = true

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

    enemy_text = Label.new()
    enemy_text.position = Vector2(24, 84)
    enemy_text.add_theme_font_size_override("font_size", 18)
    layer.add_child(enemy_text)

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
    joystick.add_child(base)

    knob = ColorRect.new()
    knob.position = Vector2(45, 45)
    knob.size = Vector2(60, 60)
    knob.color = Color(0.82, 0.87, 0.98, 0.8)
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

func _process(_delta: float) -> void:
    if is_instance_valid(hero):
        hero.mobile_move = move_vector
        hp_text.text = "HP: %d" % hero.hp
    if is_instance_valid(slime):
        enemy_text.text = "Slime HP: %d" % slime.hp if slime.hp > 0 else "Slime dikalahkan!"

extends CharacterBody3D

var hp := 70
var speed := 1.8
var hit_timer := 0.0
var hero: CharacterBody3D
var body_visual: MeshInstance3D
var base_material: StandardMaterial3D
var hit_material: StandardMaterial3D
var flash_timer := 0.0

func _ready() -> void:
    hero = get_parent().get_node_or_null("Hero")
    body_visual = MeshInstance3D.new()
    var body := body_visual
    var blob := SphereMesh.new()
    blob.radius = 0.78
    blob.height = 1.35
    body.mesh = blob
    var green := StandardMaterial3D.new()
    green.albedo_color = Color(0.22, 0.82, 0.42)
    green.roughness = 0.28
    body.material_override = green
    base_material = green
    hit_material = StandardMaterial3D.new()
    hit_material.albedo_color = Color(1.0, 0.45, 0.38)
    hit_material.emission_enabled = true
    hit_material.emission = Color(0.8, 0.08, 0.04)
    hit_material.emission_energy_multiplier = 0.9
    body.position.y = 0.7
    add_child(body)

    var eyes := StandardMaterial3D.new()
    eyes.albedo_color = Color(0.04, 0.05, 0.08)
    for x in [-0.23, 0.23]:
        var eye := MeshInstance3D.new()
        var eye_mesh := SphereMesh.new()
        eye_mesh.radius = 0.085
        eye.mesh = eye_mesh
        eye.material_override = eyes
        eye.position = Vector3(x, 0.88, -0.64)
        add_child(eye)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.7
    collision.shape = shape
    collision.position.y = 0.7
    add_child(collision)

func _process(delta: float) -> void:
    flash_timer = maxf(0.0, flash_timer - delta)
    if is_instance_valid(body_visual):
        body_visual.material_override = hit_material if flash_timer > 0.0 else base_material
        body_visual.scale = Vector3(1.12, 0.86, 1.12) if flash_timer > 0.0 else Vector3.ONE

func _physics_process(delta: float) -> void:
    if hp <= 0 or not is_instance_valid(hero):
        visible = false
        return
    hit_timer = maxf(0.0, hit_timer - delta)
    var offset := hero.global_position - global_position
    offset.y = 0
    if offset.length() > 1.55 and offset.length() < 13.0:
        var dir := offset.normalized()
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
        rotation.y = atan2(-dir.x, -dir.z)
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed)
        velocity.z = move_toward(velocity.z, 0.0, speed)
    velocity.y -= 20.0 * delta
    move_and_slide()
    if offset.length() <= 1.55 and hit_timer <= 0.0:
        hero.hp = max(0, hero.hp - 7)
        hit_timer = 1.1

func take_damage(amount: int) -> void:
    if hp <= 0:
        return
    hp = max(0, hp - amount)
    flash_timer = 0.16

extends CharacterBody3D

var hp := 350
var speed := 1.25
var hit_timer := 0.0
var hero: CharacterBody3D

func _ready() -> void:
    hero = get_parent().get_node_or_null("Hero")
    var body := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 1.25
    mesh.height = 2.35
    body.mesh = mesh
    var armor := StandardMaterial3D.new()
    armor.albedo_color = Color(0.30, 0.12, 0.48)
    armor.metallic = 0.35
    armor.roughness = 0.3
    armor.emission_enabled = true
    armor.emission = Color(0.18, 0.025, 0.32)
    armor.emission_energy_multiplier = 0.65
    body.material_override = armor
    body.position.y = 1.2
    add_child(body)

    var horn_mat := StandardMaterial3D.new()
    horn_mat.albedo_color = Color(0.88, 0.28, 0.22)
    for x in [-0.78, 0.78]:
        var horn := MeshInstance3D.new()
        var horn_mesh := ConeMesh.new()
        horn_mesh.bottom_radius = 0.24
        horn_mesh.height = 0.9
        horn.mesh = horn_mesh
        horn.material_override = horn_mat
        horn.position = Vector3(x, 2.25, 0.0)
        horn.rotation_degrees.z = -22.0 if x < 0.0 else 22.0
        add_child(horn)

    var eye_mat := StandardMaterial3D.new()
    eye_mat.albedo_color = Color(1.0, 0.22, 0.08)
    eye_mat.emission_enabled = true
    eye_mat.emission = Color(1.0, 0.08, 0.015)
    eye_mat.emission_energy_multiplier = 1.8
    for x in [-0.38, 0.38]:
        var eye := MeshInstance3D.new()
        var eye_mesh := SphereMesh.new()
        eye_mesh.radius = 0.14
        eye.mesh = eye_mesh
        eye.material_override = eye_mat
        eye.position = Vector3(x, 1.45, -1.05)
        eye.scale = Vector3(1.0, 0.75, 0.45)
        add_child(eye)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 1.15
    collision.shape = shape
    collision.position.y = 1.15
    add_child(collision)

func _physics_process(delta: float) -> void:
    if hp <= 0 or not is_instance_valid(hero):
        visible = false
        return
    hit_timer = maxf(0.0, hit_timer - delta)
    var offset := hero.global_position - global_position
    offset.y = 0.0
    if offset.length() > 2.0 and offset.length() < 16.0:
        var direction := offset.normalized()
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        rotation.y = atan2(-direction.x, -direction.z)
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed)
        velocity.z = move_toward(velocity.z, 0.0, speed)
    velocity.y -= 20.0 * delta
    move_and_slide()
    if offset.length() <= 2.0 and hit_timer <= 0.0:
        hero.hp = max(0, hero.hp - 16)
        hit_timer = 1.25

func take_damage(amount: int) -> void:
    hp = max(0, hp - amount)

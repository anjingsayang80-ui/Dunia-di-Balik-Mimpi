extends CharacterBody3D

var hp := 70
var speed := 1.8
var hit_timer := 0.0
var hero: CharacterBody3D

func _ready() -> void:
    hero = get_parent().get_node_or_null("Hero")
    var body := MeshInstance3D.new()
    var blob := SphereMesh.new()
    blob.radius = 0.78
    blob.height = 1.35
    body.mesh = blob
    var green := StandardMaterial3D.new()
    green.albedo_color = Color(0.22, 0.82, 0.42)
    green.roughness = 0.28
    body.material_override = green
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
    hp = max(0, hp - amount)

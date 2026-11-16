extends CharacterBody3D

var hp := 100
var speed := 5.8
var mobile_move := Vector2.ZERO
var cooldown := 0.0
var sword: MeshInstance3D
var slime_reward_claimed := false

func _ready() -> void:
    var body := MeshInstance3D.new()
    var capsule_mesh := CapsuleMesh.new()
    capsule_mesh.radius = 0.42
    capsule_mesh.height = 1.75
    body.mesh = capsule_mesh
    var outfit := StandardMaterial3D.new()
    outfit.albedo_color = Color(0.16, 0.29, 0.72)
    body.material_override = outfit
    body.position.y = 0.9
    add_child(body)

    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.32
    head_mesh.height = 0.64
    head.mesh = head_mesh
    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color(0.96, 0.77, 0.65)
    head.material_override = skin
    head.position.y = 1.85
    add_child(head)

    var hair := MeshInstance3D.new()
    var hair_mesh := SphereMesh.new()
    hair_mesh.radius = 0.35
    hair_mesh.height = 0.42
    hair.mesh = hair_mesh
    var hair_mat := StandardMaterial3D.new()
    hair_mat.albedo_color = Color(0.10, 0.08, 0.15)
    hair.material_override = hair_mat
    hair.position = Vector3(0, 2.03, -0.04)
    add_child(hair)

    sword = MeshInstance3D.new()
    var blade := BoxMesh.new()
    blade.size = Vector3(0.12, 0.95, 0.16)
    sword.mesh = blade
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color(0.75, 0.88, 1.0)
    metal.metallic = 0.75
    sword.material_override = metal
    sword.position = Vector3(0.52, 1.0, -0.18)
    add_child(sword)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.4
    shape.height = 1.75
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

func _physics_process(delta: float) -> void:
    cooldown = maxf(0.0, cooldown - delta)
    var move := Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    if mobile_move.length() > 0.12:
        move = mobile_move
    var direction := Vector3(move.x, 0, move.y).normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    if direction.length() > 0.1:
        rotation.y = atan2(-direction.x, -direction.z)
    velocity.y -= 20.0 * delta
    move_and_slide()

func attack() -> void:
    if cooldown > 0.0:
        return
    cooldown = 0.55
    var target = get_parent().get_node_or_null("Slime")
    if target and target.hp > 0 and global_position.distance_to(target.global_position) < 3.3:
        var was_alive: bool = target.hp > 0
        target.take_damage(35)
        if was_alive and target.hp <= 0 and not slime_reward_claimed:
            slime_reward_claimed = true
            var state = get_parent().get_node_or_null("GameState")
            if state:
                state.complete_slime_quest()
    sword.rotation.z = -0.9
    await get_tree().create_timer(0.18).timeout
    if is_instance_valid(sword):
        sword.rotation.z = 0.0

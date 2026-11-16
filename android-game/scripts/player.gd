extends CharacterBody3D

var hp := 100
var speed := 5.8
var mobile_move := Vector2.ZERO
var cooldown := 0.0
var sword: MeshInstance3D
var slime_reward_claimed := false
var attack_tween: Tween

func _ready() -> void:
    var outfit := StandardMaterial3D.new()
    outfit.albedo_color = Color(0.12, 0.22, 0.62)
    outfit.roughness = 0.82

    var body := MeshInstance3D.new()
    var capsule_mesh := CapsuleMesh.new()
    capsule_mesh.radius = 0.42
    capsule_mesh.height = 1.75
    body.mesh = capsule_mesh
    body.material_override = outfit
    body.position.y = 0.9
    add_child(body)

    var collar := MeshInstance3D.new()
    var collar_mesh := TorusMesh.new()
    collar_mesh.inner_radius = 0.24
    collar_mesh.outer_radius = 0.34
    collar.mesh = collar_mesh
    var gold := StandardMaterial3D.new()
    gold.albedo_color = Color(1.0, 0.72, 0.22)
    collar.material_override = gold
    collar.position.y = 1.55
    add_child(collar)

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

    var hair_mat := StandardMaterial3D.new()
    hair_mat.albedo_color = Color(0.10, 0.055, 0.16)
    var hair := MeshInstance3D.new()
    var hair_mesh := SphereMesh.new()
    hair_mesh.radius = 0.35
    hair_mesh.height = 0.42
    hair.mesh = hair_mesh
    hair.material_override = hair_mat
    hair.position = Vector3(0, 2.03, -0.04)
    add_child(hair)

    for i in range(5):
        var bang := MeshInstance3D.new()
        var bang_mesh := PrismMesh.new()
        bang.mesh = bang_mesh
        bang.scale = Vector3(0.20, 0.32, 0.16)
        bang.material_override = hair_mat
        bang.position = Vector3(-0.22 + float(i) * 0.11, 1.91, -0.27)
        bang.rotation_degrees.z = -12.0 + float(i) * 6.0
        add_child(bang)

    var eye_white := StandardMaterial3D.new()
    eye_white.albedo_color = Color(1.0, 0.98, 0.92)
    var iris_mat := StandardMaterial3D.new()
    iris_mat.albedo_color = Color(0.10, 0.35, 0.72)
    for x in [-0.13, 0.13]:
        var eye := MeshInstance3D.new()
        var eye_mesh := SphereMesh.new()
        eye_mesh.radius = 0.065
        eye_mesh.height = 0.09
        eye.mesh = eye_mesh
        eye.material_override = eye_white
        eye.position = Vector3(x, 1.86, -0.285)
        eye.scale = Vector3(1.0, 1.0, 0.45)
        add_child(eye)

        var iris := MeshInstance3D.new()
        var iris_mesh := SphereMesh.new()
        iris_mesh.radius = 0.038
        iris.mesh = iris_mesh
        iris.material_override = iris_mat
        iris.position = Vector3(x, 1.86, -0.319)
        iris.scale = Vector3(1.0, 1.0, 0.5)
        add_child(iris)

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
    var direction := Vector3.ZERO
    var active_camera := get_viewport().get_camera_3d()
    if active_camera:
        var camera_right := active_camera.global_basis.x
        var camera_forward := -active_camera.global_basis.z
        camera_right.y = 0.0
        camera_forward.y = 0.0
        camera_right = camera_right.normalized()
        camera_forward = camera_forward.normalized()
        direction = (camera_right * move.x + camera_forward * -move.y).normalized()
    else:
        direction = Vector3(move.x, 0.0, move.y).normalized()
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
    var state = get_parent().get_node_or_null("GameState")
    var target = null
    var target_name := ""
    var boss = get_parent().get_node_or_null("DreamBoss")
    var slime_target = get_parent().get_node_or_null("Slime")
    if boss and boss.hp > 0 and global_position.distance_to(boss.global_position) < 4.0:
        target = boss
        target_name = "DreamBoss"
    elif slime_target and slime_target.hp > 0 and global_position.distance_to(slime_target.global_position) < 3.3:
        target = slime_target
        target_name = "Slime"
    if target != null:
        var damage := 35
        if state:
            damage = maxi(1, int(round(35.0 * state.player_strength)))
        target.take_damage(damage)
        if target.hp <= 0 and state:
            if target_name == "Slime" and not slime_reward_claimed:
                slime_reward_claimed = true
                state.complete_slime_quest()
            elif target_name == "DreamBoss":
                state.defeat_boss()

    if attack_tween and attack_tween.is_running():
        attack_tween.kill()
    sword.rotation.z = 0.0
    attack_tween = create_tween()
    attack_tween.tween_property(sword, "rotation:z", -1.25, 0.10)
    attack_tween.tween_property(sword, "rotation:z", 0.0, 0.16)

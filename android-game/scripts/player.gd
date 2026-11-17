extends CharacterBody3D

var hp := 100
var speed := 5.8
var mobile_move := Vector2.ZERO
var cooldown := 0.0
var dash_cooldown := 0.0
var dash_time_left := 0.0
var dash_direction := Vector3.ZERO
var sword: MeshInstance3D
var slash_effect: MeshInstance3D
var slash_tween: Tween
var slime_reward_claimed := false
var attack_tween: Tween
var walk_phase := 0.0
var body_visual: MeshInstance3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D

func _ready() -> void:
    var outfit := StandardMaterial3D.new()
    outfit.albedo_color = Color(0.12, 0.22, 0.62)
    outfit.roughness = 0.82

    body_visual = MeshInstance3D.new()
    body_visual.name = "BodyVisual"
    var body := body_visual
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

    # Jambul runcing khas tokoh anime agar siluet kepala lebih mudah dikenali.
    for i in range(5):
        var hair_spike := MeshInstance3D.new()
        var spike_mesh := CylinderMesh.new()
        spike_mesh.top_radius = 0.0
        spike_mesh.bottom_radius = 0.14
        spike_mesh.height = 0.52
        hair_spike.mesh = spike_mesh
        hair_spike.material_override = hair_mat
        hair_spike.position = Vector3(-0.24 + float(i) * 0.12, 2.23, 0.02)
        hair_spike.rotation_degrees.z = -24.0 + float(i) * 12.0
        hair_spike.rotation_degrees.x = -12.0
        add_child(hair_spike)

    # Syal merah dan mantel pendek memberi aksen warna pada kostum petualang.
    var scarf_mat := StandardMaterial3D.new()
    scarf_mat.albedo_color = Color(0.78, 0.10, 0.16)
    scarf_mat.roughness = 0.72
    var scarf := MeshInstance3D.new()
    var scarf_mesh := BoxMesh.new()
    scarf_mesh.size = Vector3(0.76, 0.20, 0.24)
    scarf.mesh = scarf_mesh
    scarf.material_override = scarf_mat
    scarf.position = Vector3(0.0, 1.57, 0.12)
    add_child(scarf)

    var cape := MeshInstance3D.new()
    var cape_mesh := BoxMesh.new()
    cape_mesh.size = Vector3(0.72, 0.86, 0.10)
    cape.mesh = cape_mesh
    cape.material_override = scarf_mat
    cape.position = Vector3(0.0, 1.13, 0.39)
    cape.rotation_degrees.x = -8.0
    add_child(cape)

    var armor_mat := StandardMaterial3D.new()
    armor_mat.albedo_color = Color(0.88, 0.62, 0.20)
    armor_mat.metallic = 0.55
    for x in [-0.48, 0.48]:
        var shoulder_guard := MeshInstance3D.new()
        var guard_mesh := SphereMesh.new()
        guard_mesh.radius = 0.22
        guard_mesh.height = 0.30
        shoulder_guard.mesh = guard_mesh
        shoulder_guard.material_override = armor_mat
        shoulder_guard.position = Vector3(x, 1.53, 0.0)
        shoulder_guard.scale = Vector3(1.0, 0.72, 1.0)
        add_child(shoulder_guard)

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

    # Lengan dan kaki sederhana dengan pivot agar gerakan berjalan terlihat hidup.
    var limb_material := outfit
    left_arm = _make_limb(Vector3(-0.48, 1.35, 0.0), limb_material, 0.14, 0.78)
    right_arm = _make_limb(Vector3(0.48, 1.35, 0.0), limb_material, 0.14, 0.78)
    left_leg = _make_limb(Vector3(-0.19, 0.52, 0.0), limb_material, 0.17, 0.78)
    right_leg = _make_limb(Vector3(0.19, 0.52, 0.0), limb_material, 0.17, 0.78)
    left_arm.name = "LeftArm"
    right_arm.name = "RightArm"
    left_leg.name = "LeftLeg"
    right_leg.name = "RightLeg"

    sword = MeshInstance3D.new()
    sword.name = "Sword"
    var blade := BoxMesh.new()
    blade.size = Vector3(0.12, 0.95, 0.16)
    sword.mesh = blade
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color(0.75, 0.88, 1.0)
    metal.metallic = 0.75
    sword.material_override = metal
    sword.position = Vector3(0.52, 1.0, -0.18)
    add_child(sword)

    # Kilatan sabetan berbentuk busur cahaya di depan pedang.
    slash_effect = MeshInstance3D.new()
    slash_effect.name = "SwordSlashEffect"
    var slash_mesh := TorusMesh.new()
    slash_mesh.inner_radius = 0.58
    slash_mesh.outer_radius = 0.72
    slash_effect.mesh = slash_mesh
    var slash_material := StandardMaterial3D.new()
    slash_material.albedo_color = Color(0.35, 0.82, 1.0, 0.92)
    slash_material.emission_enabled = true
    slash_material.emission = Color(0.18, 0.68, 1.0)
    slash_material.emission_energy_multiplier = 2.2
    slash_effect.material_override = slash_material
    slash_effect.position = Vector3(0.0, 1.18, -0.82)
    slash_effect.rotation_degrees.x = 90.0
    slash_effect.scale = Vector3(0.12, 0.12, 0.12)
    slash_effect.visible = false
    add_child(slash_effect)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.4
    shape.height = 1.75
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

func _make_limb(pivot_position: Vector3, material: Material, radius: float, height: float) -> Node3D:
    var pivot := Node3D.new()
    pivot.position = pivot_position
    var limb := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = radius
    capsule.height = height
    limb.mesh = capsule
    limb.material_override = material
    limb.position.y = -height * 0.36
    pivot.add_child(limb)
    add_child(pivot)
    return pivot

func _physics_process(delta: float) -> void:
    cooldown = maxf(0.0, cooldown - delta)
    dash_cooldown = maxf(0.0, dash_cooldown - delta)
    dash_time_left = maxf(0.0, dash_time_left - delta)
    var move := Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    if mobile_move.length() > 0.12:
        move = mobile_move
    var direction := Vector3.ZERO
    var active_camera := get_viewport().get_camera_3d()
    if active_camera:
        # Gunakan yaw kamera saja untuk bidang gerak horizontal. Basis kamera
        # penuh ikut membawa kemiringan kamera dan dapat membuat arah analog
        # terasa tidak konsisten pada beberapa rasio layar/perangkat.
        var flat_camera_basis := Basis(Vector3.UP, active_camera.global_rotation.y)
        var camera_right := flat_camera_basis.x
        var camera_forward := -flat_camera_basis.z
        move = move.limit_length(1.0)
        direction = (camera_right * move.x + camera_forward * -move.y).normalized()
    else:
        direction = Vector3(move.x, 0.0, move.y).normalized()
    if dash_time_left > 0.0:
        velocity.x = dash_direction.x * 16.0
        velocity.z = dash_direction.z * 16.0
    else:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    if direction.length() > 0.1:
        rotation.y = atan2(-direction.x, -direction.z)
    walk_phase += delta * (9.0 if direction.length() > 0.1 else 2.0)
    var stride := sin(walk_phase) * (0.62 if direction.length() > 0.1 else 0.035)
    left_leg.rotation.x = stride
    right_leg.rotation.x = -stride
    left_arm.rotation.x = -stride * 0.72
    right_arm.rotation.x = stride * 0.72
    body_visual.position.y = 0.9 + absf(stride) * 0.045
    velocity.y -= 20.0 * delta
    move_and_slide()

    # Arena memiliki lantai terbatas; tahan pemain agar tidak berjalan keluar
    # dari tepi platform dan jatuh tanpa bisa kembali.
    var bounded_position := global_position
    var hit_x_edge := absf(bounded_position.x) > 33.0
    var hit_z_edge := absf(bounded_position.z) > 33.0
    bounded_position.x = clampf(bounded_position.x, -33.0, 33.0)
    bounded_position.z = clampf(bounded_position.z, -33.0, 33.0)
    if hit_x_edge:
        velocity.x = 0.0
    if hit_z_edge:
        velocity.z = 0.0
    global_position = bounded_position

func dash() -> void:
    if dash_cooldown > 0.0 or dash_time_left > 0.0:
        return
    var active_camera := get_viewport().get_camera_3d()
    if mobile_move.length() > 0.12 and active_camera:
        var flat_camera_basis := Basis(Vector3.UP, active_camera.global_rotation.y)
        var camera_right := flat_camera_basis.x
        var camera_forward := -flat_camera_basis.z
        var dash_move := mobile_move.limit_length(1.0)
        dash_direction = (camera_right * dash_move.x + camera_forward * -dash_move.y).normalized()
    else:
        dash_direction = -global_basis.z
        dash_direction.y = 0.0
        dash_direction = dash_direction.normalized()
    dash_time_left = 0.22
    dash_cooldown = 2.0

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
    _play_slash_effect()

func _play_slash_effect() -> void:
    if slash_tween and slash_tween.is_running():
        slash_tween.kill()
    slash_effect.visible = true
    slash_effect.scale = Vector3(0.12, 0.12, 0.12)
    slash_tween = create_tween()
    slash_tween.tween_property(slash_effect, "scale", Vector3(1.45, 0.92, 0.12), 0.18)
    slash_tween.tween_callback(_finish_slash_effect)

func _finish_slash_effect() -> void:
    slash_effect.visible = false
    slash_effect.scale = Vector3(0.12, 0.12, 0.12)

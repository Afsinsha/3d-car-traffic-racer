extends CharacterBody3D

var car_body: MeshInstance3D
var speed_label: Label

@export var max_speed: float = 25.0
@export var acceleration: float = 12.0
@export var braking: float = 20.0
@export var steering_speed: float = 8.0
@export var camera_smooth_speed: float = 5.0

var current_speed: float = 0.0

@onready var camera = $Camera3D
@onready var car_body_node = $CarBody

func _ready():
	# Speedometer UI
	var old_speed_ui = get_tree().root.get_node_or_null("SpeedUI")
	if old_speed_ui:
		old_speed_ui.queue_free()
	speed_label = Label.new()
	speed_label.text = "SPEED: 0 KM/H"
	speed_label.position = Vector2(40, 80)
	speed_label.add_theme_font_size_override("font_size", 32)
	var speed_ui = CanvasLayer.new()
	speed_ui.name = "SpeedUI"
	speed_ui.add_child(speed_label)
	get_tree().root.add_child.call_deferred(speed_ui)
	
	car_body = car_body_node
	var sport_body = BoxMesh.new()
	sport_body.size = Vector3(1.85, 0.8, 4.0)
	car_body.mesh = sport_body
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = load_car_color()
	body_material.metallic = 0.25
	body_material.roughness = 0.3
	car_body.material_override = body_material

	var cabin = MeshInstance3D.new()
	var cabin_mesh = BoxMesh.new()
	cabin_mesh.size = Vector3(1.45, 0.42, 1.8)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 0.82, 0.2)
	var cabin_material = StandardMaterial3D.new()
	cabin_material.albedo_color = Color(0.05, 0.05, 0.08)
	cabin.material_override = cabin_material
	add_child(cabin)

	var hood = MeshInstance3D.new()
	var hood_mesh = BoxMesh.new()
	hood_mesh.size = Vector3(1.8, 0.25, 1.2)
	hood.mesh = hood_mesh
	hood.position = Vector3(0, 0.85, -1.25)
	var hood_material = StandardMaterial3D.new()
	hood_material.albedo_color = load_car_color()
	hood.material_override = hood_material
	add_child(hood)

	var spoiler = MeshInstance3D.new()
	var spoiler_mesh = BoxMesh.new()
	spoiler_mesh.size = Vector3(1.7, 0.10, 0.25)
	spoiler.mesh = spoiler_mesh
	spoiler.position = Vector3(0, 1.05, 1.65)
	var spoiler_material = StandardMaterial3D.new()
	spoiler_material.albedo_color = Color(0.02, 0.02, 0.02)
	spoiler.material_override = spoiler_material
	add_child(spoiler)

	var left_spoiler_support = MeshInstance3D.new()
	var support_mesh = BoxMesh.new()
	support_mesh.size = Vector3(0.12, 0.35, 0.12)
	left_spoiler_support.mesh = support_mesh
	left_spoiler_support.position = Vector3(-0.65, 0.87, 1.65)
	var support_material = StandardMaterial3D.new()
	support_material.albedo_color = Color(0.02, 0.02, 0.02)
	support_material.metallic = 0.4
	support_material.roughness = 0.4
	left_spoiler_support.material_override = support_material
	add_child(left_spoiler_support)
	var right_spoiler_support = left_spoiler_support.duplicate()
	right_spoiler_support.position.x = 0.65
	add_child(right_spoiler_support)

	var left_light = MeshInstance3D.new()
	var light_mesh = SphereMesh.new()
	light_mesh.radius = 0.18
	light_mesh.height = 0.36
	left_light.mesh = light_mesh
	left_light.position = Vector3(-0.65, 0.65, -2.02)
	var light_material = StandardMaterial3D.new()
	light_material.albedo_color = Color(1.0, 0.9, 0.5)
	light_material.emission_enabled = true
	light_material.emission = Color(1.0, 0.8, 0.3)
	light_material.emission_energy_multiplier = 2.0
	left_light.material_override = light_material
	add_child(left_light)
	var right_light = left_light.duplicate()
	right_light.position.x = 0.65
	add_child(right_light)

	# Actual headlight beams
	var left_beam = SpotLight3D.new()
	left_beam.name = "LeftHeadlightBeam"
	left_beam.position = Vector3(-0.65, 0.65, -2.02)
	left_beam.rotation_degrees.x = -5.0
	left_beam.spot_range = 35.0
	left_beam.spot_angle = 35.0
	left_beam.light_energy = 3.0
	left_beam.light_color = Color(1.0, 0.9, 0.7)
	left_beam.visible = false
	add_child(left_beam)
	
	var right_beam = left_beam.duplicate()
	right_beam.name = "RightHeadlightBeam"
	right_beam.position.x = 0.65
	add_child(right_beam)

	var left_brake = MeshInstance3D.new()
	var brake_mesh = BoxMesh.new()
	brake_mesh.size = Vector3(0.55, 0.18, 0.12)
	left_brake.mesh = brake_mesh
	left_brake.position = Vector3(-0.65, 0.65, 2.02)
	var brake_material = StandardMaterial3D.new()
	brake_material.albedo_color = Color(1.0, 0.0, 0.0)
	brake_material.emission_enabled = true
	brake_material.emission = Color(1.0, 0.0, 0.0)
	brake_material.emission_energy_multiplier = 1.5
	left_brake.material_override = brake_material
	add_child(left_brake)
	var right_brake = left_brake.duplicate()
	right_brake.position.x = 0.65
	add_child(right_brake)
	var rear_bumper = MeshInstance3D.new()
	var rear_bumper_mesh = BoxMesh.new()
	rear_bumper_mesh.size = Vector3(1.8, 0.35, 0.25)
	rear_bumper.mesh = rear_bumper_mesh
	rear_bumper.position = Vector3(0, 0.35, 1.95)
	var rear_bumper_material = StandardMaterial3D.new()
	rear_bumper_material.albedo_color = Color(0.03, 0.03, 0.03)
	rear_bumper_material.metallic = 0.25
	rear_bumper_material.roughness = 0.3
	rear_bumper.material_override = rear_bumper_material
	add_child(rear_bumper)

	var diffuser = MeshInstance3D.new()
	var diffuser_mesh = BoxMesh.new()
	diffuser_mesh.size = Vector3(1.5, 0.18, 0.3)
	diffuser.mesh = diffuser_mesh
	diffuser.position = Vector3(0, 0.12, 2.05)
	var diffuser_material = StandardMaterial3D.new()
	diffuser_material.albedo_color = Color(0.015, 0.015, 0.015)
	diffuser_material.metallic = 0.3
	diffuser_material.roughness = 0.45
	diffuser.material_override = diffuser_material
	add_child(diffuser)
	
	var exhaust_material = StandardMaterial3D.new()
	exhaust_material.albedo_color = Color(0.12, 0.12, 0.12)
	exhaust_material.metallic = 0.8
	exhaust_material.roughness = 0.25
	for exhaust_x in [-0.55, 0.55]:
		var exhaust = MeshInstance3D.new()
		var exhaust_mesh = CylinderMesh.new()
		exhaust_mesh.top_radius = 0.14
		exhaust_mesh.bottom_radius = 0.14
		exhaust_mesh.height = 0.28
		exhaust.mesh = exhaust_mesh
		exhaust.rotation_degrees.x = 90.0
		exhaust.position = Vector3(exhaust_x, 0.22, 2.18)
		exhaust.material_override = exhaust_material
		add_child(exhaust)

	var left_mirror = MeshInstance3D.new()
	var mirror_mesh = BoxMesh.new()
	mirror_mesh.size = Vector3(0.25, 0.2, 0.45)
	left_mirror.mesh = mirror_mesh
	left_mirror.position = Vector3(-1.05, 0.9, -0.15)
	var mirror_material = StandardMaterial3D.new()
	mirror_material.albedo_color = Color(0.02, 0.02, 0.02)
	left_mirror.material_override = mirror_material
	add_child(left_mirror)
	var right_mirror = left_mirror.duplicate()
	right_mirror.position.x = 1.05
	add_child(right_mirror)
	
	var windshield = MeshInstance3D.new()
	var windshield_mesh = BoxMesh.new()
	windshield_mesh.size = Vector3(1.35, 0.35, 0.08)
	windshield.mesh = windshield_mesh
	windshield.position = Vector3(0, 1.0, -0.65)
	var windshield_material = StandardMaterial3D.new()
	windshield_material.albedo_color = Color(0.05, 0.15, 0.2)
	windshield_material.metallic = 0.2
	windshield_material.roughness = 0.15
	windshield.material_override = windshield_material
	add_child(windshield)
	var rear_windshield = MeshInstance3D.new()
	var rear_mesh = BoxMesh.new()
	rear_mesh.size = Vector3(1.15, 0.28, 0.08)
	rear_windshield.mesh = rear_mesh
	rear_windshield.position = Vector3(0, 1.02, 0.95)
	var rear_material = StandardMaterial3D.new()
	rear_material.albedo_color = Color(0.05, 0.15, 0.2)
	rear_material.metallic = 0.2
	rear_material.roughness = 0.15
	rear_windshield.material_override = rear_material
	add_child(rear_windshield)
	# Player wheels
	for wheel_position in [
		Vector3(-0.82, 0.0, -1.25),
		Vector3(0.82, 0.0, -1.25),
		Vector3(-0.82, 0.0, 1.25),
		Vector3(0.82, 0.0, 1.25)]:
		var wheel = MeshInstance3D.new()
		wheel.name = "Wheel"
		var wheel_mesh = CylinderMesh.new()
		wheel_mesh.top_radius = 0.42
		wheel_mesh.bottom_radius = 0.42
		wheel_mesh.height = 0.32
		wheel.mesh = wheel_mesh
		wheel.rotation_degrees.z = 90.0
		wheel.position = wheel_position
		var wheel_material = StandardMaterial3D.new()
		wheel_material.albedo_color = Color(0.02, 0.02, 0.02)
		wheel_material.metallic = 0.4
		wheel_material.roughness = 0.5
		wheel.material_override = wheel_material
		add_child(wheel)

func _physics_process(delta):
	var accelerate = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var brake = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	if accelerate:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	elif brake:
		current_speed = move_toward(current_speed, 5.5, braking * delta)
	else:
		current_speed = move_toward(current_speed, 15.0, acceleration * 0.5 * delta)
	velocity.z = -current_speed
	var steering := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		steering = -1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		steering = 1.0
	velocity.x = steering * steering_speed
	position.x = clamp(position.x, -5.0, 5.0)
	move_and_slide()
	if camera:
		camera.position.x = lerp(camera.position.x, 0.0, camera_smooth_speed * delta)
	var target_camera_z = 10.0 + (current_speed / max_speed) * 3.0
	var speed_ratio = current_speed / max_speed
	camera.fov = lerp(70.0, 78.0, speed_ratio)
	if camera:
		camera.position.z = lerp(
			camera.position.z,
			target_camera_z,
			camera_smooth_speed * delta)
# Update speedometer
	if speed_label:
		var speed_kmh = int(current_speed * 3.6)
		speed_label.text = "SPEED: " + str(speed_kmh) + " KM/H"

func load_car_color() -> Color:
	if FileAccess.file_exists("user://car_color.save"):
		var file = FileAccess.open("user://car_color.save", FileAccess.READ)
		var saved_color = file.get_var()
		file.close()
		if saved_color is Color:
			return saved_color
	return Color(0.8, 0.02, 0.02)

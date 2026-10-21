extends Node3D

@export var traffic_distance: float = 140.0
@export var spawn_interval: float = 2.0
@export var lane_width: float = 3.0

var spawn_timer: float = 0.0
var score: int = 0
var high_score: int = 0
const HIGH_SCORE_FILE = "user://high_score.save"
var score_label: Label
var difficulty_level: int = 1
var traffic_cars: Array[Area3D] = []
var traffic_speeds: Dictionary = {}

@onready var player = $"../PlayerCar"


func _ready():
	load_high_score()
	var old_ui = get_tree().root.get_node_or_null("ScoreUI")
	if old_ui:
		old_ui.queue_free()
	score_label = Label.new()
	score_label.text = "SCORE: 0"
	score_label.position = Vector2(45, 30)
	score_label.add_theme_font_size_override("font_size", 36)
	var ui = CanvasLayer.new()
	ui.name = "ScoreUI"
	ui.add_child(score_label)
	get_tree().root.add_child.call_deferred(ui)


func _process(delta):
	if score_label:
		score_label.text = "SCORE: " + str(score)
		difficulty_level = 1 + (score / 50)
		player.max_speed = 25.0 + (difficulty_level - 1) * 3.0
	spawn_timer += delta
	spawn_interval = max(0.8, 2.0 - (difficulty_level - 1) * 0.15)
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_traffic_car()
	move_traffic_cars(delta)
	remove_old_cars()


func spawn_traffic_car():
	var car = Area3D.new()
	car.name = "TrafficCar"
	# Car body
	var body = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	var car_type = randi() % 3
	if car_type == 0:
		mesh.size = Vector3(1.8, 0.7, 3.5)
	elif car_type == 1:
		mesh.size = Vector3(2.0, 0.85, 4.0)
	else:
		mesh.size = Vector3(2.2, 1.0, 4.5)
	body.mesh = mesh
	body.position.y = 0.5
	# Random car color
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(
		randf_range(0.2, 1.0),
		randf_range(0.2, 1.0),
		randf_range(0.2, 1.0)
	)
	body.material_override = material
	car.add_child(body)
	# Traffic car cabin
	var cabin = MeshInstance3D.new()
	var cabin_mesh = BoxMesh.new()
	cabin_mesh.size = Vector3(1.4, 0.45, 1.7)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 0.95, 0.2)
	var cabin_material = StandardMaterial3D.new()
	cabin_material.albedo_color = Color(0.04, 0.06, 0.08)
	cabin_material.metallic = 0.2
	cabin_material.roughness = 0.2
	cabin.material_override = cabin_material
	car.add_child(cabin)
	# Traffic windshield
	var windshield = MeshInstance3D.new()
	var windshield_mesh = BoxMesh.new()
	windshield_mesh.size = Vector3(1.25, 0.3, 0.08)
	windshield.mesh = windshield_mesh
	windshield.position = Vector3(0, 1.02, -0.68)
	var windshield_material = StandardMaterial3D.new()
	windshield_material.albedo_color = Color(0.03, 0.12, 0.18)
	windshield_material.metallic = 0.2
	windshield_material.roughness = 0.15
	windshield.material_override = windshield_material
	car.add_child(windshield)
	# Traffic headlights
	for side in [-1, 1]:
		var headlight = MeshInstance3D.new()
		var light_mesh = SphereMesh.new()
		light_mesh.radius = 0.12
		light_mesh.height = 0.24
		headlight.mesh = light_mesh
		headlight.position = Vector3(side * 0.6, 0.65, -2.0)
		var light_material = StandardMaterial3D.new()
		light_material.albedo_color = Color(1.0, 0.9, 0.5)
		light_material.emission_enabled = true
		light_material.emission = Color(1.0, 0.8, 0.3)
		light_material.emission_energy_multiplier = 1.5
		headlight.material_override = light_material
		car.add_child(headlight)
	# Traffic brake lights
	for side in [-1, 1]:
		var brake_light = MeshInstance3D.new()
		var brake_mesh = SphereMesh.new()
		brake_mesh.radius = 0.12
		brake_mesh.height = 0.24
		brake_light.mesh = brake_mesh
		brake_light.position = Vector3(side * 0.6, 0.65, 2.0)
		var brake_material = StandardMaterial3D.new()
		brake_material.albedo_color = Color(1.0, 0.0, 0.0)
		brake_material.emission_enabled = true
		brake_material.emission = Color(1.0, 0.0, 0.0)
		brake_material.emission_energy_multiplier = 1.5
		brake_light.material_override = brake_material
		car.add_child(brake_light)
		# Traffic side mirrors
	for side in [-1, 1]:
		var mirror = MeshInstance3D.new()
		var mirror_mesh = BoxMesh.new()
		mirror_mesh.size = Vector3(0.2, 0.18, 0.35)
		mirror.mesh = mirror_mesh
		mirror.position = Vector3(side * 0.85, 0.9, -0.15)
		var mirror_material = StandardMaterial3D.new()
		mirror_material.albedo_color = Color(0.02, 0.02, 0.02)
		mirror.material_override = mirror_material
		car.add_child(mirror)
	# Collision
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2.0, 0.8, 4.0)
	collision.shape = shape
	collision.position.y = 0.5
	car.add_child(collision)
	# Position traffic car
	var lanes = [-1, 0, 1]
	var lane = lanes[randi() % lanes.size()]
	var lane_offset = randf_range(-0.4, 0.4)
	car.position = Vector3(
	lane * lane_width + lane_offset,0,
	player.position.z - traffic_distance)
	# Detect player
	car.body_entered.connect(_on_traffic_collision.bind(car))
	add_child(car)
	traffic_cars.append(car)
	traffic_speeds[car] = randf_range(6.0, 11.0) + (difficulty_level - 1) * 0.5

func _on_traffic_collision(body, car):
	if body == player:
		print("💥 CRASH!")
		player.current_speed = 0.0
		player.velocity = Vector3.ZERO
		crash_effect()
		show_game_over()

func crash_effect():
	var camera = player.get_node_or_null("Camera3D")
	if camera:
		var original_position = camera.position
		for i in range(8):
			camera.position = original_position + Vector3(
				randf_range(-0.25, 0.25),
				randf_range(-0.15, 0.15),
				randf_range(-0.15, 0.15)
			)
			await get_tree().create_timer(0.03).timeout
		camera.position = original_position

func show_game_over():
	if get_node_or_null("../GameOverUI"):
		return
	if score > high_score:
		high_score = score
		save_high_score()
	var ui = CanvasLayer.new()
	ui.name = "GameOverUI"
	ui.layer = 10
	var panel = ColorRect.new()
	panel.color = Color(0, 0, 0, 0.75)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(panel)
	var title = Label.new()
	title.text = "GAME OVER\n\nSCORE: " + str(score) + "\nHIGH SCORE: " + str(high_score)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.position = Vector2(0, 180)
	title.size = Vector2(1152, 100)
	panel.add_child(title)
	var restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.position = Vector2(476, 320)
	restart_button.size = Vector2(200, 70)
	restart_button.add_theme_font_size_override("font_size", 28)
	restart_button.pressed.connect(_restart_game)
	panel.add_child(restart_button)
	get_tree().root.add_child(ui)
	get_tree().paused = true
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	ui.process_mode = Node.PROCESS_MODE_ALWAYS

func _restart_game():
	get_tree().paused = false
	var game_over_ui = get_tree().root.get_node_or_null("GameOverUI")
	if game_over_ui:
		game_over_ui.queue_free()
	get_tree().reload_current_scene()

func move_traffic_cars(delta):
	for car in traffic_cars:
		var current_speed = traffic_speeds.get(
			car,
			8.0 + (difficulty_level - 1) * 0.5)
		for other_car in traffic_cars:
			if car != other_car:
				var distance_z = other_car.position.z - car.position.z
				if distance_z < 8.0 and distance_z > 0.0:
					if abs(other_car.position.x - car.position.x) < 2.0:
						current_speed *= 0.5
		car.position.z += current_speed * delta
		var target_x = car.position.x
		target_x += sin(
			Time.get_ticks_msec() * 0.001 + car.position.z) * 0.15
		car.position.x = move_toward(
			car.position.x,target_x,0.5 * delta)

func remove_old_cars():
	for car in traffic_cars.duplicate():
		if car.position.z > player.position.z + 30.0:
			score += 10
			print("Overtake! Score: ", score)
			show_overtake_popup()
			traffic_cars.erase(car)
			traffic_speeds.erase(car)
			car.queue_free()

func show_overtake_popup():
	var popup = Label.new()
	popup.text = "+10"
	popup.add_theme_font_size_override("font_size", 30)
	popup.position = Vector2(50, 125)
	var ui = get_node_or_null("OvertakeUI")
	if ui == null:
		ui = CanvasLayer.new()
		ui.name = "OvertakeUI"
		ui.layer = 5
		add_child(ui)
	ui.add_child(popup)
	var tween = create_tween()
	tween.tween_property(
		popup,
		"position",
		popup.position + Vector2(0, -40),
		0.5)
	tween.parallel().tween_property(
		popup,
		"modulate:a",
		0.0,
		0.5)
	tween.tween_callback(popup.queue_free)

func load_high_score():
	if FileAccess.file_exists(HIGH_SCORE_FILE):
		var file = FileAccess.open(HIGH_SCORE_FILE, FileAccess.READ)
		high_score = file.get_var()
		file.close()

func save_high_score():
	var file = FileAccess.open(HIGH_SCORE_FILE, FileAccess.WRITE)
	file.store_var(high_score)
	file.close()

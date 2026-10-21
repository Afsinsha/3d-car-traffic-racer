extends Control
var racing_lines: Array[ColorRect] = []
var racing_line_speeds: Array[float] = []
var selected_car_color = Color(0.8, 0.02, 0.02)

var title_label: Label
var play_button: Button
var high_score_button: Button
var settings_button: Button
var quit_button: Button


func _ready():
	load_car_color()
	create_menu()
	create_racing_lines()

func create_racing_lines():
	for i in range(12):
		var line = ColorRect.new()
		line.size = Vector2(3, randf_range(40, 120))
		line.position = Vector2(
			randf_range(80, 1070),
			randf_range(0, 650))
		line.color = Color(0.8, 0.08, 0.08, randf_range(0.15, 0.45))
		add_child(line)
		racing_lines.append(line)
		racing_line_speeds.append(randf_range(120.0, 280.0))

func create_menu():
	# Cinematic background
	var background = ColorRect.new()
	background.color = Color(0.01, 0.015, 0.03)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	# Sky gradient
	var sky = TextureRect.new()
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0.01, 0.02, 0.06),
		Color(0.03, 0.07, 0.14),
		Color(0.01, 0.015, 0.03)
		])
	gradient.offsets = PackedFloat32Array([0.0,0.55,1.0])
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = 1152
	gradient_texture.height = 648
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	sky.texture = gradient_texture
	background.add_child(sky)
	# Horizon glow
	var horizon_glow = ColorRect.new()
	horizon_glow.color = Color(0.08, 0.18, 0.30, 0.18)
	horizon_glow.position = Vector2(0, 275)
	horizon_glow.size = Vector2(1152, 120)
	horizon_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(horizon_glow)
	# Distant light streaks
	for i in range(12):
		var light = ColorRect.new()
		var side = -1 if i % 2 == 0 else 1
		light.color = Color(0.2, 0.45, 0.8, 0.18)
		light.size = Vector2(2, randf_range(20, 55))
		if side < 0:
			light.position = Vector2(
				randf_range(80, 360),
				randf_range(300, 600)
			)
		else:
			light.position = Vector2(
				randf_range(790, 1070),
				randf_range(300, 600))
		light.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.add_child(light)
	# Subtle bottom shadow
	var bottom_shadow = ColorRect.new()
	bottom_shadow.color = Color(0.0, 0.0, 0.0, 0.35)
	bottom_shadow.position = Vector2(0, 560)
	bottom_shadow.size = Vector2(1152, 88)
	bottom_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(bottom_shadow)
	# Title - Racing Logo
	var title_top = Label.new()
	title_top.text = "ENDLESS"
	title_top.position = Vector2(0, 90)
	title_top.size = Vector2(1152, 80)
	title_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_top.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_top.add_theme_font_size_override("font_size", 64)
	title_top.add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
	title_top.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	title_top.add_theme_constant_override("outline_size", 8)
	background.add_child(title_top)
	var title_bottom = Label.new()
	title_bottom.text = "RACER"
	title_bottom.position = Vector2(0, 150)
	title_bottom.size = Vector2(1152, 80)
	title_bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_bottom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_bottom.add_theme_font_size_override("font_size", 70)
	title_bottom.add_theme_color_override("font_color", Color(0.95, 0.08, 0.08))
	title_bottom.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	title_bottom.add_theme_constant_override("outline_size", 8)
	background.add_child(title_bottom)
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "HIGHWAY RACING"
	subtitle.position = Vector2(0, 235)
	subtitle.size = Vector2(1152, 50)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	background.add_child(subtitle)
	# Play button
	play_button = create_button("PLAY", Vector2(426, 300))
	play_button.pressed.connect(_play_game)
	background.add_child(play_button)
	# High Score button
	high_score_button = create_button("HIGH SCORE", Vector2(426, 370))
	high_score_button.pressed.connect(_show_high_score)
	background.add_child(high_score_button)
	# Settings button
	settings_button = create_button("SETTINGS", Vector2(426, 510))
	settings_button.pressed.connect(_show_settings)
	background.add_child(settings_button)
	# Quit button
	quit_button = create_button("QUIT", Vector2(426, 580))
	quit_button.pressed.connect(_quit_game)
	background.add_child(quit_button)
	# Garage button
	var garage_button = create_button("GARAGE", Vector2(426, 440))
	garage_button.pressed.connect(_show_garage)
	background.add_child(garage_button)


func create_button(button_text: String, button_position: Vector2) -> Button:
	var button = Button.new()
	button.text = button_text
	button.position = button_position
	button.size = Vector2(300, 60)
	button.add_theme_font_size_override("font_size", 24)
	# Normal button style
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.04, 0.055, 0.95)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(0.18, 0.2, 0.25)
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6
	button.add_theme_stylebox_override("normal", normal)
	# Hover style
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.12, 0.025, 0.03, 1.0)
	hover.border_width_left = 2
	hover.border_width_right = 2
	hover.border_width_top = 2
	hover.border_width_bottom = 2
	hover.border_color = Color(0.9, 0.08, 0.08)
	hover.corner_radius_top_left = 6
	hover.corner_radius_top_right = 6
	hover.corner_radius_bottom_left = 6
	hover.corner_radius_bottom_right = 6
	button.add_theme_stylebox_override("hover", hover)
	# Pressed style
	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(0.25, 0.03, 0.035, 1.0)
	pressed.border_width_left = 2
	pressed.border_width_right = 2
	pressed.border_width_top = 2
	pressed.border_width_bottom = 2
	pressed.border_color = Color(1.0, 0.15, 0.15)
	pressed.corner_radius_top_left = 6
	pressed.corner_radius_top_right = 6
	pressed.corner_radius_bottom_left = 6
	pressed.corner_radius_bottom_right = 6
	button.add_theme_stylebox_override("pressed", pressed)
	# Text colors
	button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.92))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
	return button

func _play_game():
	get_tree().change_scene_to_file("res://Main.tscn")

func _show_high_score():
	var high_score = 0
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		high_score = file.get_var()
		file.close()
	var popup = AcceptDialog.new()
	popup.title = "HIGH SCORE"
	popup.dialog_text = "Your Best Score: " + str(high_score)
	popup.ok_button_text = "OK"
	add_child(popup)
	popup.popup_centered()

func _show_settings():
	var popup = AcceptDialog.new()
	popup.title = "SETTINGS"
	popup.dialog_text = "Settings will be added soon."
	popup.ok_button_text = "OK"
	add_child(popup)
	popup.popup_centered()

func _quit_game():
	get_tree().quit()

func _process(delta):
	for i in range(racing_lines.size()):
		var line = racing_lines[i]
		line.position.y += racing_line_speeds[i] * delta
		if line.position.y > 700:
			line.position.y = -line.size.y
			line.position.x = randf_range(80, 1070)

func _show_garage():
	var garage = ColorRect.new()
	garage.name = "GarageScreen"
	garage.color = Color(0.02, 0.025, 0.04, 1.0)
	garage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(garage)
	# Garage title
	var title = Label.new()
	title.text = "GARAGE"
	title.position = Vector2(0, 70)
	title.size = Vector2(1152, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 58)
	title.add_theme_color_override("font_color", Color(0.95, 0.08, 0.08))
	garage.add_child(title)
	# Car name
	var car_name = Label.new()
	car_name.text = "SPORT GT"
	car_name.position = Vector2(0, 150)
	car_name.size = Vector2(1152, 50)
	car_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	car_name.add_theme_font_size_override("font_size", 26)
	garage.add_child(car_name)
	# 3D car preview area
	var preview = SubViewportContainer.new()
	preview.name = "CarPreview"
	preview.position = Vector2(300, 220)
	preview.size = Vector2(550, 220)
	garage.add_child(preview)
	var viewport = SubViewport.new()
	viewport.name = "CarViewport"
	viewport.size = Vector2i(550, 220)
	viewport.transparent_bg = true
	preview.add_child(viewport)
	var camera = Camera3D.new()
	camera.position = Vector3(0, 2.5, 7)
	camera.look_at_from_position(camera.position,Vector3(0, 0.5, 0))
	viewport.add_child(camera)
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -25, 0)
	light.light_energy = 1.2
	viewport.add_child(light)
	var garage_car = Node3D.new()
	garage_car.name = "GarageCar"
	viewport.add_child(garage_car)
	# Garage car body
	var body = MeshInstance3D.new()
	var body_mesh = PrismMesh.new()
	body_mesh.size = Vector3(2.0, 0.8, 4.0)
	body_mesh.left_to_right = 0.7
	body.mesh = body_mesh
	body.position = Vector3(0, 0, 0)
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = selected_car_color
	body_material.metallic = 0.25
	body_material.roughness = 0.3
	body.material_override = body_material
	garage_car.add_child(body)
	
	# Garage car cabin
	var cabin = MeshInstance3D.new()
	var cabin_mesh = BoxMesh.new()
	cabin_mesh.size = Vector3(1.5, 0.5, 1.8)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 0.9, 0.2)
	var cabin_material = StandardMaterial3D.new()
	cabin_material.albedo_color = Color(0.05, 0.05, 0.08)
	cabin_material.metallic = 0.2
	cabin_material.roughness = 0.2
	cabin.material_override = cabin_material
	garage_car.add_child(cabin)
	
	# Garage car spoiler
	var spoiler = MeshInstance3D.new()
	var spoiler_mesh = BoxMesh.new()
	spoiler_mesh.size = Vector3(2.0, 0.15, 0.4)
	spoiler.mesh = spoiler_mesh
	spoiler.position = Vector3(0, 1.0, 1.65)
	var spoiler_material = StandardMaterial3D.new()
	spoiler_material.albedo_color = Color(0.02, 0.02, 0.02)
	spoiler_material.metallic = 0.3
	spoiler_material.roughness = 0.4
	spoiler.material_override = spoiler_material
	garage_car.add_child(spoiler)
	
	# Garage car wheels
	for wheel_position in [
		Vector3(-0.82, 0.0, -1.25),
		Vector3(0.82, 0.0, -1.25),
		Vector3(-0.82, 0.0, 1.25),
		Vector3(0.82, 0.0, 1.25)
	]:
		var wheel = MeshInstance3D.new()
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
		garage_car.add_child(wheel)
# Garage car headlights
	for x_position in [-0.65, 0.65]:
		var headlight = MeshInstance3D.new()
		var light_mesh = SphereMesh.new()
		light_mesh.radius = 0.18
		light_mesh.height = 0.36
		headlight.mesh = light_mesh
		headlight.position = Vector3(x_position, 0.65, -2.02)
		var light_material = StandardMaterial3D.new()
		light_material.albedo_color = Color(1.0, 0.9, 0.5)
		light_material.emission_enabled = true
		light_material.emission = Color(1.0, 0.8, 0.3)
		light_material.emission_energy_multiplier = 2.0
		headlight.material_override = light_material
		garage_car.add_child(headlight)
		
		# Garage car brake lights
	for x_position in [-0.65, 0.65]:
		var brake_light = MeshInstance3D.new()
		var brake_mesh = SphereMesh.new()
		brake_mesh.radius = 0.15
		brake_mesh.height = 0.3
		brake_light.mesh = brake_mesh
		brake_light.position = Vector3(x_position, 0.65, 2.02)
		var brake_material = StandardMaterial3D.new()
		brake_material.albedo_color = Color(1.0, 0.0, 0.0)
		brake_material.emission_enabled = true
		brake_material.emission = Color(1.0, 0.0, 0.0)
		brake_material.emission_energy_multiplier = 1.5
		brake_light.material_override = brake_material
		garage_car.add_child(brake_light)
		
		# Garage car side mirrors
	for x_position in [-1.05, 1.05]:
		var mirror = MeshInstance3D.new()
		var mirror_mesh = BoxMesh.new()
		mirror_mesh.size = Vector3(0.25, 0.2, 0.45)
		mirror.mesh = mirror_mesh
		mirror.position = Vector3(x_position, 0.9, -0.15)
		var mirror_material = StandardMaterial3D.new()
		mirror_material.albedo_color = Color(0.02, 0.02, 0.02)
		mirror_material.metallic = 0.5
		mirror_material.roughness = 0.3
		mirror.material_override = mirror_material
		garage_car.add_child(mirror)
		
		# Garage car windshield
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
	garage_car.add_child(windshield)
	
	# Garage car rear windshield
	var rear_windshield = MeshInstance3D.new()
	var rear_mesh = BoxMesh.new()
	rear_mesh.size = Vector3(1.35, 0.35, 0.08)
	rear_windshield.mesh = rear_mesh
	rear_windshield.position = Vector3(0, 1.0, 0.95)
	var rear_material = StandardMaterial3D.new()
	rear_material.albedo_color = Color(0.05, 0.15, 0.2)
	rear_material.metallic = 0.2
	rear_material.roughness = 0.15
	rear_windshield.material_override = rear_material
	garage_car.add_child(rear_windshield)
	# Color button
	var color_button = create_button("CHANGE COLOR", Vector2(426, 450))
	color_button.pressed.connect(func():
		var colors = [
			Color(0.8, 0.02, 0.02),
			Color(0.02, 0.15, 0.8),
			Color(0.02, 0.02, 0.02),
			Color(0.9, 0.9, 0.9),
			Color(0.9, 0.65, 0.02)]
		var material = body.material_override as StandardMaterial3D
		var current_color = material.albedo_color
		var next_index = 0
		for i in range(colors.size()):
			if current_color.is_equal_approx(colors[i]):
				next_index = (i + 1) % colors.size()
				break
		material.albedo_color = colors[next_index]
		selected_car_color = colors[next_index]
		save_car_color())
	garage.add_child(color_button)
	# Back button
	var back_button = create_button("BACK", Vector2(426, 530))
	back_button.pressed.connect(func():garage.queue_free())
	garage.add_child(back_button)

func save_car_color():
	var file = FileAccess.open("user://car_color.save", FileAccess.WRITE)
	file.store_var(selected_car_color)
	file.close()

func load_car_color():
	if FileAccess.file_exists("user://car_color.save"):
		var file = FileAccess.open("user://car_color.save", FileAccess.READ)
		selected_car_color = file.get_var()
		file.close()

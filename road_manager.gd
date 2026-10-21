extends Node3D

var world_environment: WorldEnvironment
@onready var sun = $Sun

@export var road_length: float = 100.0
@export var road_width: float = 12.0
@export var segments_ahead: int = 6

var road_segments: Array[MeshInstance3D] = []
var environment_objects: Array[Node3D] = []
var grass_segments: Array[MeshInstance3D] = []
var next_segment_z: float = 0.0

@onready var player = $PlayerCar


func _ready():
		var fade = ColorRect.new()
		fade.color = Color(0, 0, 0, 1)
		fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fade_layer = CanvasLayer.new()
		fade_layer.layer = 100
		fade_layer.add_child(fade)
		get_tree().root.add_child(fade_layer)
		var fade_tween = create_tween()
		fade_tween.tween_property(fade, "color:a", 0.0, 0.6)
		fade_tween.tween_callback(fade_layer.queue_free)
		world_environment = WorldEnvironment.new()
		world_environment.name = "WorldEnvironment"
		var environment = Environment.new()
		environment.background_mode = Environment.BG_SKY
		var sky = Sky.new()
		var sky_material = ProceduralSkyMaterial.new()
		sky_material.sky_top_color = Color(0.25, 0.5, 0.9)
		sky_material.sky_horizon_color = Color(0.75, 0.85, 1.0)
		sky_material.ground_bottom_color = Color(0.08, 0.12, 0.06)
		sky_material.ground_horizon_color = Color(0.55, 0.65, 0.45)
		sky.sky_material = sky_material
		environment.sky = sky
		environment.fog_enabled = true
		environment.fog_light_color = Color(0.65, 0.75, 0.85)
		environment.fog_density = 0.008
		environment.fog_sky_affect = 0.3
		world_environment.environment = environment
		add_child(world_environment)
		for i in range(segments_ahead):
			create_road_segment(i)
		next_segment_z = -segments_ahead * road_length
		sun.light_energy = 0.85
		sun.shadow_enabled = true


func _process(_delta):
	if player.position.z < next_segment_z + road_length * 3:
		create_road_segment(road_segments.size())
	remove_old_segments()


func create_road_segment(index: int):
	var road = MeshInstance3D.new()
	road.name = "RoadSegment_" + str(index)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(road_width, 0.2, road_length)
	road.mesh = mesh
	road.position = Vector3(0, 0, next_segment_z)
	add_child(road)
	create_lane_markings(next_segment_z + road_length)
	create_road_shoulders(next_segment_z + road_length)
	create_road_barriers(next_segment_z + road_length)
	create_grass_patches(next_segment_z + road_length)
	road_segments.append(road)
	next_segment_z -= road_length
	create_roadside_objects(next_segment_z + road_length)
	create_grass_segment(next_segment_z + road_length)


func remove_old_segments():
	for road in road_segments.duplicate():
		if road.position.z > player.position.z + road_length * 2:
			road_segments.erase(road)
			road.queue_free()
	for tree in environment_objects.duplicate():
		if tree.position.z > player.position.z + road_length * 2:
			environment_objects.erase(tree)
			tree.queue_free()
	for grass in grass_segments.duplicate():
		if grass.position.z > player.position.z + road_length * 2:
			grass_segments.erase(grass)
			grass.queue_free()


func create_roadside_objects(z_position: float):
	for side in [-1, 1]:
		var tree = Node3D.new()
		tree.name = "Tree"
		# Tree trunk
		var trunk = MeshInstance3D.new()
		var trunk_mesh = CylinderMesh.new()
		trunk_mesh.top_radius = 0.2
		trunk_mesh.bottom_radius = 0.3
		trunk_mesh.height = 2.0
		trunk.mesh = trunk_mesh
		trunk.position.y = 1.0
		tree.add_child(trunk)

# Tree leaves
		var leaves = MeshInstance3D.new()
		var leaves_mesh = SphereMesh.new()
		leaves_mesh.radius = 1.2
		leaves_mesh.height = 2.4
		leaves.mesh = leaves_mesh
		leaves.position.y = 2.7
		tree.add_child(leaves)

# Position beside road
		var tree_x = side * randf_range(8.0, 13.0)
		var tree_z = z_position - randf_range(0.0, road_length)
		tree.position = Vector3(
		tree_x,
		0,
		tree_z)
		var tree_scale = randf_range(0.7, 1.4)
		tree.scale = Vector3.ONE * tree_scale
		add_child(tree)
		environment_objects.append(tree)
		var bush = MeshInstance3D.new()
		bush.name = "Bush"
		var bush_mesh = SphereMesh.new()
		bush_mesh.radius = 0.7
		bush_mesh.height = 1.0
		bush.mesh = bush_mesh
		bush.position = Vector3(
		side * randf_range(7.0, 12.0),
		0.35,
		z_position - randf_range(0.0, road_length)
		)
		var bush_material = StandardMaterial3D.new()
		bush_material.albedo_color = Color(0.08, 0.3, 0.08)
		bush.material_override = bush_material
		bush.scale = Vector3.ONE * randf_range(0.5, 1.0)
		add_child(bush)
		environment_objects.append(bush)
	for side in [-1, 1]:
		var pole = MeshInstance3D.new()
		pole.name = "LampPost"
		var pole_mesh = CylinderMesh.new()
		pole_mesh.top_radius = 0.08
		pole_mesh.bottom_radius = 0.12
		pole_mesh.height = 3.5
		pole.mesh = pole_mesh
		pole.position = Vector3(
		side * 8.0,
		1.75,
		z_position - randf_range(10.0, road_length)
		)
		var pole_material = StandardMaterial3D.new()
		pole_material.albedo_color = Color(0.12, 0.12, 0.12)
		pole_material.metallic = 0.5
		pole.material_override = pole_material
		add_child(pole)
		environment_objects.append(pole)


func create_grass_segment(z_position: float):
	for side in [-1, 1]:
		var grass = MeshInstance3D.new()
		grass.name = "Grass"
		var mesh = BoxMesh.new()
		mesh.size = Vector3(12.0, 0.1, road_length)
		grass.mesh = mesh

		grass.position = Vector3(
			side * 10.0,
			-0.05,
			z_position - road_length * 0.5)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.15, 0.45, 0.12)
		grass.material_override = material
		add_child(grass)
		grass_segments.append(grass)

func create_lane_markings(z_position: float):
	for lane_x in [-1.5, 1.5]:
		var marking = MeshInstance3D.new()
		marking.name = "LaneMarking"
		var mesh = BoxMesh.new()
		mesh.size = Vector3(0.15, 0.03, road_length)
		marking.mesh = mesh
		marking.position = Vector3(
			lane_x,
			0.12,
			z_position - road_length * 0.5)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1.0, 1.0, 1.0)
		marking.material_override = material
		add_child(marking)
		environment_objects.append(marking)
	for edge_x in [-5.5, 5.5]:
		var edge = MeshInstance3D.new()
		edge.name = "RoadEdge"
		var edge_mesh = BoxMesh.new()
		edge_mesh.size = Vector3(0.18, 0.03, road_length)
		edge.mesh = edge_mesh
		edge.position = Vector3(
			edge_x,
			0.12,
			z_position - road_length * 0.5)
		var edge_material = StandardMaterial3D.new()
		edge_material.albedo_color = Color(1.0, 1.0, 1.0)
		edge.material_override = edge_material
		add_child(edge)
		environment_objects.append(edge)

func create_road_shoulders(z_position: float):
	for side in [-1, 1]:
		var shoulder = MeshInstance3D.new()
		shoulder.name = "RoadShoulder"
		var mesh = BoxMesh.new()
		mesh.size = Vector3(0.8, 0.05, road_length)
		shoulder.mesh = mesh
		shoulder.position = Vector3(
			side * 6.0,
			0.08,
			z_position - road_length * 0.5)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.18, 0.18, 0.18)
		shoulder.material_override = material
		add_child(shoulder)
		environment_objects.append(shoulder)


func create_road_barriers(z_position: float):
	for side in [-1, 1]:
		var barrier = MeshInstance3D.new()
		barrier.name = "RoadBarrier"
		var mesh = BoxMesh.new()
		mesh.size = Vector3(0.25, 0.8, road_length)
		barrier.mesh = mesh
		barrier.position = Vector3(
			side * 6.8,
			0.4,
			z_position - road_length * 0.5)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.488, 0.488, 0.488, 1.0)
		material.metallic = 0.3
		material.roughness = 0.5
		barrier.material_override = material
		add_child(barrier)
		environment_objects.append(barrier)
	for side in [-1, 1]:
		for i in range(5):
			var reflector = MeshInstance3D.new()
			reflector.name = "RoadReflector"
			var reflector_mesh = BoxMesh.new()
			reflector_mesh.size = Vector3(0.15, 0.08, 0.3)
			reflector.mesh = reflector_mesh
			reflector.position = Vector3(
			side * 6.45,
			0.12,
			z_position - i * (road_length / 5.0))
			var reflector_material = StandardMaterial3D.new()
			reflector_material.albedo_color = Color(1.0, 0.8, 0.2)
			reflector_material.emission_enabled = true
			reflector_material.emission = Color(1.0, 0.6, 0.1)
			reflector_material.emission_energy_multiplier = 2.0
			reflector.material_override = reflector_material
			add_child(reflector)
			environment_objects.append(reflector)

func create_grass_patches(z_position: float):
	for side in [-1, 1]:
		for i in range(6):
			var grass = MeshInstance3D.new()
			grass.name = "GrassPatch"
			var mesh = BoxMesh.new()
			mesh.size = Vector3(
			randf_range(1.0, 3.0),
			0.08,
			randf_range(1.0, 4.0)
			)
			grass.mesh = mesh
			grass.position = Vector3(
			side * randf_range(7.0, 14.0),
			0.02,
			z_position - randf_range(0.0, road_length)
			)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.12, 0.4, 0.08)
			grass.material_override = material
			add_child(grass)
			environment_objects.append(grass)

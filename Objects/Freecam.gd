extends Camera3D

@export var mouse_sensitivity: float = 0.003
@export var speed: float = 10
@export var point_speed: float = 1
@export var speed_change: float = 1

var point_distance = 10
var looking = false
var mouse_position = Vector3()

var Spline3D = preload("res://Objects/B-Spline3D.gd")
var spline = Spline3D.new()

var ControlPoint = preload("res://Objects/ControlPoint.tscn")
var preview_point: MeshInstance3D

var line_mesh

var traversal_thing = 0.9

func _ready():
	preview_point = ControlPoint.instantiate()
	add_child(preview_point)
	line_mesh = $"../Lines".mesh

func _process(delta):
	#Handle Movement
	var horizontal_direction = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var vertical_direction = Input.get_axis("player_down", "player_up")
	position += (global_transform.basis * Vector3(horizontal_direction.x, vertical_direction, horizontal_direction.y)).normalized() * speed * delta
	
	mouse_position = project_position(get_viewport().get_mouse_position(), point_distance)
	if Input.is_action_just_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if looking:
		preview_point.visible = false
	else:
		preview_point.visible = true
		preview_point.global_transform.origin = mouse_position
	
	render_spline()
	
	if len(spline.points) < 2:
		return
	traversal_thing += 0.0001
	if traversal_thing > 1:
		traversal_thing = 0.9
	$"../TraversalPoint".global_transform.origin = spline.get_sample(traversal_thing)
	print(spline.get_tangent(traversal_thing).normalized().y)
	

func render_spline():
	while $"../ControlPoints".get_child_count() < len(spline.points):
		$"../ControlPoints".add_child(ControlPoint.instantiate())
	var Meshes = $"../ControlPoints".get_children()
	for i in range(len(spline.points)):
		Meshes[i].global_transform.origin = spline.points[i]
	if len(spline.points) < 2:
		return
	line_mesh.clear_surfaces()
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	#Draw the points
	for i in spline.points:
		line_mesh.surface_add_vertex(i)
	line_mesh.surface_end()
	#Draw the spline
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in spline.samples:
		line_mesh.surface_add_vertex(i)
	line_mesh.surface_end()

func _input(event):
	if event is InputEventMouseMotion:
		if looking:
			rotation.x -= event.relative.y * mouse_sensitivity
			rotation.y -= event.relative.x * mouse_sensitivity
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if not looking and event.pressed:
				spline.points.append(mouse_position)
				spline.bulk_sample(100)
		if event.button_index == 2:
			looking = event.pressed
			if event.pressed:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.button_index == 4 and event.pressed:
			if looking:
				speed += speed_change
			else:
				point_distance += point_speed
		elif event.button_index == 5 and event.pressed:
			if looking:
				speed -= speed_change
			else:
				point_distance -= point_speed

extends Node3D

@onready var cam_pivot = $CameraPivot
@onready var cam = $CameraPivot/Camera3D
@onready var ray = $RayCast3D

const ROTATE_SPEED := 0.005

var controlled_unit = null
var last_mouse_pos := Vector2.ZERO

func _ready():
	await get_tree().process_frame
	controlled_unit = get_node("../CharacterBase")
	

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var current := get_viewport().get_mouse_position()
		var dx := (current.x - last_mouse_pos.x) * ROTATE_SPEED

		var pivot := _get_camera_focus_point()
		cam_pivot.global_transform.origin = pivot
		cam_pivot.rotate_y(-dx)

	last_mouse_pos = get_viewport().get_mouse_position()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(event)
			return
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_right_click(event)
			return


func _move_selected_units(target):
	var units = SelectionManager.selected_units
	var spacing = 2.0 # distance between units

	for i in range(units.size()):
		var row = i / 3
		var col = i % 3
		var offset = Vector3(col * spacing, 0, row * spacing)
		units[i].agent.set_target_position(target + offset)

func _handle_left_click(event):
	var from = cam.project_ray_origin(event.position)
	var to = from + cam.project_ray_normal(event.position) * 2000
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if not result:
		return

	var collider = result["collider"]

	if collider.is_in_group("units"):
		if Input.is_key_pressed(KEY_SHIFT):
			SelectionManager.toggle_select(collider)
		else:
			SelectionManager.select_single(collider)
	
func _handle_right_click(event):
	if SelectionManager.selected_units.is_empty():
		return

	var from = cam.project_ray_origin(event.position)
	var to = from + cam.project_ray_normal(event.position) * 2000
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if not result:
		return

	_move_selected_units(result.position)
	

func _get_camera_focus_point() -> Vector3:
	if SelectionManager.selected_units.size() > 0:
		var center := Vector3.ZERO
		for unit in SelectionManager.selected_units:
			center += unit.global_transform.origin
		return center / SelectionManager.selected_units.size()

	# Fallback: rotate around where the camera is looking
	var from = cam.global_transform.origin
	var dir = -cam.global_transform.basis.z
	var plane := Plane(Vector3.UP, 0.0)
	var hit = plane.intersects_ray(from, dir)

	return hit if hit != null else cam_pivot.global_transform.origin

extends Node3D

@onready var cam = $CameraPivot/Camera3D
@onready var ray = $RayCast3D
var controlled_unit = null

func _ready():
	await get_tree().process_frame
	controlled_unit = get_node("../CharacterBase")
	

func _process(_delta):
	# Middle mouse to rotate
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		rotate_y(-Input.get_last_mouse_velocity().x * 0.002)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var from = cam.project_ray_origin(event.position)
		var to = from + cam.project_ray_normal(event.position) * 2000

		var query := PhysicsRayQueryParameters3D.create(from, to)
		var result := get_world_3d().direct_space_state.intersect_ray(query)

		if result:
			print("Hit terrain at: ", result.position)
			var collider = result["collider"]
			
			if collider.is_in_group("units"):
				SelectionManager.select_single(collider)
				return
			
			if SelectionManager.selected_units.size() > 0:
				_move_selected_units(result.position)
				return
		else:
			print("Ray missed")


func _move_selected_units(target):
	var units = SelectionManager.selected_units
	var spacing = 2.0 # distance between units

	for i in range(units.size()):
		var offset = Vector3((i % 3) * spacing, 0, (i / 3) * spacing)
		var dest = target + offset
		units[i].agent.set_target_position(dest)

extends Node

const DRAG_THRESHOLD := 6.0  # pixel distance before a drag counts as a drag

var selected_units: Array[Node] = []
var all_units: Array[Node] = []

var dragging := false
var drag_start: Vector2

@onready var box = get_tree().current_scene.get_node("UI/SelectionBox")
@onready var cam: Camera3D = get_viewport().get_camera_3d()


func _ready():
	all_units = get_tree().get_nodes_in_group("units")


func _unhandled_input(event):
	if get_viewport().gui_get_focus_owner():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = event.position
			box.begin(event.position)
		else:
			if dragging:
				var drag_distance := drag_start.distance_to(event.position)
			
				if drag_distance > DRAG_THRESHOLD:
					var rect: Rect2 = box.end(event.position)
					_select_by_rect(rect)
				else:
					box.visible = false
			dragging = false
	
	# MOUSE MOVE → UPDATE DRAG BOX
	elif event is InputEventMouseMotion and dragging:
		box.update(event.position)


func select_single(unit):
	if Input.is_key_pressed(KEY_SHIFT):
		toggle_select(unit)
		return

	_clear_selection()
	selected_units.append(unit)
	unit.select()


func _clear_selection():
	for u in selected_units:
		if is_instance_valid(u):
			u.deselect()
	selected_units.clear()


func _select_by_rect(rect: Rect2) -> void:
	var newly_selected: Array[Node] = []

	# find units inside the rectangle
	for unit in all_units:
		if not is_instance_valid(unit):
			continue

		var screen_pos: Vector2 = cam.unproject_position(
			unit.global_transform.origin
		)

		if rect.has_point(screen_pos):
			newly_selected.append(unit)

	# If rectangle selected NOTHING → do nothing (keep current selection)
	if newly_selected.is_empty():
		return

	# If Shift is NOT held, replace selection
	if not Input.is_key_pressed(KEY_SHIFT):
		_clear_selection()

	# Apply new selection
	for unit in newly_selected:
		if unit not in selected_units:
			selected_units.append(unit)
			unit.select()


func toggle_select(unit):
	if unit in selected_units:
		unit.deselect()
		selected_units.erase(unit)
	else:
		unit.select()
		selected_units.append(unit)

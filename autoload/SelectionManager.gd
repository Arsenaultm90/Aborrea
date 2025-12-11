extends Node

var selected_units: Array[Node] = []
var all_units: Array[Node] = []
var dragging := false
var drag_start: Vector2

@onready var box = get_tree().current_scene.get_node("UI/SelectionBox")

func _ready():
	all_units = get_tree().get_nodes_in_group("units")


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = event.position
				box.begin(event.position)
			else:
				if dragging:
					var rect : Rect2 = box.end(event.position)
					_select_by_rect(rect)
					dragging = false

	if event is InputEventMouseMotion and dragging:
		box.update(event.position)


func select_single(unit):
	_clear_selection()
	selected_units.append(unit)
	unit.select()


func _clear_selection():
	for u in selected_units:
		u.deselect()
	selected_units.clear()


func _select_by_rect(rect: Rect2):
	_clear_selection()

	for unit in all_units:
		var screen_pos = get_viewport().get_camera_3d().unproject_position(unit.global_transform.origin)
		if rect.has_point(screen_pos):
			selected_units.append(unit)
			unit.select()

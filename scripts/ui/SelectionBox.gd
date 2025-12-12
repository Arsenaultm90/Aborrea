extends ColorRect

var start_pos: Vector2
var end_pos: Vector2

func begin(pos: Vector2):
	start_pos = pos
	end_pos = pos
	visible = true
	_update_rect()

func update(pos: Vector2):
	end_pos = pos
	_update_rect()

func end(_pos: Vector2) -> Rect2 :
	visible = false
	return Rect2(
		min(start_pos.x, end_pos.x),
		min(start_pos.y, end_pos.y),
		abs(start_pos.x - end_pos.x),
		abs(start_pos.y - end_pos.y)
	)

func _update_rect():
	var rect = Rect2(start_pos, end_pos - start_pos)
	rect = rect.abs()
	position = rect.position
	size = rect.size

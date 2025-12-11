extends CharacterBody3D

@onready var agent = $NavigationAgent3D

var move_speed := 5.0
var is_selected: bool = false

func _ready():
	pass

func _physics_process(_delta):
	if agent.is_navigation_finished():
		velocity = Vector3.ZERO
	else:
		var nextpos = agent.get_next_path_position()
		var direction = (nextpos - global_transform.origin).normalized()
		velocity = direction * move_speed

	move_and_slide()


## --------------------------------------------------------------------
## 							PLAYER SELECTION
## --------------------------------------------------------------------
func select():
	is_selected = true
	if $SelectionIndicator:
		$SelectionIndicator.visible = true

func deselect():
	is_selected = false
	if $SelectionIndicator:
		$SelectionIndicator.visible = false

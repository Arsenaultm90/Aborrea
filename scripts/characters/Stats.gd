class_name Stats extends Resource

@export var strength: int = 5
@export var dexterity: int = 5
@export var constitution: int = 5
@export var perception: int = 5
@export var intelligence: int = 5
@export var wisdom: int = 5

func get_max_health() -> int:
	return constitution * 10

func get_max_stamina() -> int:
	return strength * 5 + dexterity * 3

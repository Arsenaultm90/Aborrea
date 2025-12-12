class_name CharacterData extends Resource

@export var character_name: String = "Unnamed"
@export var race: String = "Human"
@export var level: int = 1
@export var stats: Stats

var current_health: int
var current_stamina: int


func initialize():
	current_health = stats.get_max_health()
	current_stamina = stats.get_max_stamina()

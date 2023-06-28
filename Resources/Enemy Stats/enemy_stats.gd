extends Resource
class_name EnemyStats

#Variables

@export var health: float = 100
@export var turn_speed: float = 4.0
@export var move_speed: float = 2.0
@export var throw_strength: float = 10.0
@export var weapon: PackedScene

#Getters

func get_weapon() -> PackedScene:
	return weapon

extends Resource
class_name WepRes

#Stores stats of a base weapon

#Variables 
@export var damage: float = 1
@export var attack_speed: float = 1
@export var mass: float = 1
@export var thow_damage: float = 2
@export var auto: bool = false

#Getters
func is_auto():
	return auto

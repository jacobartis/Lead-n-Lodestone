extends Resource
class_name CharPhysicsRes

#Stores a characters physics values in one place

#Variables (uses base player values)
@export var max_ground_speed: float = 10
@export var max_air_speed: float = .94
var ground_acceleration: float = 10*max_ground_speed
var air_acceleration: float = 10*max_air_speed
@export var jump_strength: float = 10
@export var friction: float = 8

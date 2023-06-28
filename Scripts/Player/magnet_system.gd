extends Node3D

#Acts as bridge between the player script and the two magnet systems

#Node refrences
@onready var weapon_magnet_system = $WeaponMagnetSystem

#Functions

func pull(strength:float):
	weapon_magnet_system.pull(strength)

func push(strength:float):
	weapon_magnet_system.push(strength)

func set_aim(aim:Vector3):
	weapon_magnet_system.set_aim(aim)

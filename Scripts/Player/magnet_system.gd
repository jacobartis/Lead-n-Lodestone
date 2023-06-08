extends Node3D

#Acts as bridge between the player script and the two magnet systems

#Node refrences
@onready var weapon_magnet_system = $WeaponMagnetSystem

#Functions

func pull():
	weapon_magnet_system.pull()

func push():
	weapon_magnet_system.push()

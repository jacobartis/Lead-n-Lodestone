extends RigidBody3D
class_name DroppedWeapon

#Signals

signal equipping()

#Variable

@export var stats: WepRes
@export var equipped: PackedScene

#Setters

func set_equipped(val:PackedScene):
	equipped = val

func set_stats(res:WepRes):
	stats = res
	set_mass(stats.mass)

#Getters

func get_equipped_ver():
	emit_signal("equipping")
	#Saves the dropped version of the weapon
	var packed = PackedScene.new()
	packed.pack(self)
	#Creates an instance of the equipped weapon version and sets the dropped counterpart
	var inst = equipped.instantiate()
	inst.set_dropped(packed)
	inst.set_stats(stats)
	return inst

func equip() -> MeshInstance3D:
	queue_free()
	return get_equipped_ver()

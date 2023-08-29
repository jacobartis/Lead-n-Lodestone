extends RigidBody3D
class_name DroppedWeapon

#Variable

@export var stats: WepRes
@export var equipped: PackedScene

#Setters

func set_equipped(val:PackedScene):
	equipped = val

func set_stats(res:WepRes):
	stats = res

#Getters
func get_equipped_ver():
	#Saves the dropped version of the weapon
	var packed = PackedScene.new()
	packed.pack(self)
	#Creates an instance of the equipped weapon version and sets the dropped counterpart
	var inst = equipped.instantiate()
	inst.set_dropped(packed)
	inst.set_stats(stats)
	return inst

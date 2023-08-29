extends Node3D
class_name EquipedWeapon

#Variable

@export var stats: WepRes
@export var dropped: PackedScene

@onready var ac_timer = $AttackCooldown

#Setters

func set_dropped(val:PackedScene):
	dropped = val

func set_stats(res:WepRes):
	stats = res

#Getters

func get_dropped_ver():
	var packed = PackedScene.new()
	packed.pack(self)
	var inst = dropped.instantiate()
	inst.set_equipped(packed)
	inst.set_stats(stats)
	return inst

#Functions

#Returns if the weapon can attack (no cooldown by default)
func can_attack() -> bool:
	return !ac_timer.get_time_left()

func start_cooldown():
	ac_timer.start(1.0/stats.attack_speed)

func auto_attack() -> void:
	if !stats.is_auto():
		return
	attack()

#To be overridden by weapon type
func attack():
	pass


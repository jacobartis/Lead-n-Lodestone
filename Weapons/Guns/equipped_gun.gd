extends EquipedWeapon

#Variables

#Node References
@onready var proj_spawn = $ProjSpawn

#Functions



func attack() -> void:
	if !can_attack():
		return
	start_cooldown()
	var proj = stats.proj_scene.instantiate()
	proj.set_position(proj_spawn.get_global_position())
	proj.set_velocity(-proj_spawn.get_global_transform().basis.z*stats.proj_speed)
	proj.set_damage(stats.damage)
	find_parent("World").add_child(proj)

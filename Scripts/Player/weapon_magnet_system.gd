extends RayCast3D

@onready var magnet_area = $MagnetArea
@onready var pull_cooldown = $PullCooldown
@onready var default = $Default

var aim: Vector3 = Vector3.ZERO

func set_aim(value: Vector3):
	aim = value

#Handles pulling magnetic objects to the player
func pull(strength:float) -> void:
	if !pull_cooldown.is_stopped():
		return
	magnet_area.set_global_position(get_magnet_point())
	var mag_pos = magnet_area.get_global_position()
	for body in magnet_area.get_overlapping_bodies():
		if !body.is_in_group("Magnetic"):
			continue
		if body.get_position().distance_to(mag_pos)>.5:
			body.find_child("Magnetic").pull(mag_pos,strength)
		else:
			body.find_child("Magnetic").pull(mag_pos,strength*sqrt(body.get_position().distance_to(mag_pos)))

#Handles pushing weapons away from the magnet point
func push(strength:float) -> void:
	magnet_area.set_global_position(get_magnet_point())
	for body in magnet_area.get_overlapping_bodies():
		if !body.is_in_group("Magnetic"):
			continue
		
		#If the player is aiming at a location the weapon is pulled towards that location to increase acuracy.
		if aim != Vector3.ZERO:
			body.find_child("Magnetic").pull(aim,20)
		#Else the weapon is pushed from the position of the weapon system.
		else:
			body.find_child("Magnetic").push(get_global_position(),20)
	pull_cooldown.start(1)

#Gets the point of the magnatisms origin
func get_magnet_point() -> Vector3:
	if (get_collision_point()-global_position).length_squared() > 2.5:
		#If the distance is bigger than 2 a default position is used instead
		return default.get_global_position()
	#Returns the point of collision if the default would be behind a wall
	return get_collision_point()

extends DroppedWeapon

#Variables

var neg_pol: bool = false
var active: bool = false
var mag_bodies: Array[RigidBody3D] 

#Setters

func set_active(val: bool) -> void:
	active = val

func set_polarity(val: bool) -> void:
	neg_pol = val

#Getters

func get_polarity() -> bool:
	return neg_pol

#Functions

func _physics_process(delta):
	if !active:
		return
	
	for body in mag_bodies:
		var force = body.global_position.direction_to(global_position)*stats.strength*(1.0/body.global_position.distance_squared_to(global_position))
		
		if neg_pol:
			force = -force 
		
		body.apply_force(force)
		apply_force(-force)
	

#Signal functions

func _on_magnet_range_body_entered(body):
	if body.is_in_group("magnetic"):
		mag_bodies.append(body)


func _on_magnet_range_body_exited(body):
	if !body is RigidBody3D:
		return
	if body in mag_bodies:
		mag_bodies.erase(body)


func _on_body_entered(body):
	print(linear_velocity.length())
	if linear_velocity.length() < 5:
		return
	print("Freeze")
	set_freeze_enabled(true)


func _on_equipping():
	print("unfreeze")
	set_freeze_enabled(false)

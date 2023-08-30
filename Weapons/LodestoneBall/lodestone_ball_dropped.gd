extends DroppedWeapon

#Variables

var polarity: bool = true
var active: bool = false
var mag_bodies: Array[RigidBody3D] 

#Setters

func set_active(val: bool) -> void:
	active = val

func set_polarity(val: bool) -> void:
	polarity = val

#Functions

func _physics_process(delta):
	if !active:
		return
	
	for body in mag_bodies:
		var force = body.global_position.direction_to(global_position)*stats.strength*(1.0/body.global_position.distance_squared_to(global_position))
		
		if !polarity:
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

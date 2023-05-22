extends magnetic


#Handles magnetic properties for default weapons
func pull(pos:Vector3,strength:float):
	body.set_linear_velocity(body.get_position().direction_to(pos).normalized()*strength)
func push(pos:Vector3,strength:float):
	body.set_linear_velocity(pos.direction_to(body.get_position()).normalized()*strength)

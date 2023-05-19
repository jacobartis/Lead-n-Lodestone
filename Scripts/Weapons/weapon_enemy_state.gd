extends WeaponBaseState

func enter():
	body.set_layer_mask(1)
	body.set_freeze_enabled(true)
	body.set_collision_layer_value(2,false)
	body.set_collision_mask_value(1,false)
	body.set_collision_mask_value(2,false)

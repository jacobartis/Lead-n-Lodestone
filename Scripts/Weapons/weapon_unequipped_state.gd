extends WeaponBaseState

@onready var timer = $Timer

func enter():
	body.set_layer_mask(1)
	body.set_freeze_enabled(false)
	timer.start(0.05)


func _on_timer_timeout():
	if !body:
		return
	body.set_collision_layer_value(2,true)
	body.set_collision_mask_value(1,true)
	body.set_collision_mask_value(2,true)

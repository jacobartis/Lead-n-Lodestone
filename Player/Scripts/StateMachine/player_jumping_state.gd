extends PlayerBaseState

func enter():
	var phy: CharPhysicsRes = body.get_physics_res()
	var vel = body.get_velocity()
	vel.y += phy.jump_strength
	body.set_velocity(vel)

func process(delta):
	return PlayerBaseState.State.Idle

func physics_process(delta):
	body.move_and_slide()

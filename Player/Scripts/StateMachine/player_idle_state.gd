extends PlayerBaseState


func process(delta) -> PlayerBaseState.State:
	if !body.is_on_floor():
		return PlayerBaseState.State.Falling
	elif is_direction_pressed():
		return PlayerBaseState.State.Walking
	elif is_jump_pressed(): 
		return PlayerBaseState.State.Jumping
	return PlayerBaseState.State.None


func is_direction_pressed() -> bool:
	return Input.get_vector("Player_Left", "Player_Right", "Player_Forward", "Player_Back") != Vector2.ZERO

func is_jump_pressed():
	return Input.is_action_just_pressed("Player_Jump")

func physics_process(delta):
	var vel = apply_friction(body.get_velocity(),delta, body.get_physics_res())
	body.set_velocity(vel)
	body.move_and_slide()

func apply_friction(vel: Vector3, delta: float, phy_res: CharPhysicsRes) -> Vector3:
	var speed: float = vel.length()
	var drop: float = 0
	if speed < 0.01:
		return vel*Vector3(0,1,0)
	if body.is_on_floor():
		drop += speed*phy_res.friction*delta
	return vel*clamp(speed - drop,0,INF)/speed

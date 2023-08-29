extends PlayerBaseState

func process(delta):
	if body.is_on_floor():
		return PlayerBaseState.State.Idle
	return PlayerBaseState.State.None

func physics_process(delta) -> void:
	movement(delta)

func movement_input() -> Vector3:
	var input_dir = Input.get_vector("Player_Left", "Player_Right", "Player_Forward", "Player_Back")
	return (body.get_transform().basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

#Handles basic player movement
func movement(delta) -> void:
	var vel = body.get_velocity()
	var phy_res = body.get_physics_res()
	
	#Uses quake movement system allowing for interesting movement techinques
	vel = update_air_velocity(vel,movement_input(),delta,phy_res)
	vel.y -= ProjectSettings.get_setting("physics/3d/default_gravity")*delta
	body.set_velocity(vel)
	body.move_and_slide()

func update_air_velocity(vel: Vector3, wish_dir: Vector3, delta: float, phy_res: CharPhysicsRes) -> Vector3:
	return vel + clamp(phy_res.max_air_speed - vel.dot(wish_dir), 0 , phy_res.air_acceleration/5) * wish_dir

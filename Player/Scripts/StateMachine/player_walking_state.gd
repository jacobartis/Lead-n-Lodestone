extends PlayerBaseState

#Functions

func enter():
	body.set_cam_control(true)

func process(delta):
	if movement_input() == Vector3.ZERO:
		return PlayerBaseState.State.Idle
	elif is_jump_pressed():
		return PlayerBaseState.State.Jumping
	elif !body.is_on_floor():
		return PlayerBaseState.State.Falling
	return PlayerBaseState.State.None

func movement_input() -> Vector3:
	var input_dir = Input.get_vector("Player_Left", "Player_Right", "Player_Forward", "Player_Back")
	return (body.get_transform().basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func is_jump_pressed():
	return Input.is_action_just_pressed("Player_Jump")

func physics_process(delta) -> void:
	movement(delta)

#Handles basic player movement
func movement(delta) -> void:
	var vel = body.get_velocity()
	var phy_res = body.get_physics_res()
	
	#Uses quake movement system allowing for interesting movement techinques
	vel = update_ground_velocity(vel,movement_input(),delta,phy_res)
	
	if !body.is_on_floor():
		vel.y -= ProjectSettings.get_setting("physics/3d/default_gravity")*delta
	
	body.set_velocity(vel)
	
	body.move_and_slide()

#Quake velocity and friction functions
func update_ground_velocity(vel: Vector3, wish_dir: Vector3, delta: float, phy_res: CharPhysicsRes) -> Vector3:
	vel = apply_friction(vel, delta, phy_res)
	return vel + clamp(phy_res.max_ground_speed - vel.dot(wish_dir), 0 , phy_res.ground_acceleration) * wish_dir

func apply_friction(vel: Vector3, delta: float, phy_res: CharPhysicsRes) -> Vector3:
	var speed: float = vel.length()
	var drop: float = 0
	if speed < 0.01:
		return vel*Vector3(0,1,0)
	if body.is_on_floor():
		drop += speed*phy_res.friction*delta
	return vel*clamp(speed - drop,0,INF)/speed

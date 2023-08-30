extends CharacterBody3D

#Signals
signal velocity_update(velocity)
signal mode_update(mode)

#Node Refrences
@export var physics_res: CharPhysicsRes
@onready var state_controller: Node = $PlayerStateController
@onready var cam: Camera3D = $Camera3D
@onready var interact_ray = $Camera3D/InteractRay
@onready var aim_ray = $Camera3D/AimRay
@onready var gun_hand = $Camera3D/GunHand
@onready var ball_hand = $Camera3D/BallHand
@onready var ball_ray = $Camera3D/BallRay

#Physics Variables
var max_ground_speed: float = 10
var max_air_speed: float = .94
var acceleration: float = 10*max_ground_speed
var jump_strength: float = 10

#Action Variables
var cam_control: bool = true
var int_control: bool = true

#Weapon variables
var ball_mode: bool = false

#Setters

func set_cam_control(val:bool) -> void:
	cam_control = val

func set_int_control(val:bool) -> void:
	int_control = val

#Getters

func get_physics_res() -> CharPhysicsRes:
	return physics_res

func get_weapon(hand:Node3D):
	if !hand.get_child_count():
		return null
	return hand.get_child(0)

#Functions

func _ready() -> void:
	state_controller.init(self)

func _process(delta) -> void:
	state_controller.process(delta)
	set_aim()
	if int_control:
		check_base_interaction()
		if ball_mode:
			check_ball_controls()

func set_aim() -> void:
	if !aim_ray.is_colliding():
		return
	if get_weapon(gun_hand):
		get_weapon(gun_hand).look_at(aim_ray.get_collision_point())
	if get_weapon(ball_hand):
		get_weapon(ball_hand).look_at(aim_ray.get_collision_point())

func check_base_interaction():
	if Input.is_action_just_pressed("Player_Change_Mode"):
		mode_toggle()
	if Input.is_action_just_pressed("Player_Interact"):
		interact()
	if Input.is_action_just_pressed("Player_Throw"):
		drop()
	check_attack()

func mode_toggle():
	ball_mode = !ball_mode
	emit_signal("mode_update",ball_mode)

func interact() -> void:
	if !interact_ray.get_collider():
		return
	
	if interact_ray.get_collider().is_in_group("dropped_weapon"):
		equip_weapon(interact_ray.get_collider(),gun_hand)
	if interact_ray.get_collider().is_in_group("lodestone_ball"):
		equip_weapon(interact_ray.get_collider(),ball_hand)

func drop() ->void:
	if !ball_mode and get_weapon(gun_hand):
		drop_weapon(gun_hand)
	elif ball_mode and get_weapon(ball_hand):
		drop_weapon(ball_hand)

func check_attack() -> void:
	if !(!ball_mode and get_weapon(gun_hand)):
		return
	if Input.is_action_just_pressed("Player_Attack"):
		get_weapon(gun_hand).attack()
	elif Input.is_action_pressed("Player_Attack"):
		get_weapon(gun_hand).auto_attack()

func equip_weapon(weapon: Node3D, hand:Node3D):
	if get_weapon(hand):
		drop_weapon(hand)
	
	var equip_ver = weapon.get_equipped_ver()
	equip_ver.set_transform(hand.get_transform())
	hand.add_child(equip_ver)
	
	weapon.queue_free()

func drop_weapon(hand:Node3D):
	var drop_ver = get_weapon(hand).get_dropped_ver()
	
	find_parent("World").add_child(drop_ver)
	
	drop_ver.set_global_transform(get_weapon(hand).get_global_transform())
	drop_ver.apply_impulse(-drop_ver.transform.basis.z*20)
	
	get_weapon(hand).queue_free()

func check_ball_controls():
	if Input.is_action_pressed("Player_Ball_Pull"):
		ball_pull()
	if Input.is_action_just_pressed("Player_Ball_Toggle_Polarity"):
		ball_toggle_polarity()
	if Input.is_action_just_pressed("Player_Ball_Toggle_Active"):
		ball_toggle_active()

func ball_pull() -> void:
	if get_weapon(ball_hand):
		return
	if !ball_ray.is_colliding():
		return
	var ball = ball_ray.get_collider()
	ball.apply_impulse(ball.global_position.direction_to(global_position)*50)

func ball_toggle_polarity() -> void:
	var ball
	if get_weapon(ball_hand):
		ball = get_weapon(ball_hand)
	elif ball_ray.is_colliding():
		ball = ball_ray.get_collider()
	else:
		return
	ball.set_polarity(!ball.polarity)

func ball_toggle_active() -> void:
	var ball
	if get_weapon(ball_hand):
		ball = get_weapon(ball_hand)
	elif ball_ray.is_colliding():
		ball = ball_ray.get_collider()
	else:
		return
	ball.set_active(!ball.active)

func _physics_process(delta) -> void:
	state_controller.physics_process(delta)
	emit_signal("velocity_update",velocity)

func _input(event):
	move_camera(event as InputEventMouseMotion)

#Rotates the player and camera by the mouse motion
func move_camera(mouse_mo:InputEventMouseMotion) -> void:
	if !mouse_mo or !cam_control:
		return
	
	if !MouseController.is_mouse_locked():
		return
	
	var cam_rot = cam.get_rotation()
	cam_rot.y -= mouse_mo.relative.x * MouseController.get_sensitivity()
	cam_rot.x -= mouse_mo.relative.y * MouseController.get_sensitivity()
	cam.set_rotation(Vector3(clamp(cam_rot.x, -1.3, 1.3),cam.get_rotation().y,cam.get_rotation().z))
	set_rotation(get_rotation()+Vector3(0,cam_rot.y,0))

func take_damage(damage:float):
	print(name," took ",damage," damage")

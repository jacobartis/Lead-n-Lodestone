extends CharacterBody3D

#Signals
signal velocity_update(velocity)
signal mode_update(mode)

#Node Refrences
@export var physics_res: CharPhysicsRes
@onready var state_controller: Node = $PlayerStateController
@onready var cam: Camera3D = $Camera3D
@onready var interact_ray = $Camera3D/InteractRay
@onready var gun_hand = $Camera3D/GunHand
@onready var ball_hand = $Camera3D/BallHand

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
	if int_control:
		check_mode_toggle()
		check_interact()
		check_drop()
		check_attack()

func check_mode_toggle():
	if !Input.is_action_just_pressed("Player_Change_Mode"):
		return
	ball_mode = !ball_mode
	emit_signal("mode_update",ball_mode)

func check_interact() -> void:
	if !Input.is_action_just_pressed("Player_Interact"):
		return
	if !interact_ray.get_collider():
		return
	
	if interact_ray.get_collider().is_in_group("dropped_weapon"):
		equip_weapon(interact_ray.get_collider(),gun_hand)
	if interact_ray.get_collider().is_in_group("lodestone_ball"):
		equip_weapon(interact_ray.get_collider(),ball_hand)

func check_drop() ->void:
	if !Input.is_action_just_pressed("Player_Throw"):
		return
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

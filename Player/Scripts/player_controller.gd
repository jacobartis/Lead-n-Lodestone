extends CharacterBody3D

#Signals
signal velocity_update(velocity)

#Node Refrences
@export var physics_res: CharPhysicsRes
@onready var state_controller: Node = $PlayerStateController
@onready var cam: Camera3D = $Camera3D
@onready var interact_ray = $Camera3D/InteractRay
@onready var aim_ray = $Camera3D/AimRay
@onready var gun_hand = $Camera3D/GunHand
@onready var magnetism_ray = $Camera3D/MagnetismRay

#Physics Variables
var max_ground_speed: float = 10
var max_air_speed: float = .94
var acceleration: float = 10*max_ground_speed
var jump_strength: float = 10

#Action Variables
var cam_control: bool = true

#Setters

func set_cam_control(val:bool) -> void:
	cam_control = val

#Getters

func get_physics_res() -> CharPhysicsRes:
	return physics_res

func get_weapon():
	if !gun_hand.get_child_count():
		return null
	return gun_hand.get_child(0)

#Functions

func _ready() -> void:
	state_controller.init(self)

func _process(delta) -> void:
	state_controller.process(delta)
	set_aim()
	check_base_interaction()

func set_aim() -> void:
	if !aim_ray.is_colliding():
		print("no collision")
		return
	if get_weapon():
		get_weapon().look_at(aim_ray.get_collision_point())

func check_base_interaction():
	if Input.is_action_just_pressed("Player_Interact"):
		interact()
	if Input.is_action_just_pressed("Player_Throw"):
		drop()
	check_attack()


func interact() -> void:
	if !interact_ray.get_collider():
		return
	
	if interact_ray.get_collider().is_in_group("dropped_weapon"):
		equip_weapon(interact_ray.get_collider().equip())


func drop() ->void:
	if !get_weapon():
		return
	if !get_weapon().is_in_group("DefaultGun"):
		drop_weapon()
		equip_weapon(preload("res://Weapons/Guns/DefaultGun/default_gun.tscn").instantiate())


func check_attack() -> void:
	if !get_weapon():
		return
	if Input.is_action_just_pressed("Player_Attack"):
		get_weapon().attack()
	elif Input.is_action_pressed("Player_Attack"):
		get_weapon().auto_attack()


func equip_weapon(weapon: Node3D):
	if get_weapon():
		if !get_weapon().is_queued_for_deletion():
			drop_weapon()
	
	gun_hand.add_child(weapon)


func drop_weapon():
	var drop_ver = get_weapon().drop()
	
	if !drop_ver:
		return
	
	find_parent("World").add_child(drop_ver)
	
	drop_ver.set_global_transform(get_weapon().get_global_transform())
	drop_ver.apply_impulse(-drop_ver.transform.basis.z*20)


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

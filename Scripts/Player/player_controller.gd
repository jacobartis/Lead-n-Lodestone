extends CharacterBody3D

#Const

const FRICTION = 8

#Variables

#Node References
@onready var state_controller: Node = $StateController
@onready var camera: Camera3D = $Camera3D
@onready var shader: ShaderMaterial = $CanvasLayer/ColorRect.get_material()
@onready var interact_ray = $Camera3D/InteractRay
@onready var aim_ray = $Camera3D/AimRay
@onready var hand = $Camera3D/SubViewportContainer/SubViewport/WeaponCam/Hand
@onready var weapon_cam = $Camera3D/SubViewportContainer/SubViewport/WeaponCam
@onready var magnet_system = $Camera3D/MagnetSystem
@onready var animation_player = $AnimationPlayer

var weapon: Node3D

#Movement Variables
var max_ground_speed: float = 10
var max_air_speed: float = .94
var acceleration: float = 10*max_ground_speed
var jump_strength: float = 3

#Health Variables
var max_health: float = 100
@onready var health: float = get_max_health()

#Energy Variables
var max_energy: float = 5
@onready var energy: float = get_max_energy()
var magnet_cost: float = 2

#Magnetic Variables
var magnetic_bodies: Array = []
var magnet_strength: float = 10
var dash_cost: float = 2.5

#Player strength
var player_strength: float = 20

#Getters

func get_state_controller() -> Node:
	return state_controller

func get_animation_player() -> AnimationPlayer:
	return animation_player

func get_camera() -> Camera3D:
	return camera

func get_weapon() -> Node3D:
	return weapon

func get_max_ground_speed() -> float:
	return max_ground_speed

func get_max_air_speed() -> float:
	return max_air_speed

func get_acceleration() -> float:
	return acceleration

func get_jump_strength() -> float:
	return jump_strength

func get_friction() -> float:
	return FRICTION

func get_max_health() -> float:
	return max_health

func get_health() -> float:
	return health

func get_max_energy() -> float:
	return max_energy

func get_energy() -> float:
	return energy

func get_magnet_cost() -> float:
	return magnet_cost

func get_dash_cost() -> float:
	return dash_cost
#Setters

func set_weapon(value:Node3D) -> void:
	weapon = value

func set_max_ground_speed(value:float) -> void:
	max_ground_speed = value

func set_max_air_speed(value:float) -> void:
	max_air_speed = value

func set_acceleration(value:float) -> void:
	acceleration = value

func set_jump_strength(value:float) -> void:
	jump_strength = value

func set_max_health(value:float) -> void:
	max_health = value

func set_health(value:float) -> void:
	health = value

func set_max_energy(value:float) -> void:
	max_energy = value

func set_energy(value:float) -> void:
	energy = value

#Functions

func _ready() -> void:
	state_controller.init(self)
	#Debug stuff
	for child in hand.get_children():
		if !child is Weapon:
			continue
		call_deferred("pickup_weapon",child)
		return

func _process(delta) -> void:
	state_controller.process(delta)
	weapon_cam.set_transform(camera.get_global_transform())
	set_aim()

func set_aim() -> void:
	if !aim_ray.is_colliding():
		magnet_system.set_aim(Vector3.ZERO)
		return
	magnet_system.set_aim(aim_ray.get_collision_point())
	if !get_weapon():
		return
	get_weapon().set_projectile_spawn_direction(aim_ray.get_collision_point())

func _physics_process(delta) -> void:
	state_controller.physics_process(delta)

func _input(event) -> void:
	state_controller.input(event)

#Handles the player interacting with objects
func interact() -> void:
	if !interact_ray.get_collider():
		return
	if interact_ray.get_collider().is_in_group("Interactable"):
		interact_ray.get_collider().interact(self)
	elif interact_ray.get_collider().is_in_group("Weapon"):
		pickup_weapon(interact_ray.get_collider().get_parent())

#Handles picking up a given weapon, adding it to the players hand
func pickup_weapon(new_weapon:RigidBody3D):
	if !new_weapon is Weapon:
		return
	#Removes previous weapon
	throw_weapon()
	#Equips new weapon
	if new_weapon.get_parent():
		new_weapon.get_parent().remove_child(new_weapon)
	hand.add_child(new_weapon)
	new_weapon.set_global_transform(hand.get_global_transform())
	new_weapon.change_state(WeaponBaseState.State.Player)
	set_weapon(new_weapon)

func throw_weapon(throw_strength:int=player_strength) -> void:
	weapon = get_weapon()
	if !weapon:
		return
	hand.remove_child(weapon)
	find_parent("QodotMap").add_child(weapon)
	weapon.set_global_transform($Camera3D/DropPos.get_global_transform())
	weapon.call_deferred("change_state",WeaponBaseState.State.Unequipped)
	weapon.set_linear_velocity(camera.get_global_position().direction_to(weapon.get_position()).normalized()*throw_strength)
	set_weapon(null)

#Handles calling attack on held weapon
func attack() -> void:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.attack(["Enemy","Weapon"])
		return

#Handles calling auto attack on held weapon
func auto_attack() -> void:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.auto_attack(["Enemy"])
		return

func pull_magnet() -> void:
	magnet_system.pull(magnet_strength)

func push_magnet() -> void:
	magnet_system.push(magnet_strength)

#Handles taking damage
func take_damage(damage) -> void:
	set_health(clamp(get_health()-damage,0,INF))

#Handles healing returns false if the player cant be healed
func heal(heal_quant) -> bool:
	if get_health()==get_max_health():
		return false
	set_health(clamp(get_health()+heal_quant,0,get_max_health()))
	return true

#Signal Functions

func _on_magnet_area_body_entered(body):
	if body.is_in_group("Magnetic"):
		magnetic_bodies.append(body)

func _on_magnet_area_body_exited(body):
	if magnetic_bodies.has(body):
		magnetic_bodies.erase(body)

func _on_auto_pickup_area_entered(area):
	if area.is_in_group("Weapon") and !get_weapon():
#		pickup_weapon(area.get_parent())
		return

func _on_auto_pickup_body_entered(body):
	if body.is_in_group("Collectable"):
		body.collect(self)

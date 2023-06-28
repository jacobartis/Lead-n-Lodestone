extends CharacterBody3D


#Node References

@onready var state_controller = $StateController
@onready var hand: Node = $Hand
@onready var attack_ray = $AttackRay
@onready var navigation = $Navigation

#Variables

@export var stats: Resource

var weapon: Node3D

@onready var health: float = stats.health

var target: Node3D

#Getters

func get_weapon() -> Weapon:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		return child
	return null

func get_attack_ray() -> RayCast3D:
	return attack_ray

func get_target() -> Node3D:
	return target

func is_target_visible() -> bool:
	if !attack_ray.is_colliding():
		return false
	return attack_ray.get_collider() == target

func get_navigation() -> NavigationAgent3D:
	return navigation

func get_stats() -> Resource:
	return stats

func get_health() -> float:
	return health

#Setters

func set_health(value:float) -> void:
	health = value

func set_weapon(value:Node3D) -> void:
	weapon = value

#Functions 

func _ready():
	state_controller.init(self)
	pickup_weapon(stats.get_weapon().instantiate())

func _process(delta):
	state_controller.process(delta)

func _physics_process(delta):
	state_controller.physics_process(delta)

func _input(event):
	state_controller.input(event)

func take_damage(damage) -> void:
	set_health(clamp(get_health()-damage,0,INF))

#Handles picking up a given weapon, adding it to the enemies hand
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
	new_weapon.change_state(WeaponBaseState.State.Enemy)
	set_weapon(new_weapon)

#Handles the enemy throwing their weapon
func throw_weapon(throw_strength:int=stats.throw_strength) -> void:
	weapon = get_weapon()
	if !weapon:
		return
	hand.remove_child(weapon)
	find_parent("QodotMap").add_child(weapon)
	weapon.set_global_transform($Camera3D/DropPos.get_global_transform())
	weapon.call_deferred("change_state",WeaponBaseState.State.Unequipped)
	
	#Throws at an avalible target or just the direction the enemy is facing
	if target:
		weapon.set_linear_velocity(weapon.get_position().direction_to(target.get_global_position()).normalized()*stats.throw_strength)
	else:
		weapon.set_linear_velocity(get_global_position().direction_to(weapon.get_position()).normalized()*stats.throw_strength/2)
	
	set_weapon(null)

func set_weapon_aim() -> void:
	if !attack_ray.is_colliding():
		return
	var weapon = null
	for child in hand.get_children():
		if !child is Weapon:
			continue
		weapon = child
	if !weapon:
		return
	get_weapon().set_projectile_spawn_direction(attack_ray.get_collision_point())

#Signal Functions

func _on_player_detection_body_entered(body):
	if body.is_in_group("Player"):
		target = body.get_camera()

func _on_player_detection_body_exited(body):
	if body == target:
		target = null

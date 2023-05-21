extends RigidBody3D
class_name Weapon

#Constants

const DESPAWN_TIME: float = 3
const PROJ_SPEED: float = 75
const BREAK_SPEED: float = 20

#Node References

@onready var attack_timer: Timer = $AttackCooldown
@onready var reload_timer = $ReloadTimer
@onready var interact_shape: CollisionShape3D = $WeaponInteractArea/CollisionShape3D
@onready var projectile_spawn = $ProjectileSpawn
@onready var state_controller = $StateController
@onready var model = $Model

#Variables

@export var stats: Resource

@onready var ammo: int = stats.get_max_ammo() 

#Setters

func set_ammo(value:int) -> void:
	ammo = value

func change_state(value:WeaponBaseState.State) -> void:
	state_controller.change_state(value)

func set_projectile_spawn_direction(value:Vector3) -> void:
	projectile_spawn.look_at(value)

func set_layer_mask(value: int):
	model.set_layer_mask(1)

#Getters

func get_stats() -> Resource:
	return stats

func is_collectable() -> bool:
	return !interact_shape.is_disabled()

func get_ammo() -> int:
	return ammo

#Functions

func _ready():
	state_controller.init(self)
	set_mass(stats.get_mass())

#Fires the gun repeatedly if is_auto is true
func auto_attack(target_groups:Array) -> void:
	if !stats.is_auto():
		return
	attack(target_groups)

#Handles attacking with the weapon
func attack(target_groups:Array) -> void:
	if !can_attack():
		return
	set_ammo(get_ammo()-1)
	attack_timer.start(1.0/stats.get_fire_rate())
	var proj = stats.get_projectile().instantiate()
	proj.set_position(projectile_spawn.get_global_position())
	proj.set_velocity(projectile_spawn.get_global_transform().basis * Vector3(0,0,-1)* PROJ_SPEED)
	proj.set_target_groups(target_groups)
	proj.set_damage(stats.get_damage())
	find_parent("QodotMap").add_child(proj)

#Returns if the weapon can fire
func can_attack() -> bool:
	return !attack_timer.get_time_left() and get_ammo()

func reload() -> void:
	if reload_timer.get_time_left() > 0:
		return
	reload_timer.start(stats.get_reload_time())

func pull(pos:Vector3,strength:float):
	set_linear_velocity(get_position().direction_to(pos).normalized()*strength)

func push(pos:Vector3,strength:float):
	apply_central_impulse(pos.direction_to(get_position()).normalized()*strength)

#Signal Functions

func _on_body_entered(body) -> void:
	handle_collision(body)

#Handles doing damage with thrown weapons
func handle_collision(body):
	if body.is_in_group("Enemy") and get_linear_velocity().length() > 2:
		body.take_damage(get_mass()*get_linear_velocity().length() + stats.get_thrown_damage())
	
	if get_linear_velocity().length()>BREAK_SPEED:
		call_deferred("queue_free")

func _on_reload_timer_timeout():
	set_ammo(get_stats().get_max_ammo())

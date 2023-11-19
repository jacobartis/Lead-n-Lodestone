extends EquipedWeapon

#Signals

signal attract_time_update(at)

#Node references

@onready var aim_ray = $AimRay
@onready var default = $AimRay/Default
@onready var m_range = $MagnetRange

#Variables

var attract_time: float

var neg_pol: bool = false
var active: bool = false
var mag_bodies: Array[RigidBody3D] 

#Setters

func set_active(val: bool) -> void:
	active = val and can_attack()


func set_polarity(val: bool) -> void:
	neg_pol = val and active

#Getters

func get_polarity() -> bool:
	return neg_pol

#Functions

func _ready():
	attract_time = stats.attract_time

func _process(delta):
	if neg_pol and active:
		attract_time -= delta*2
#
#	if attract_time <= 0:
#		start_cooldown()
	attract_time = clamp(attract_time+delta,0,stats.attract_time)

func _physics_process(delta):
	if !active:
		return
	
	m_range.set_global_position(get_magnet_point())
	
	if neg_pol:
		repel()
	else:
		attract()

func attract():
	for body in mag_bodies:
		var dist = body.global_position.distance_squared_to(m_range.global_position)
		var force
		
		#Keeps all magnetic objects in the center using a parabola curve
		if dist < .5:
			#When too close, the force is reduced the closer to the center
			force = stats.strength*(body.global_position.distance_squared_to(m_range.global_position))
		else:
			#When far, the force increases when closer to the center
			force = stats.strength*(1.0/body.global_position.distance_squared_to(m_range.global_position))
		
		body.set_linear_velocity(force*body.global_position.direction_to(m_range.global_position))

func repel():
	for body in mag_bodies:
		var force = stats.strength
		body.apply_impulse(force*body.global_position.direction_to(global_transform.basis.z*-100))
	set_polarity(false)
	start_cooldown()

#Gets the point of the magnatisms origin
func get_magnet_point() -> Vector3:
	if !aim_ray.is_colliding():
		return default.get_global_position()
	#Returns the point of collision if the default would be behind a wall
	return aim_ray.get_collision_point()

#Overridden Functions

func start_cooldown():
	ac_timer.start(stats.attack_speed)
	set_active(false)

#Signal functions

func _on_magnet_range_body_entered(body):
	if body.is_in_group("magnetic"):
		mag_bodies.append(body)


func _on_magnet_range_body_exited(body):
	if !body is RigidBody3D:
		return
	if body in mag_bodies:
		mag_bodies.erase(body)

extends Node

@export var weapon: PackedScene

signal value_update(type:String,value)
signal speed_update(speed)
signal type_update(type:String)

var type = [
	"mag_strength",
	"Test"
]

var current: int = 0

func _ready():
	emit_signal("type_update",type[current])
	emit_signal("value_update",type[current],get_parent().magnet_strength)

func _process(delta):
	if Input.is_action_just_pressed("Debug_Spawn_Weapon"):
		get_parent().pickup_weapon(weapon.instantiate())
	emit_signal("speed_update",get_parent().get_velocity().length())
	get_parent().set_energy(99)
	check_type_change()
	check_value_change()

func check_type_change():
	if Input.is_action_just_pressed("Debug_Type_Forward"):
		current = (current+1)%type.size()
	elif Input.is_action_just_pressed("Debug_Type_Backward"):
		current = (current-1)%type.size()
	else:
		return
	emit_signal("type_update",type[current])

func check_value_change():
	var value: bool
	if Input.is_action_just_pressed("Debug_Up"):
		value = true
	elif Input.is_action_just_pressed("Debug_Down"):
		value = false
	else:
		return
	
	match current:
		0:
			mag_strength(value)
		_:
			print("Try as you might, nothing was changed.")
			return

func mag_strength(increase:bool) -> void:
	if increase:
		get_parent().magnet_strength = clamp(get_parent().magnet_strength+.5,0,INF)
		emit_signal("value_update",type[current],get_parent().magnet_strength)
	else:
		get_parent().magnet_strength = clamp(get_parent().magnet_strength-.5,0,INF)
		emit_signal("value_update",type[current],get_parent().magnet_strength)

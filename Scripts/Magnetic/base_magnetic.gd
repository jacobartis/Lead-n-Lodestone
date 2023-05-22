extends Node
#Base class for magnetic objects
class_name magnetic

@onready var body = get_parent()

#Adds the body to the magnetic group and sets their magnetic node to this
func _ready():
	body.set_magnetic_node(self)
	body.add_to_group("Magnetic")

#Base function for pull
func pull(pos:Vector3,strength:float):
	print(pos, strength)

#Base function for push
func push(pos:Vector3,strength:float):
	print(pos, strength)

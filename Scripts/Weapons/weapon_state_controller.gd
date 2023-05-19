extends WeaponBaseState

#Variables 

#Dictionary of all avalible state nodes
@onready var States = {
	WeaponBaseState.State.Unequipped: $Unequipped,
	WeaponBaseState.State.Player: $Player,
	WeaponBaseState.State.Enemy: $Enemy
}

#Stores current and previous state nodes
var current_state: WeaponBaseState
var prev_state: WeaponBaseState

#Stores current and previous state dict refrences
var current_state_dict: WeaponBaseState.State
var prev_state_dict: WeaponBaseState.State

#Getters

#Returns current state
func get_state() -> WeaponBaseState:
	return current_state

#Returns previous state
func get_prev_state() -> WeaponBaseState:
	return prev_state

#Functions

#Initialises all child states
func init(value:RigidBody3D, sc_value:Node = null) -> void:
	body = value
	
	for child in get_children():
		if child is WeaponBaseState:
			child.init(value,self)
	
	change_state(WeaponBaseState.State.Unequipped)

#Handles running process in current state and reciving new states 
func process(delta) -> void:
	
	if !current_state:
		return
	
	var new_state = current_state.process(delta)
	
	if new_state:
		change_state(new_state)

#Runs the current states physics processes
func physics_process(delta) -> void:
	if !current_state:
		return
	current_state.physics_process(delta)

#Runs input for the current state
func input(event) -> void:
	if !current_state:
		return
	current_state.input(event)

#Exits current state and enters given state
func change_state(new_state) -> void:
	
	if current_state:
		current_state.exit()
	
	prev_state = current_state
	prev_state_dict = current_state_dict
	
	current_state = States[new_state]
	current_state_dict = new_state
	current_state.enter()

extends PlayerBaseState

#Signals

signal state_change(prev_state,new_state)

#Variables 

#Dictionary of all avalible state nodes
@onready var States = {
	PlayerBaseState.State.Idle: $Idle,
	PlayerBaseState.State.Walking: $Walking,
	PlayerBaseState.State.Jumping: $Jumping,
	PlayerBaseState.State.Falling: $Falling,
	PlayerBaseState.State.Dead: $Dead
}

#Stores current and previous state nodes
var current_state: PlayerBaseState
var prev_state: PlayerBaseState 

#Getters

func get_state_name(state:PlayerBaseState) -> String:
	if !state:
		return ""
	return state.get_name()

#Functions

func init(value:CharacterBody3D, sc_value:Node = null) -> void:
	body = value
	#initialises all child states
	for child in get_children():
		if child is PlayerBaseState:
			child.init(value,self)
	
	#Enters idle state
	change_state(PlayerBaseState.State.Idle)

#Runs state process and gets the next state
func process(delta) -> void:
	
	if !current_state:
		return
	
	var new_state = current_state.process(delta)
	
	if new_state:
		change_state(new_state)

#Runs state physics
func physics_process(delta) -> void:
	if !current_state:
		return
	current_state.physics_process(delta)

#Enters a new given state
func change_state(new_state) -> void:
	if current_state == States[PlayerBaseState.State.Dead]:
		return
	
	if current_state:
		current_state.exit()
	
	prev_state = current_state
	current_state = States[new_state]
	
	emit_signal("state_change",get_state_name(prev_state),get_state_name(current_state))
	
	current_state.enter()

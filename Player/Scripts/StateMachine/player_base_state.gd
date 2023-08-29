extends Node
class_name PlayerBaseState

#Enums

#Enum of all states
enum State{
	None,
	Idle,
	Walking,
	Jumping,
	Falling,
	Dead
}

#Variables

var body: CharacterBody3D
var state_controler: Node

#Functions

#Takes the value of the body being controled and can take a state controller value
func init(body_value:CharacterBody3D, sc_value:Node = null) -> void:
	body = body_value
	state_controler = sc_value

#Ran when first entering the state
func enter() -> void:
	pass

#Ran when leaving the state
func exit() -> void:
	pass

func process(delta):
	return PlayerBaseState.State.None

func physics_process(delta) -> void:
	pass

func input(event) -> void:
	pass

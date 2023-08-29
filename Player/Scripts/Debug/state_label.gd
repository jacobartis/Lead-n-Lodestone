extends Label


func _on_player_state_controller_state_change(prev_state, new_state):
	set_text(str("Prev state: ",prev_state," Current state: ",new_state))

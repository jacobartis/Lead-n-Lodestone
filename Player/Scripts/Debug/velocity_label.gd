extends Label



func _on_player_velocity_update(velocity:Vector3):
	set_text(str("Velocity: ",velocity, " Speed: ",velocity.length()))

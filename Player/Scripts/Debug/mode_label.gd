extends Label

func _on_player_mode_update(mode):
	set_text(str("Mode:", mode))

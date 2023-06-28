extends Label



func _on_debug_value_update(type, value):
	set_text(str(type,": ",value))

extends Label


func _on_debug_type_update(type):
	set_text(str("Current : ",type))

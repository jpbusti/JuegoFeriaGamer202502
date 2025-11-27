extends Area2D

signal close_success
signal close_fail


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if viewport.is_input_handled():
			return
			
		viewport.set_input_as_handled()
		
		emit_signal("close_fail")

func _on_close_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		viewport.set_input_as_handled()
		
		emit_signal("close_success")
		queue_free()

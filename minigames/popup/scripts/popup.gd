extends Area2D

signal close_success
signal close_fail

# ¡Ya no necesitamos la función set_texture!
# La textura se asigna directamente en el editor de cada escena.

# Esta función se llama cuando se hace clic en el CUERPO del pop-up
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("close_fail")

# Esta función se llama cuando se hace clic en la "X"
func _on_close_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("close_success")
		queue_free()

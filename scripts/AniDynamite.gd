extends AnimatedSprite2D

func _ready():
	connect("animation_finished", Callable(self, "_on_animation_finished"))
	set_process_input(true)

func _input(event):
	# Detecta clic izquierdo sobre el sprite (si tiene CollisionShape2D y Pickable activo)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_playing():
			play("press")

func _on_animation_finished():
	frame = 0
	stop()

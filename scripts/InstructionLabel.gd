extends CanvasLayer

signal finished

@onready var label = $Label
@onready var background = $ColorRect

func show_message(text: String, duration: float = 1.5):
	label.text = text
	
	label.scale = Vector2(0, 0)
	label.pivot_offset = label.size / 2 
	background.modulate.a = 0
	
	var t = create_tween()
	t.set_parallel(true)
	t.tween_property(background, "modulate:a", 0.8, 0.2)
	t.tween_property(label, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(duration).timeout
	
	var t_out = create_tween()
	t_out.set_parallel(true)
	t_out.tween_property(label, "scale", Vector2(2, 0), 0.2).set_ease(Tween.EASE_IN) 
	t_out.tween_property(self, "modulate:a", 0, 0.2)
	
	await t_out.finished
	emit_signal("finished")
	queue_free()

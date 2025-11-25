extends CanvasLayer

@onready var progress_bar = $SecurityBar

func _ready():
	Global.score_updated.connect(update_bar)
	
	progress_bar.max_value = 25
	progress_bar.value = Global.score
	
	visible = true

func update_bar(new_score):
	var t = create_tween()
	t.tween_property(progress_bar, "value", new_score, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	if new_score >= 20:
		progress_bar.modulate = Color(0, 1, 0) 
	elif new_score >= 10:
		progress_bar.modulate = Color(1, 1, 0) 
	else:
		progress_bar.modulate = Color(1, 1, 1) 

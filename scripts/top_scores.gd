extends Control

@onready var score_list: VBoxContainer = $Panel/ScoreList
@onready var back_button: Button = $Panel/BackButton
@onready var title_label: Label = $Panel/TitleLabel

func _ready() -> void:
	load_scores()
	back_button.text = "Volver al Menú"
	back_button.pressed.connect(_on_back_pressed)

func load_scores():
	# limpiar hijos anteriores
	for child in score_list.get_children():
		child.queue_free()

	# obtener puntajes desde ScoreManager
	var scores = ScoreManager.scores

	if scores.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No hay puntajes guardados aún."
		empty_label.add_theme_color_override("font_color", Color(1, 1, 0))
		score_list.add_child(empty_label)
	else:
		for i in range(scores.size()):
			var entry = scores[i]
			var label = Label.new()
			label.text = "%d. %s - %d pts" % [i + 1, entry["name"], entry["score"]]
			label.add_theme_color_override("font_color", Color(1, 1, 1))
			score_list.add_child(label)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

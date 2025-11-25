extends Control

@onready var score_list: VBoxContainer = $Panel/ScoreList
@onready var back_button: Button = $Panel/BackButton
@onready var title_label: Label = $Panel/TitleLabel

var font_ref = preload("res://assets/contraseña/fonts/BoldPixels.ttf")

func _ready() -> void:
	title_label.text = "TOP HACKERS"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_override("font", font_ref)
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.add_theme_color_override("font_color", Color("00ff00")) 
	
	load_scores()
	
	back_button.text = "VOLVER AL SISTEMA"
	back_button.pressed.connect(_on_back_pressed)

func load_scores():
	for child in score_list.get_children():
		child.queue_free()

	var scores = ScoreManager.scores

	if scores.is_empty():
		var empty_label = Label.new()
		empty_label.text = "BASE DE DATOS VACÍA..."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_override("font", font_ref)
		empty_label.add_theme_color_override("font_color", Color.GRAY)
		score_list.add_child(empty_label)
	else:
		for i in range(scores.size()):
			var entry = scores[i]
			var label = Label.new()
			
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_override("font", font_ref)
			
			var rank_text = ""
			var color = Color.WHITE
			var size = 32 
			
			match i:
				0: 
					rank_text = "1ST"
					color = Color("FFD700") 
					size = 56 
				1: 
					rank_text = "2ND"
					color = Color("C0C0C0") 
					size = 48 
				2: 
					rank_text = "3RD"
					color = Color("CD7F32") 
					size = 42 
				_:
					rank_text = "%d." % (i + 1)
					color = Color("00FF00") 
					size = 32
			
			label.text = "%s  %s ..... %d PTS" % [rank_text, entry["name"], entry["score"]]
			label.add_theme_color_override("font_color", color)
			label.add_theme_font_size_override("font_size", size)
			
			label.add_theme_color_override("font_shadow_color", Color.BLACK)
			label.add_theme_constant_override("shadow_offset_x", 2)
			label.add_theme_constant_override("shadow_offset_y", 2)
			
			score_list.add_child(label)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

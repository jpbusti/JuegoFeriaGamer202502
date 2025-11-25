extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var score_label: Label = $CenterContainer/VBoxContainer/FinalScoreLabel
@onready var info_label: Label = $CenterContainer/VBoxContainer/InfoLabel
@onready var name_input: LineEdit = $CenterContainer/VBoxContainer/NameInput


var game_over_sound = preload("res://assets/assetsgenerales/Game over.mp3")
var audio_player: AudioStreamPlayer



func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = game_over_sound
	add_child(audio_player)
	audio_player.play()
	
	score_label.text = "Puntuacion final: " + str(Global.score)
	
	if info_label:
		var data = {}
		if "last_terminal_data" in Global and not Global.last_terminal_data.is_empty():
			data = Global.last_terminal_data
		elif "cyber_dictionary" in Global and not Global.cyber_dictionary.is_empty():
			data = Global.cyber_dictionary.pick_random()
			
		if not data.is_empty():
			# Usamos BBCode o texto plano con saltos de línea
			info_label.text = "--- DATO CIBERNETICO ---\n\n" + str(data["word"]) + ":\n" + str(data["def"])
			info_label.modulate = Color(0.5, 1, 0.5) # Verde claro
		else:
			info_label.text = "¡Sigue intentándolo!"

	# 4. Input
	name_input.text_submitted.connect(_on_name_submitted)
	name_input.grab_focus()

func _on_name_submitted(new_text: String):
	if new_text.strip_edges() == "": return 
	ScoreManager.add_score(new_text, Global.score)
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

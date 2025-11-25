extends Node2D

@onready var score_label: Label = $FinalScoreLabel
@onready var name_input: LineEdit = $NameInput
@onready var info_label = $InfoLabel 

var game_over_sound = preload("res://assets/assetsgenerales/Game over.mp3")
var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = game_over_sound
	add_child(audio_player)
	audio_player.play()
	
	score_label.text = "Puntuacion final: " + str(Global.score)
	
	if info_label:
		info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART 
		info_label.custom_minimum_size.x = 800 
		info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER 
		var data_to_show = {}
		
		if "last_terminal_data" in Global and not Global.last_terminal_data.is_empty():
			data_to_show = Global.last_terminal_data
		
		elif "cyber_dictionary" in Global and not Global.cyber_dictionary.is_empty():
			data_to_show = Global.cyber_dictionary.pick_random()
		
		if not data_to_show.is_empty():
			info_label.text = "DATO: " + str(data_to_show["word"]) + "\n\n" + str(data_to_show["def"])
			info_label.modulate = Color(0.5, 1, 0.5)
		else:
			info_label.text = "¡Inténtalo de nuevo!"
	
	name_input.text_submitted.connect(_on_name_submitted)
	name_input.grab_focus()

func _on_name_submitted(new_text: String):
	if new_text.strip_edges() == "":
		return 
	
	ScoreManager.add_score(new_text, Global.score)
	print("Guardando score para: ", new_text)
	
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

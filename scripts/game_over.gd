extends Node2D

@onready var score_label: Label = $FinalScoreLabel
@onready var name_input: LineEdit = $NameInput 

func _ready():
	# Mostramos el puntaje
	score_label.text = "Puntuacion final:   " + str(Global.score)

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

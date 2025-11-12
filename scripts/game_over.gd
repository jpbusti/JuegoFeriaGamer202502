extends Node2D

@onready var score_label: Label = $FinalScoreLabel

func _ready():
	score_label.text = "Puntuación final: " + str(Global.score)
	printerr("💀 GAME OVER - Score: " + str(Global.score))
	
	# Guardar puntaje
	var player_name = "Jugador"
	if Engine.has_singleton("ScoreManager"):
		ScoreManager.add_score(player_name, Global.score)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

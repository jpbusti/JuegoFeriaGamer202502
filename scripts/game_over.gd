extends Node2D

@onready var score_label: Label = $FinalScoreLabel

func _ready():
	score_label.text = "Tu puntuación final: " + str(Global.score)
	print("💀 GAME OVER - Score final:", Global.score)
	
	# Guardar automáticamente el puntaje
	var player_name = "Jugador"
	ScoreManager.add_score(player_name, Global.score)
	print("💾 Score guardado en ScoreManager.")
	
	print("Presiona Enter para volver al menú.")

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

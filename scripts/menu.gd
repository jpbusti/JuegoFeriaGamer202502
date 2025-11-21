extends Control

@onready var play_button = $VBoxContainer/Jugar

func _ready():
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
# 1. Ocultar el menú (o cambiar a una escena vacía)
	# Si cambias de escena, el menú desaparece
	get_tree().change_scene_to_file("res://scenes/MAIN_SCENE.tscn") 
	
	GameManager.start_game()

func _on_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/top_scores.tscn") 


func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Inicio.tscn") 

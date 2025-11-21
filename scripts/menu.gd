extends Control

@onready var play_button = $VBoxContainer/Jugar

func _ready():
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	GameManager.play_ui_sound()

	GameManager.stop_music()
	
	get_tree().change_scene_to_file("res://scenes/MAIN_SCENE.tscn") 
	GameManager.start_game()

func _on_scores_pressed() -> void:
	GameManager.play_ui_sound()
	get_tree().change_scene_to_file("res://scenes/top_scores.tscn") 

func _on_salir_pressed() -> void:
	GameManager.play_ui_sound()
	get_tree().change_scene_to_file("res://scenes/Inicio.tscn")

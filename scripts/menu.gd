extends Control

@onready var play_button = $VBoxContainer/Jugar

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	print("🎮 MENU: _ready() ejecutado")
	printerr("🔴 MENU: printerr ejecutado")

func _on_play_pressed() -> void:
	Global.reset()
	print("🎯 BOTÓN JUGAR: Presionado")
	printerr("🔴 BOTÓN JUGAR: Presionado")
	
	get_tree().change_scene_to_file("res://scenes/GameManager.tscn")

func _on_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/top_scores.tscn")

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Inicio.tscn")

extends Control

@onready var play_button = $VBoxContainer/Jugar

func _ready():
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	printerr("🎯 Botón Jugar presionado")
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn") 

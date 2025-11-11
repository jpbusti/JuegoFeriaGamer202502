extends Control

@onready var play_button = $VBoxContainer/Jugar

func _ready():
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/score_scene.tscn")

func _on_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/top_scores.tscn")

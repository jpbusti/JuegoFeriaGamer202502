extends Node2D

@onready var anim = $AnimatedSprite2D

func _ready():
	if anim:
		anim.play("press_start")
	

	GameManager.play_music()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false) 
		GameManager.play_ui_sound()
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

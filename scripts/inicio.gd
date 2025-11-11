extends Node2D

@onready var anim = $AnimatedSprite2D

func _ready():
	if anim:
		anim.play("press_start")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

# main_scene.gd
extends Node2D

@onready var minigame_container = $MinijuegoContainer

func _ready():
	
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("setup_minigame_container"):
		game_manager.setup_minigame_container(minigame_container)
	
	if minigame_container.get_child_count() > 0:
		for child in minigame_container.get_children():
			child.queue_free()
	
	if game_manager and game_manager.has_method("start_first_minigame"):
		game_manager.start_first_minigame()

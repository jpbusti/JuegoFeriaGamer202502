extends Node2D

func _ready():
	printerr("🏠 MainScene iniciada - Contenedor de minijuegos")
	
	# Iniciar primer minijuego a través del GameManager
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("start_first_minigame"):
		game_manager.start_first_minigame()

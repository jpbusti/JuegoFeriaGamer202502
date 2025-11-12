extends Node

var current_minigame_path: String = ""
var game_active: bool = true

func _ready():
	printerr("🚀 GameManager Autoload iniciado")
	randomize()

func start_first_minigame():
	printerr("🎮 Iniciando primer minijuego")
	game_active = true
	start_random_minigame()

func start_random_minigame():
	if not game_active:
		return
	
	var minigame_paths = [
		"res://minigames/buttonsmasher/button_masher.tscn",
		"res://minigames/presionar/mini_juego_tiempo.tscn", 
		"res://minigames/saltar/saltar.tscn"
	]
	
	# Elegir minijuego aleatorio
	var random_index = randi() % minigame_paths.size()
	current_minigame_path = minigame_paths[random_index]
	
	printerr("📁 Cargando: " + current_minigame_path)
	get_tree().change_scene_to_file(current_minigame_path)

func process_minigame_result(won: bool):
	printerr("🎯 Resultado: " + ("GANÓ" if won else "PERDIÓ"))
	
	if won:
		Global.score += 1
		printerr("⭐ Score: " + str(Global.score))
		# Transición directa al siguiente minijuego
		start_random_minigame()
	else:
		printerr("💀 Game Over")
		game_over()

func game_over():
	# Guardar puntaje
	var player_name = "Jugador"
	if Engine.has_singleton("ScoreManager"):
		ScoreManager.add_score(player_name, Global.score)
	
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

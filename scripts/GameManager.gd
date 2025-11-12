extends Node

var minigame_paths = [
	"res://minigames/buttonsmasher/button_masher.tscn",
	"res://minigames/presionar/mini_juego_tiempo.tscn", 
	"res://minigames/saltar/saltar.tscn"
]

var current_minigame: Node = null
var transition_active: bool = false
var game_active: bool = true
var minigame_processed: bool = false  # Evitar procesamiento doble

func _ready():
	printerr("🚀 GameManager Autoload iniciado")
	randomize()

func start_first_minigame():
	printerr("🎮 Iniciando primer minijuego")
	game_active = true
	transition_active = false
	minigame_processed = false
	load_and_start_minigame()

func load_and_start_minigame():
	if not game_active: 
		return
	
	# Limpiar minijuego anterior si existe
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
	
	var random_index = randi() % minigame_paths.size()
	var minigame_path = minigame_paths[random_index]
	
	printerr("📁 Cargando minijuego: " + minigame_path)
	
	# Cargar minijuego
	var minigame_scene = load(minigame_path)
	if minigame_scene:
		current_minigame = minigame_scene.instantiate()
		get_tree().current_scene.add_child(current_minigame)
		
		# Iniciar minijuego
		if current_minigame.has_method("start_game"):
			current_minigame.start_game()
		elif current_minigame.has_method("reset_game"):
			current_minigame.reset_game()
	else:
		printerr("❌ Error cargando minijuego")
		game_over()

func process_minigame_result(won: bool):
	# EVITAR PROCESAMIENTO DOBLE
	if minigame_processed:
		printerr("⚠️ Resultado ya procesado, ignorando...")
		return
	
	minigame_processed = true
	printerr("🎯 Resultado: " + ("GANÓ" if won else "PERDIÓ"))
	
	if won:
		Global.score += 1
		printerr("⭐ Score: " + str(Global.score))
		start_transition_to_next()
	else:
		game_over()

func start_transition_to_next():
	if transition_active: 
		return
	transition_active = true
	
	printerr("🔄 Iniciando transición rápida...")
	
	# Crear escena de transición sobre el minijuego actual
	var transition_scene = preload("res://scenes/transition_scene.tscn").instantiate()
	get_tree().current_scene.add_child(transition_scene)

func complete_transition():
	printerr("✅ Transición completada - Cargando siguiente minijuego")
	transition_active = false
	minigame_processed = false
	load_and_start_minigame()

func game_over():
	printerr("💀 Game Over - Score: " + str(Global.score))
	game_active = false
	transition_active = false
	minigame_processed = false
	
	# Guardar puntaje
	var player_name = "Jugador"
	if Engine.has_singleton("ScoreManager"):
		ScoreManager.add_score(player_name, Global.score)
	
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

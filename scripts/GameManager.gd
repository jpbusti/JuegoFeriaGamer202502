# GameManager.gd - REEMPLAZA TODO EL SCRIPT
extends Node

var minigame_paths = [
	"res://minigames/buttonsmasher/scenes/MainButtonMasher.tscn",
	"res://minigames/contraseña/scenes/MainContraseña.tscn",
	"res://minigames/popup/scenes/PopupMain.tscn",
	"res://minigames/presionar/scenes/MainPresionar.tscn",
	"res://minigames/saltar/scenes/MainSaltar.tscn"

]

var current_minigame: Node = null
var current_minigame_path: String = ""
var transition_active: bool = false
var game_active: bool = true
var minigame_processed: bool = false

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
	
	printerr("🔄 Cargando nuevo minijuego...")
	
	# LIMPIEZA EXTREMA - ELIMINAR TODO
	cleanup_everything()
	
	# Pequeña pausa para asegurar limpieza
	await get_tree().create_timer(0.2).timeout
	
	# ELEGIR MINIJUEGO ALEATORIO
	var available_paths = minigame_paths.duplicate()
	
	# Evitar repetir el mismo minijuego consecutivo
	if current_minigame_path and available_paths.size() > 1:
		available_paths.erase(current_minigame_path)
	
	var random_index = randi() % available_paths.size()
	var minigame_path = available_paths[random_index]
	current_minigame_path = minigame_path
	
	printerr("🎲 Minijuego seleccionado: " + minigame_path)
	
	# Verificar que la ruta existe
	if not ResourceLoader.exists(minigame_path):
		printerr("❌ ERROR: La ruta no existe: " + minigame_path)
		game_over()
		return
	
	# CARGAR NUEVO MINIJUEGO
	var minigame_scene = load(minigame_path)
	if minigame_scene and minigame_scene is PackedScene:
		current_minigame = minigame_scene.instantiate()
		get_tree().current_scene.add_child(current_minigame)
		printerr("✅ Minijuego añadido: " + current_minigame.name)
	else:
		printerr("❌ Error: No es una escena válida: " + minigame_path)
		game_over()

func cleanup_everything():
	printerr("💥 LIMPIEZA EXTREMA - ELIMINANDO TODO...")
	
	var scene_root = get_tree().current_scene
	var deleted_count = 0
	
	# ELIMINAR TODOS los nodos que no sean esenciales
	for child in scene_root.get_children():
		# Mantener solo estos nodos esenciales
		if child.name in ["Background", "UI", "HUD", "TransitionLayer"]:
			continue
			
		printerr("🗑️ ELIMINANDO: " + child.name)
		child.queue_free()
		deleted_count += 1
	
	# Asegurar que current_minigame se libera
	if current_minigame and is_instance_valid(current_minigame):
		printerr("🗑️ ELIMINANDO current_minigame: " + current_minigame.name)
		current_minigame.queue_free()
		current_minigame = null
	
	printerr("✅ Limpieza completada. " + str(deleted_count) + " nodos eliminados.")

func process_minigame_result(won: bool):
	printerr("🔄 GameManager procesando resultado: " + ("GANÓ" if won else "PERDIÓ"))
	
	# EVITAR PROCESAMIENTO DOBLE
	if minigame_processed:
		printerr("⚠️ Resultado ya procesado, ignorando...")
		return
	
	minigame_processed = true
	
	if won:
		Global.score += 1
		printerr("⭐ Nuevo score: " + str(Global.score))
		start_transition_to_next()
	else:
		game_over()

func start_transition_to_next():
	if transition_active: 
		return
	transition_active = true
	
	printerr("🎭 Iniciando transición...")
	
	# Limpiar ANTES de la transición
	cleanup_everything()
	
	# Crear escena de transición
	var transition_scene = preload("res://scenes/transition_scene.tscn").instantiate()
	get_tree().current_scene.add_child(transition_scene)

func complete_transition():
	printerr("✅ Transición completada")
	transition_active = false
	minigame_processed = false
	load_and_start_minigame()

func game_over():
	printerr("💀 Game Over - Score: " + str(Global.score))
	game_active = false
	transition_active = false
	minigame_processed = false
	
	# Limpiar antes del game over
	cleanup_everything()
	
	# Guardar puntaje
	var player_name = "Jugador"
	if Engine.has_singleton("ScoreManager"):
		ScoreManager.add_score(player_name, Global.score)
	
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

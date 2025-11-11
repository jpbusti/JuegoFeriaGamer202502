extends Node

var current_minigame_path: String = ""
var minigame_result: bool = false
var game_active: bool = true
var transition_in_progress: bool = false

# Referencias al TransitionLayer de la escena
var transition_layer: CanvasLayer = null
var anim: AnimationPlayer = null

func _ready() -> void:
	print("🚀 GameManager Autoload iniciado")
	randomize()

func setup_transition_layer(layer: CanvasLayer, animation_player: AnimationPlayer) -> void:
	transition_layer = layer
	anim = animation_player
	print("✅ TransitionLayer configurado en Autoload")

func start_first_minigame() -> void:
	print("🎮 Iniciando primer minijuego desde GameManager")
	game_active = true
	transition_in_progress = false
	start_random_minigame()

func start_random_minigame() -> void:
	if not game_active:
		print("❌ Game no active")
		return
	if transition_in_progress:
		print("❌ Transition in progress")
		return
	
	print("🔄 Seleccionando nuevo minijuego...")
	
	var minigame_paths = [
		"res://minigames/buttonsmasher/button_masher.tscn",
		"res://minigames/presionar/mini_juego_tiempo.tscn", 
		"res://minigames/saltar/saltar.tscn"
	]
	
	# Verificar que las rutas existen
	for path in minigame_paths:
		if not ResourceLoader.exists(path):
			print("❌ Ruta no existe: ", path)
	
	# Elegir minijuego aleatorio
	var available_paths = minigame_paths.duplicate()
	if available_paths.size() > 1 and current_minigame_path != "":
		available_paths.erase(current_minigame_path)
	
	if available_paths.is_empty():
		available_paths = minigame_paths
	
	var random_index = randi() % available_paths.size()
	current_minigame_path = available_paths[random_index]
	
	print("📁 Cargando: ", current_minigame_path)
	
	# Cargar el minijuego como escena principal
	var result = get_tree().change_scene_to_file(current_minigame_path)
	print("📊 Resultado cambio de escena: ", result)

func process_minigame_result(won: bool) -> void:
	print("🎯 GameManager.process_minigame_result llamado - Ganó: ", won)
	
	if transition_in_progress:
		print("❌ Transición ya en progreso")
		return
	
	minigame_result = won
	transition_in_progress = true
	
	if won:
		Global.score += 1
		print("⭐ Score: ", Global.score)
		# Transición al siguiente minijuego
		transition_to_next_minigame()
	else:
		print("💀 Perdió - Yendo a Game Over")
		# Game over directamente
		game_over()

func transition_to_next_minigame() -> void:
	print("🔄 Iniciando transición con cortinas...")
	
	if transition_layer == null:
		print("❌ transition_layer es null")
	if anim == null:
		print("❌ anim es null")
	
	if transition_layer and anim:
		print("✅ TransitionLayer y AnimationPlayer encontrados")
		
		if anim.has_animation("curtains_close"):
			print("✅ Animación 'curtains_close' encontrada")
			
			# CONGELAR el juego durante transición
			get_tree().paused = true
			print("⏸️ Juego pausado")
			
			# 1. Cerrar cortinas
			anim.play("curtains_close")
			print("🎬 Reproduciendo curtains_close")
			await anim.animation_finished
			print("✅ curtains_close completada")
			
			# 2. Pequeña pausa con cortinas cerradas
			await get_tree().create_timer(0.3).timeout
			
			# 3. Cargar siguiente minijuego mientras cortinas cerradas
			start_random_minigame()
			
			# 4. Abrir cortinas para revelar nuevo minijuego
			anim.play("curtains_open")
			print("🎬 Reproduciendo curtains_open")
			await anim.animation_finished
			print("✅ curtains_open completada")
			
			# 5. Descongelar juego
			get_tree().paused = false
			print("▶️ Juego reanudado")
			
			transition_in_progress = false
		else:
			print("❌ Animación 'curtains_close' NO encontrada")
	else:
		print("⚠ No hay TransitionLayer - Transición directa")
		# Fallback: transición directa
		await get_tree().create_timer(1.0).timeout
		start_random_minigame()
		transition_in_progress = false

func game_over() -> void:
	print("💀 Game Over - Score final: ", Global.score)
	game_active = false
	transition_in_progress = false
	
	# Guardar puntaje
	var player_name = "Jugador"
	if Engine.has_singleton("ScoreManager"):
		ScoreManager.add_score(player_name, Global.score)
	
	# Ir a escena game_over
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

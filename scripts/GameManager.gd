extends Node

# --- CONFIGURACIÓN ---
var minigame_paths: Array[String] = [
	"res://minigames/buttonsmasher/scenes/MainButtonMasher.tscn",
	"res://minigames/contraseña/scenes/MainContraseña.tscn",
	"res://minigames/popup/scenes/PopupMain.tscn",
	"res://minigames/presionar/scenes/MainPresionar.tscn",
	"res://minigames/saltar/scenes/MainSaltar.tscn"
]

var transition_path: String = "res://scenes/transition_scene.tscn"
var game_over_scene_path: String = "res://scenes/game_over.tscn" # Ruta a tu escena de Game Over

var current_game_instance: Node = null
var is_game_active: bool = false

func _ready():
	pass

func start_game():
	print("🚀 Iniciando partida...")
	Global.reset() # Reiniciamos puntos y estado de derrota
	is_game_active = true
	game_loop()

func stop_game():
	is_game_active = false
	if current_game_instance:
		current_game_instance.queue_free()
		current_game_instance = null

func game_loop():
	while is_game_active:
		if minigame_paths.is_empty():
			printerr("❌ ERROR: Lista de juegos vacía")
			break
			
		var random_path = minigame_paths.pick_random()
		var game_scene = load(random_path)
		
		if game_scene:
			await play_minigame(game_scene)
		else:
			await get_tree().create_timer(1.0).timeout

func play_minigame(game_scene: PackedScene):
	print("\n🎬 --- NUEVO MINIJUEGO ---")
	
	# 1. RESETEAR ESTADO DE DERROTA AL INICIO DE LA RONDA
	Global.round_failed = false 
	
	# 2. INSTANCIAR JUEGO
	current_game_instance = game_scene.instantiate()
	get_tree().root.add_child(current_game_instance)
	
	# 3. JUGAR (5 SEGUNDOS)
	await get_tree().create_timer(5.0).timeout
	
	# 4. TRANSICIÓN (Cerrar cortinas)
	print("🛑 Tiempo fuera. Cerrando cortinas...")
	var transition = load(transition_path).instantiate()
	get_tree().root.add_child(transition) 
	
	if transition.has_method("play_close"):
		await transition.play_close()
	else:
		await get_tree().create_timer(1.0).timeout

	# 5. LIMPIEZA (Borrar minijuego anterior)
	if current_game_instance != null:
		current_game_instance.queue_free()
		current_game_instance = null
	
	# --- AQUÍ ESTÁ LA SOLUCIÓN DEL GAME OVER ---
	if Global.round_failed:
		print("💀 Jugador perdió la ronda. Yendo a Game Over.")
		is_game_active = false # Rompemos el bucle
		
		# Cambiamos a la escena de Game Over (mientras las cortinas siguen cerradas)
		get_tree().change_scene_to_file(game_over_scene_path)
		
		# Abrimos cortinas para revelar la pantalla de Game Over
		if transition.has_method("play_open"):
			transition.play_open()
			get_tree().create_timer(1.5).timeout.connect(transition.queue_free)
		return # Salimos de la función para no seguir al siguiente juego
	
	# 6. SI NO PERDIÓ, ABRIR CORTINAS PARA EL SIGUIENTE
	if transition.has_method("play_open"):
		transition.play_open()
		get_tree().create_timer(1.5).timeout.connect(transition.queue_free)
	else:
		transition.queue_free()

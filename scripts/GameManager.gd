extends Node

# --- AUDIO GLOBAL (SFX y MÚSICA) ---
var sound_stream = preload("res://assets/assetsgenerales/Select.mp3")
var music_stream = preload("res://assets/assetsgenerales/Menu.mp3") # <--- Tu música aquí

var ui_sound_player: AudioStreamPlayer
var music_player: AudioStreamPlayer # <--- Nuevo reproductor para música

# --- CONFIGURACIÓN DE JUEGOS ---
var minigame_paths: Array[String] = [
	"res://minigames/buttonsmasher/scenes/MainButtonMasher.tscn",
	"res://minigames/contraseña/scenes/MainContraseña.tscn",
	"res://minigames/popup/scenes/PopupMain.tscn",
	"res://minigames/presionar/scenes/MainPresionar.tscn",
	"res://minigames/saltar/scenes/MainSaltar.tscn",
	"res://minigames/antivirus/scenes/MainAntivirus.tscn"
]

var transition_path: String = "res://scenes/transition_scene.tscn"
var game_over_scene_path: String = "res://scenes/game_over.tscn" 
var last_played_path: String = "" 
var current_game_instance: Node = null
var is_game_active: bool = false
var available_games: Array[String] = [] 

func _ready():
	# 1. Configurar efectos de sonido
	ui_sound_player = AudioStreamPlayer.new()
	ui_sound_player.stream = sound_stream
	add_child(ui_sound_player)
	
	# 2. Configurar música de fondo
	music_player = AudioStreamPlayer.new()
	music_player.stream = music_stream
	music_player.volume_db = -5 # Bajar volumen para que no moleste
	add_child(music_player)

# Funciones de Audio
func play_ui_sound():
	if ui_sound_player: ui_sound_player.play()

func play_music():
	# Solo reproducir si no está sonando ya
	if music_player and not music_player.playing:
		music_player.play()

func stop_music():
	if music_player:
		music_player.stop()

# --- LÓGICA DEL JUEGO (Igual que antes) ---
func start_game():
	Global.reset() 
	is_game_active = true
	available_games = minigame_paths.duplicate()
	game_loop()

func stop_game():
	is_game_active = false
	if current_game_instance:
		current_game_instance.queue_free()
		current_game_instance = null

func game_loop():
	while is_game_active:
		if minigame_paths.is_empty(): break
			
		if available_games.is_empty():
			available_games = minigame_paths.duplicate()
		
		var random_path = available_games.pick_random()
		available_games.erase(random_path)
		
		var game_scene = load(random_path)
		if game_scene:
			await play_minigame(game_scene)
		else:
			await get_tree().create_timer(1.0).timeout

func play_minigame(game_scene: PackedScene):
	Global.round_failed = false 
	current_game_instance = game_scene.instantiate()
	get_tree().root.add_child(current_game_instance)
	
	await get_tree().create_timer(5.0).timeout
	
	var transition = load(transition_path).instantiate()
	get_tree().root.add_child(transition) 
	
	if transition.has_method("play_close"):
		await transition.play_close()
	else:
		await get_tree().create_timer(1.0).timeout

	if current_game_instance != null:
		current_game_instance.queue_free()
		current_game_instance = null
	
	if Global.round_failed:
		is_game_active = false 
		get_tree().change_scene_to_file(game_over_scene_path)
		
		if transition.has_method("play_open"):
			transition.play_open()
			get_tree().create_timer(1.5).timeout.connect(transition.queue_free)
		return 
	
	if transition.has_method("play_open"):
		transition.play_open()
		get_tree().create_timer(1.5).timeout.connect(transition.queue_free)
	else:
		transition.queue_free()

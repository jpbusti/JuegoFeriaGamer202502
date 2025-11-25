extends Node

var sound_stream = preload("res://assets/assetsgenerales/Select.mp3")
var music_stream = preload("res://assets/assetsgenerales/Menu.mp3")

var ui_sound_player: AudioStreamPlayer
var music_player: AudioStreamPlayer 

var minigame_paths: Array[String] = [
	"res://minigames/buttonsmasher/scenes/MainButtonMasher.tscn",
	"res://minigames/contraseña/scenes/MainContraseña.tscn",
	"res://minigames/popup/scenes/PopupMain.tscn",
	"res://minigames/presionar/scenes/MainPresionar.tscn",
	"res://minigames/saltar/scenes/MainSaltar.tscn",
	"res://minigames/antivirus/scenes/MainAntivirus.tscn",
	"res://minigames/terminal/scenes/MainTerminal.tscn",
	"res://minigames/papelera/scenes/MainPapelera.tscn"
]

var transition_path: String = "res://scenes/transition_scene.tscn"
var game_over_scene_path: String = "res://scenes/game_over.tscn" 
var last_played_path: String = "" 
var current_game_instance: Node = null
var is_game_active: bool = false
var available_games: Array[String] = [] 

var hud_scene = preload("res://scenes/UI/SecurityHUD.tscn") 
var current_hud_instance: Node = null

func _ready():
	ui_sound_player = AudioStreamPlayer.new()
	ui_sound_player.stream = sound_stream
	add_child(ui_sound_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.stream = music_stream
	music_player.volume_db = -5 
	add_child(music_player)

func play_ui_sound():
	if ui_sound_player: ui_sound_player.play()

func play_music():
	if music_player and not music_player.playing:
		music_player.play()

func stop_music():
	if music_player:
		music_player.stop()

func start_game():
	Global.reset() 
	
	Global.played_games = {} 
	
	if current_hud_instance: current_hud_instance.queue_free() 
	current_hud_instance = hud_scene.instantiate()
	get_tree().root.add_child(current_hud_instance) 
		
	is_game_active = true
	available_games = minigame_paths.duplicate()
	game_loop()

func stop_game():
	is_game_active = false
	if current_game_instance:
		current_game_instance.queue_free()
		current_game_instance = null
	if current_hud_instance:
		current_hud_instance.queue_free()
		current_hud_instance = null

func game_loop():
	while is_game_active:
		if minigame_paths.is_empty(): break
			
		if available_games.is_empty():
			available_games = minigame_paths.duplicate()
		
		var random_path = available_games.pick_random()
		if available_games.size() > 1 and random_path == last_played_path:
			continue
			
		available_games.erase(random_path)
		last_played_path = random_path
		
		var game_scene = load(random_path)
		if game_scene:
			await play_minigame(game_scene)
		else:
			await get_tree().create_timer(1.0).timeout

func play_minigame(game_scene: PackedScene):
	Global.round_failed = false 

	current_game_instance = game_scene.instantiate()
	get_tree().root.add_child(current_game_instance)
	
	if current_game_instance.has_signal("start_timer"):
		print("Esperando instrucciones...")
		await current_game_instance.start_timer
	
	var game_duration = 5.0
	if "Boss" in current_game_instance.name:
		game_duration = 60.0
	
	await get_tree().create_timer(game_duration).timeout
	
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
		
		if current_hud_instance:
			current_hud_instance.queue_free()
			current_hud_instance = null
		
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

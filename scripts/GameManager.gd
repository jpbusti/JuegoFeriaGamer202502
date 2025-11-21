extends Node

# --- CONFIGURACIÓN ---
var minigame_paths: Array[String] = [
	"res://minigames/buttonsmasher/scenes/MainButtonMasher.tscn",
	"res://minigames/contraseña/scenes/MainContraseña.tscn",
	"res://minigames/popup/scenes/PopupMain.tscn",
	"res://minigames/presionar/scenes/MainPresionar.tscn",
	"res://minigames/saltar/scenes/MainSaltar.tscn",
	"res://minigames/antivirus/scripts/MainAntivirus.tscn"
]

var transition_path: String = "res://scenes/transition_scene.tscn"
var game_over_scene_path: String = "res://scenes/game_over.tscn" 
var last_played_path: String = "" 
var current_game_instance: Node = null
var is_game_active: bool = false

func _ready():
	pass

func start_game():
	Global.reset() 
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
			break
		var candidates = minigame_paths.duplicate() 
		if candidates.size() > 1 and last_played_path != "":
			candidates.erase(last_played_path)
			
		var random_path = candidates.pick_random()
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
		return #
	
	if transition.has_method("play_open"):
		transition.play_open()
		get_tree().create_timer(1.5).timeout.connect(transition.queue_free)
	else:
		transition.queue_free()

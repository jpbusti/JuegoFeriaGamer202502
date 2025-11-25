extends Node2D

signal start_timer

@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var lose_sound: AudioStreamPlayer2D = $LoseSound
@onready var ani_bomba = $AniBomba
@onready var bgm_player = $BgmPlayer
@onready var game_timer = $GameTimer

var game_over = false
var game_active = false

var secure_db = [
	"M@ta@Rata2.32", "XyZ_987-Lmn", "!dadSAwd23421", "3#99??¡?//dafac",
	"M1GatoSeLlamaGuante", "Kanqu1_2025", "N1E319IddhT/aN",
	"14Q@dgSGTYQ_#19f", "H4ck3r_Pr0_99", "341247QesiQ@3#"
]

var insecure_db = [
	"123456", "password", "admin", "12345", "querty", "hola123", 
	"dragon", "baseball", "princess", "iloveyou", "master", "shadow",
	"superman", "111111", "teamo", "usuario", "clave", "abcde",
	"futbol", "mama", "papa", "google", "facebook", "contraseña"
]

func _ready():
	# 1. FRENADO
	Global.round_failed = true
	game_active = false
	if game_timer: game_timer.stop()
	if ani_bomba: 
		ani_bomba.stop()
		ani_bomba.frame = 0
	
	if bgm_player: bgm_player.play()
	
	if not Global.played_games.has("contrasena"):
		# [INSTRUCCIONES]
		await show_instructions("¡ELIGE LA CONTRASEÑA SEGURA!") 
		Global.played_games["contrasena"] = true
		
	# --- CORRECCIÓN CRÍTICA ---
	await get_tree().process_frame
	# --------------------------
	
	start_timer.emit()
	start_game()

func start_game():
	game_active = true
	if ani_bomba: ani_bomba.play()
	if game_timer: game_timer.start()
	spawn_options()

func spawn_options():
	var current_round_data = []
	var secure_pass = secure_db.pick_random()
	current_round_data.append({"text": secure_pass, "is_secure": true})
	var insecure_pool = insecure_db.duplicate()
	insecure_pool.shuffle()
	var insecure_1 = insecure_pool.pop_back()
	var insecure_2 = insecure_pool.pop_back()
	current_round_data.append({"text": insecure_1, "is_secure": false})
	current_round_data.append({"text": insecure_2, "is_secure": false})
	current_round_data.shuffle()
	
	var center_x = get_viewport_rect().size.x / 3.5
	var positions = [Vector2(center_x, 150), Vector2(center_x, 300), Vector2(center_x, 450)]
	var option_scene = preload("res://minigames/contraseña/scenes/password_option.tscn")
	
	for i in 3:
		var option = option_scene.instantiate()
		option.position = positions[i]
		var data = current_round_data[i]
		option.set_password_text(data["text"])
		option.is_secure = data["is_secure"]
		option.chose_correct.connect(win_game)
		option.chose_wrong.connect(lose_game)
		add_child(option)

func win_game():
	if game_over: return
	game_over = true
	Global.round_failed = false
	Global.increase_score()
	if win_sound: win_sound.play()
	message_label.text = "¡ACCESO CONCEDIDO!"
	message_label.add_theme_color_override("font_color", Color.GREEN)
	message_label.visible = true

func lose_game():
	if game_over: return
	game_over = true
	Global.round_failed = true
	if lose_sound: lose_sound.play()
	message_label.text = "¡DENEGADO! CLAVE DÉBIL"
	message_label.add_theme_color_override("font_color", Color.RED)
	message_label.visible = true

func show_instructions(text_to_show: String):
	var instruction_scene = preload("res://scenes/UI/InstructionLabel.tscn")
	var instance = instruction_scene.instantiate()
	add_child(instance)
	await instance.show_message(text_to_show)

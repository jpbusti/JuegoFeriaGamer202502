extends Node2D

@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var lose_sound: AudioStreamPlayer2D = $LoseSound
@onready var ani_bomba = $AniBomba

var game_over = false

var secure_db = [
	"M@ta@Rata2.32", "XyZ_987-Lmn", "!dadSAwd23421", "3#99??¡?//dafac",
	"M1GatoSeLlamaGuante", "Kanqu1_2025", "Seguridad_Total!",
	"C0mpl3j4$Texto", "H4ck3r_Pr0_99", "341247QesiQ@3#"
]

var insecure_db = [
	"123456", "password", "admin", "12345", "querty", "hola123", 
	"dragon", "baseball", "princess", "iloveyou", "master", "shadow",
	"superman", "111111", "teamo", "usuario", "clave", "abcde"
]

func _ready():
	Global.round_failed = true
	start_game()

func start_game():
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")
	spawn_options()

func spawn_options():
	var current_round_data = []
	
	# 1. ELEGIR 1 SEGURA
	var secure_pass = secure_db.pick_random()
	current_round_data.append({"text": secure_pass, "is_secure": true})
	
	# 2. ELEGIR 2 INSEGURAS (Sin repetir)
	var insecure_pool = insecure_db.duplicate()
	insecure_pool.shuffle()
	
	var insecure_1 = insecure_pool.pop_back()
	var insecure_2 = insecure_pool.pop_back()
	
	current_round_data.append({"text": insecure_1, "is_secure": false})
	current_round_data.append({"text": insecure_2, "is_secure": false})
	
	# 3.  ORDEN
	current_round_data.shuffle()
	
	var center_x = get_viewport_rect().size.x / 3.5
	
	var positions = [
		Vector2(center_x, 150), 
		Vector2(center_x, 300), 
		Vector2(center_x, 450)
	]
	
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

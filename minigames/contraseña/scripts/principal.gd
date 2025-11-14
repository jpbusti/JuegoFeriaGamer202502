# principal.gd
extends Node2D

# 1. Cargar la plantilla de la opción (asegúrate que la ruta sea correcta)
const PASSWORD_OPTION_SCENE = preload("res://minigames/contraseña/scenes/password_option.tscn")

# 2. Definir las contraseñas
const SECURE_PASSWORD = ")T5oh27X2S\\Q" # Se usa doble barra \\
const WEAK_PASSWORDS = [
	"123456",
	"contraseña"
]

# 3. Posiciones donde aparecerán (ajústalas a tu pantalla)
const POSITIONS = [
	Vector2(350, 150),
	Vector2(350, 250),
	Vector2(350, 350)
]

# 4. Referencias a los nodos MÍNIMOS
@onready var game_timer: Timer = $GameTimer
@onready var message_label: Label = $MessageLabel
@onready var restart_timer: Timer = $RestartTimer
@onready var flicker_timer: Timer = $FlickerTimer
@onready var bgm_player: AudioStreamPlayer2D = $BgmPlayer
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var lose_sound: AudioStreamPlayer2D = $LoseSound

var flicker_mode = "none" # "win" o "lose"

var game_over: bool = false

func _ready():
	randomize() # ¡AÑADE ESTA LÍNEA!
	spawn_options()

func spawn_options():
	# Combinar y barajar las contraseñas
	var passwords_to_spawn = WEAK_PASSWORDS.duplicate()
	passwords_to_spawn.append(SECURE_PASSWORD)
	passwords_to_spawn.shuffle()
	
	# Crear las 3 opciones
	for i in 3:
		var new_option = PASSWORD_OPTION_SCENE.instantiate()
		new_option.position = POSITIONS[i]
		
		# Poner el texto
		var current_password_text = passwords_to_spawn[i]
		new_option.set_password_text(current_password_text)
		
		# Marcar cuál es la correcta
		if current_password_text == SECURE_PASSWORD:
			new_option.is_secure = true
			
		# Conectar las señales
		new_option.chose_correct.connect(win_game)
		new_option.chose_wrong.connect(lose_game)
		
		add_child(new_option)

# --- Lógica de Ganar/Perder (Limpia) ---

func win_game():
	if game_over: return
	game_over = true
	game_timer.stop()
	win_sound.play() # <--- AÑADE ESTA LÍNEA
	
	message_label.text = "¡MUY SEGURO!" # Muestra el texto de victoria
	message_label.visible = true
	message_label.self_modulate = Color.GREEN # Color inicial
	
	# --- AÑADE ESTAS 2 LÍNEAS ---
	flicker_mode = "win"
	flicker_timer.start()
	
	restart_timer.start()

func lose_game():
	if game_over: return
	game_over = true
	# --- LÓGICA DE SONIDO ---
	bgm_player.stop()  # <--- AÑADE ESTA LÍNEA
	lose_sound.play() # <--- AÑADE ESTA LÍNEA
	# ------------------------
	
	
	message_label.text = "¡INSEGURO!" # Muestra el texto de derrota
	message_label.visible = true
	message_label.self_modulate = Color.RED # Color inicial

	# --- AÑADE ESTAS 2 LÍNEAS ---
	flicker_mode = "lose"
	flicker_timer.start()
	
	game_timer.stop()
	restart_timer.start()

# --- Conexiones de los Timers ---

func _on_GameTimer_timeout():
	if not game_over:
		lose_game() # Pierdes si se acaba el tiempo

func _on_RestartTimer_timeout():
	get_tree().reload_current_scene()

# --- AÑADE ESTA FUNCIÓN AL FINAL DE TU SCRIPT ---
func _on_flicker_timer_timeout():
	message_label.visible = not message_label.visible
	
	if flicker_mode == "win":
		# Genera un tono aleatorio de verde (Verde entre 50% y 100% de brillo)
		message_label.self_modulate = Color(0.0, randf_range(0.5, 1.0), 0.0, 1.0)
		
	elif flicker_mode == "lose":
		# Genera un tono aleatorio de rojo (Rojo entre 50% y 100% de brillo)
		message_label.self_modulate = Color(randf_range(0.5, 1.0), 0.0, 0.0, 1.0)

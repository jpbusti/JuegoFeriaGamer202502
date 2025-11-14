extends Node2D

# --- SECCIÓN CORREGIDA ---
# Cargamos las TRES escenas (plantillas)
const POPUP_FELICIDADES_SCENE = preload("res://minigames/popup/popup_felicidades.tscn")
const POPUP_DESCARGA_SCENE = preload("res://minigames/popup/popup_descarga.tscn")
const POPUP_VIDEO_SCENE = preload("res://minigames/popup/popup_video.tscn")

# Un array con nuestras escenas
const POPUP_SCENES = [
	POPUP_FELICIDADES_SCENE,
	POPUP_DESCARGA_SCENE,
	POPUP_VIDEO_SCENE
]
# -------------------------

# Las mismas posiciones
const POSICIONES = [
	Vector2(550, 300),
	Vector2(860, 400),
	Vector2(250, 510)
]

@onready var game_timer: Timer = $GameTimer
@onready var restart_timer: Timer = $RestartTimer
@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound
@onready var virus_sprite: Sprite2D = $VirusSprite
@onready var laugh_sound: AudioStreamPlayer2D = $LaughSound
@onready var bgm_player: AudioStreamPlayer2D = $BgmPlayer
var popups_restantes: int = 3
var game_over: bool = false

func _ready() -> void:
	spawn_popups()

func spawn_popups() -> void:
	for i in 3:
		# --- SECCIÓN CORREGIDA ---
		# 1. Crear una instancia de la escena correcta
		var new_popup = POPUP_SCENES[i].instantiate()
		
		# 2. Asignarle su posición (ya no asignamos textura)
		new_popup.position = POSICIONES[i]
		# -------------------------
		
		# 3. Conectar sus señales
		new_popup.close_success.connect(_on_Popup_close_success)
		new_popup.close_fail.connect(_on_Popup_close_fail)
		
		# 4. Añadirlo a la escena
		add_child(new_popup)

# --- EL RESTO DEL CÓDIGO ES EXACTAMENTE IGUAL ---

# Esta función se llama CADA VEZ que cierras una 'X'
func _on_Popup_close_success() -> void:
	if game_over: return

	popups_restantes -= 1
	print("¡Pop-up cerrado! Faltan: %d" % popups_restantes)
	
	if popups_restantes == 0:
		win_game()

# Esta función se llama cuando CUALQUIER pop-up emite "close_fail"
func _on_Popup_close_fail() -> void:
	lose_game("¡Hiciste clic en el lugar equivocado!")

# Esta función se llama cuando el GameTimer de 5 segundos se acaba
func _on_GameTimer_timeout() -> void:
	if popups_restantes > 0 and not game_over:
		lose_game("¡Se acabó el tiempo!")

func win_game() -> void:
	if game_over: return
	game_over = true
	game_timer.stop()
	win_sound.play()
	
	virus_sprite.visible = false # Oculta el virus si ganas
	
	message_label.text = "GANASTE"
	message_label.visible = true
	
	restart_timer.start()

func lose_game(reason: String) -> void:
	if game_over: return
	game_over = true
	bgm_player.stop()  # Detiene la música de fondo
	# --- ¡AQUÍ ESTÁ LA NUEVA LÓGICA! ---
	fail_sound.play()          # 1. Reproduce el sonido de derrota
	laugh_sound.play()   # 2. Reproduce la risa
	virus_sprite.visible = true  # 3. Muestra la imagen del virus
	message_label.visible = false  # 4. Oculta el texto "PERDISTE"
	# -----------------------------------
	game_timer.stop()
	
	print("PERDISTE. " + reason)
	#message_label.text = "¡PERDISTE!"
	#message_label.visible = true
	
	restart_timer.start()

# Esta función se llama cuando el RestartTimer de 2 segundos termina
# (Asegúrate de que el nombre de esta función coincida con tu señal conectada)
func _on_RestartTimer_timeout() -> void:
	get_tree().reload_current_scene()

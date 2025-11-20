extends Node2D

# CONFIGURACIÓN DE DIFICULTAD
@export var TIEMPO_BASE: float = 5.0
@export var REDUCCION_TIEMPO: float = 0.5  # Reducción de segundos por nivel

# Escenas de popups
const POPUP_FELICIDADES_SCENE = preload("res://minigames/popup/scenes/popup_felicidades.tscn")
const POPUP_DESCARGA_SCENE = preload("res://minigames/popup/scenes/popup_descarga.tscn")
const POPUP_VIDEO_SCENE = preload("res://minigames/popup/scenes/popup_video.tscn")

const POPUP_SCENES = [
	POPUP_FELICIDADES_SCENE,
	POPUP_DESCARGA_SCENE,
	POPUP_VIDEO_SCENE
]

# Posiciones
const POSICIONES = [
	Vector2(550, 300),
	Vector2(860, 400),
	Vector2(250, 510)
]

# Referencias a nodos
@onready var game_timer: Timer = $GameTimer
@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound
@onready var virus_sprite: Sprite2D = $VirusSprite
@onready var laugh_sound: AudioStreamPlayer2D = $LaughSound
@onready var bgm_player: AudioStreamPlayer2D = $BgmPlayer
@onready var ani_bomba: AnimatedSprite2D = $AniBomba

# Variables del juego
var popups_restantes: int = 3
var game_over: bool = false
var victory: bool = false
var timer: Timer

func _ready():
	printerr("Minijuego Popup iniciado")
	apply_difficulty_settings()
	reset_game()
	start_game()

func apply_difficulty_settings():
	# Configurar tiempo según dificultad (menos tiempo en niveles más altos)
	var tiempo_actual = TIEMPO_BASE - (Global.score * REDUCCION_TIEMPO)
	tiempo_actual = max(tiempo_actual, 2.0)
	printerr("Dificultad: " + str(Global.score) + ", Tiempo: " + str(tiempo_actual))

func reset_game():
	game_over = false
	victory = false
	popups_restantes = 3
	
	# Limpiar popups anteriores
	for child in get_children():
		if child is Area2D:  # Asumiendo que los popups son Area2D
			child.queue_free()

func start_game():
	# Temporizador principal de 5 segundos
	timer = Timer.new()
	timer.wait_time = 5.0  # 5 segundos fijos
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_time_out)
	timer.start()

	# Configurar timer de UI
	game_timer.wait_time = 5.0
	game_timer.start()

	# Animación bomba
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

	spawn_popups()
	

func spawn_popups() -> void:
	for i in 3:
		var new_popup = POPUP_SCENES[i].instantiate()
		new_popup.position = POSICIONES[i]
		new_popup.close_success.connect(_on_Popup_close_success)
		new_popup.close_fail.connect(_on_Popup_close_fail)
		add_child(new_popup)
	
	printerr("3 popups generados")

# --- Lógica de Ganar/Perder ---

func _on_Popup_close_success() -> void:
	if game_over: return

	popups_restantes -= 1
	printerr("Popup cerrado - Faltan: " + str(popups_restantes))
	
	if popups_restantes == 0:
		win_game()

func _on_Popup_close_fail() -> void:
	if game_over: return
	printerr("Clic en lugar equivocado")
	lose_game()

func win_game():
	if game_over: return
	game_over = true
	victory = true
	
	# Detener timers
	if timer:
		timer.stop()
	game_timer.stop()
	
	# Efectos de victoria
	if win_sound:
		win_sound.play()
	
	virus_sprite.visible = false
	message_label.text = "GANASTE"
	message_label.visible = true
	
	# Esperar y notificar
	await get_tree().create_timer(1.5).timeout
	notify_game_manager()

func lose_game():
	if game_over: return
	game_over = true
	victory = false
	
	# Detener timers
	if timer:
		timer.stop()
	game_timer.stop()
	
	# Efectos de derrota
	bgm_player.stop()
	if fail_sound:
		fail_sound.play()
	if laugh_sound:
		laugh_sound.play()
	
	virus_sprite.visible = true
	message_label.visible = false
	
	# Esperar y notificar
	await get_tree().create_timer(1.5).timeout
	notify_game_manager()

func notify_game_manager():
	printerr("Popup - Resultado: " + ("GANÓ" if victory else "PERDIÓ"))
	
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("process_minigame_result"):
		game_manager.process_minigame_result(victory)
	else:
		printerr("GameManager no encontrado")

# --- Temporizadores ---

func _on_time_out():
	if not game_over:
		printerr("Tiempo agotado - Popup")
		lose_game()

func _on_GameTimer_timeout():
	# Este timer puede usarse para actualizar una barra de tiempo visual
	pass

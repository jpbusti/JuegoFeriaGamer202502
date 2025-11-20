# principal.gd - VERSIÓN SUPER SIMPLE
extends Node2D

@onready var game_timer: Timer = $GameTimer
@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var lose_sound: AudioStreamPlayer2D = $LoseSound
@onready var ani_bomba: AnimatedSprite2D = $AniBomba

var game_over = false
var victory = false

func _ready():
	printerr("🎮 CONTRASEÑA - Iniciado")
	start_game()

func start_game():
	# Timer de 5 segundos
	game_timer.wait_time = 5.0
	game_timer.start()
	
	# Animación bomba
	if ani_bomba:
		ani_bomba.play("anibomba")
	
	# Generar opciones
	spawn_options()
	

func spawn_options():
	var passwords = ["123456", "contraseña", ")T5oh27X2S\\Q"]
	passwords.shuffle()
	
	var positions = [Vector2(350, 150), Vector2(350, 250), Vector2(350, 350)]
	
	for i in 3:
		var option_scene = preload("res://minigames/contraseña/scenes/password_option.tscn")
		var option = option_scene.instantiate()
		option.position = positions[i]
		option.set_password_text(passwords[i])
		option.is_secure = (passwords[i] == ")T5oh27X2S\\Q")
		option.chose_correct.connect(win_game)
		option.chose_wrong.connect(lose_game)
		add_child(option)
		
		printerr("🔑 Opción " + str(i) + ": " + passwords[i] + " - Segura: " + str(option.is_secure))

func win_game():
	if game_over: return
	game_over = true
	victory = true
	game_timer.stop()
	
	
	if win_sound:
		win_sound.play()
	
	message_label.text = "¡GANASTE!"
	message_label.visible = true
	
	# Esperar y notificar
	await get_tree().create_timer(1.5).timeout
	notify_game_manager()

func lose_game():
	if game_over: return
	game_over = true
	victory = false
	game_timer.stop()
	
	
	if lose_sound:
		lose_sound.play()
	
	message_label.text = "¡PERDISTE!"
	message_label.visible = true
	
	# Esperar y notificar
	await get_tree().create_timer(1.5).timeout
	notify_game_manager()

func _on_game_timer_timeout():
	if not game_over:
		lose_game()

func notify_game_manager():
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("process_minigame_result"):
		game_manager.process_minigame_result(victory)

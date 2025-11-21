extends Node2D

@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var lose_sound: AudioStreamPlayer2D = $LoseSound
@onready var ani_bomba: AnimatedSprite2D = $AniBomba

var game_over = false

func _ready():
	start_game()

func start_game():
	if ani_bomba: ani_bomba.play("anibomba")
	spawn_options()

func spawn_options():
	var passwords = ["123456", "password", ")T5oh27X2S\\Q"]
	passwords.shuffle()
	# Ajusta estas posiciones según tu escena
	var positions = [Vector2(350, 150), Vector2(350, 250), Vector2(350, 350)]
	
	for i in 3:
		var option_scene = preload("res://minigames/contraseña/scenes/password_option.tscn")
		var option = option_scene.instantiate()
		option.position = positions[i]
		option.set_password_text(passwords[i])
		# La contraseña segura es la compleja
		option.is_secure = (passwords[i] == ")T5oh27X2S\\Q")
		
		option.chose_correct.connect(win_game)
		option.chose_wrong.connect(lose_game)
		add_child(option)

func win_game():
	if game_over: return
	game_over = true
	
	printerr("✅ Contraseña correcta")
	Global.increase_score()
	
	if win_sound: win_sound.play()
	message_label.text = "¡GANASTE!"
	message_label.visible = true

func lose_game():
	if game_over: return
	game_over = true
	
	if lose_sound: lose_sound.play()
	message_label.text = "¡PERDISTE!"
	message_label.visible = true

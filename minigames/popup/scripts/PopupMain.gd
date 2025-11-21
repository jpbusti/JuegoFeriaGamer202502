extends Node2D

const POPUP_SCENES = [
	preload("res://minigames/popup/scenes/popup_felicidades.tscn"),
	preload("res://minigames/popup/scenes/popup_descarga.tscn"),
	preload("res://minigames/popup/scenes/popup_video.tscn")
]

const POSICIONES = [Vector2(550, 300), Vector2(860, 400), Vector2(250, 510)]

@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound
@onready var virus_sprite: Sprite2D = $VirusSprite
@onready var ani_bomba = $AniBomba

var popups_restantes: int = 3
var game_over: bool = false

func _ready():
	# --- CORRECCIÓN CLAVE ---
	Global.round_failed = true 
	# ------------------------
	start_game()

func start_game():
	popups_restantes = 3
	game_over = false
	
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

func _on_Popup_close_success() -> void:
	if game_over: return
	popups_restantes -= 1
	
	if popups_restantes == 0:
		win_game()

func _on_Popup_close_fail() -> void:
	if game_over: return
	lose_game() 

func win_game():
	if game_over: return
	game_over = true
	
	Global.increase_score()
	
	# --- CORRECCIÓN CLAVE ---
	Global.round_failed = false
	# ------------------------
	
	if win_sound: win_sound.play()
	if virus_sprite: virus_sprite.visible = false
	if message_label:
		message_label.text = "GANASTE"
		message_label.visible = true

func lose_game():
	if game_over: return
	game_over = true
	
	Global.round_failed = true
	
	if fail_sound: fail_sound.play()
	if virus_sprite: virus_sprite.visible = true
	if message_label:
		message_label.text = "FALLASTE"
		message_label.visible = true

extends Node2D

# Referencias
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
	lose_game() # Si haces clic mal, pierdes inmediatamente esta ronda

func win_game():
	if game_over: return
	game_over = true
	
	printerr("✅ Popups limpiados - WIN")
	Global.increase_score()
	
	if win_sound: win_sound.play()
	virus_sprite.visible = false
	message_label.text = "GANASTE"
	message_label.visible = true

func lose_game():
	if game_over: return
	game_over = true
	
	if fail_sound: fail_sound.play()
	virus_sprite.visible = true
	message_label.text = "FALLASTE"
	message_label.visible = true

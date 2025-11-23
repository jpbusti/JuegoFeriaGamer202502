extends Node2D

const POPUP_SCENES = [
	preload("res://minigames/popup/scenes/popup_felicidades.tscn"),
	preload("res://minigames/popup/scenes/popup_descarga.tscn"),
	preload("res://minigames/popup/scenes/popup_video.tscn")
]

# --- CONFIGURACIÓN DE ZONA SEGURA ---
# Dimensiones de la pantalla
const SCREEN_W = 1152
const SCREEN_H = 648

# MARGEN DE SEGURIDAD (Padding)
# Esto es cuánto espacio vacío dejamos obligatoriamente en los bordes.
# Si tus ventanas miden 300px de ancho, la mitad es 150px.
# Ponemos 200 de margen para asegurar que incluso si están centradas, no se salgan.
const PAD_X = 250 
const PAD_Y = 200 

@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound
@onready var virus_sprite: Sprite2D = $VirusSprite
@onready var ani_bomba = $AniBomba

var popups_restantes: int = 3
var game_over: bool = false

func _ready():
	Global.round_failed = true 
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
		
		# --- CÁLCULO DE POSICIÓN SEGURA ---
		# Generamos una posición SOLO dentro del recuadro central seguro.
		# X: Entre 250 y (1152 - 250) = Entre 250 y 902
		# Y: Entre 200 y (648 - 200) = Entre 200 y 448
		
		var min_x = PAD_X
		var max_x = SCREEN_W - PAD_X
		
		var min_y = PAD_Y
		var max_y = SCREEN_H - PAD_Y
		
		var random_x = randf_range(min_x, max_x)
		var random_y = randf_range(min_y, max_y)
		
		new_popup.position = Vector2(random_x, random_y)
		# ----------------------------------
		
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
	Global.round_failed = false
	
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

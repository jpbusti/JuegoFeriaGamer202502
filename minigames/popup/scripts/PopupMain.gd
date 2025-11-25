extends Node2D

signal start_timer

const POPUP_SCENES = [
	preload("res://minigames/popup/scenes/popup_felicidades.tscn"),
	preload("res://minigames/popup/scenes/popup_descarga.tscn"),
	preload("res://minigames/popup/scenes/popup_video.tscn")
]

const SCREEN_W = 1152
const SCREEN_H = 648
const PAD_X = 250 
const PAD_Y = 200 

@onready var message_label: Label = $MessageLabel
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound
@onready var virus_sprite: Sprite2D = $VirusSprite
@onready var ani_bomba = $AniBomba
@onready var bgm_player = $BgmPlayer
@onready var game_timer = $GameTimer 

var popups_restantes: int = 3
var game_over: bool = false
var game_active: bool = false

func _ready():
	# 1. FRENADO
	Global.round_failed = true 
	game_active = false
	if game_timer: game_timer.stop()
	if ani_bomba: 
		ani_bomba.stop()
		ani_bomba.frame = 0
	
	if bgm_player: bgm_player.play()
	
	if not Global.played_games.has("popup"):
		# [INSTRUCCIONES]
		await show_instructions("¡CIERRA LAS VENTANAS!") 
		Global.played_games["popup"] = true
		
	# --- CORRECCIÓN CRÍTICA ---
	await get_tree().process_frame
	# --------------------------
	
	start_timer.emit()
	start_game()

func start_game():
	game_active = true
	popups_restantes = 3
	game_over = false
	
	if ani_bomba: ani_bomba.play()
	if game_timer: game_timer.start()
	spawn_popups()

func spawn_popups() -> void:
	for i in 3:
		var new_popup = POPUP_SCENES[i].instantiate()
		var min_x = PAD_X
		var max_x = SCREEN_W - PAD_X
		var min_y = PAD_Y
		var max_y = SCREEN_H - PAD_Y
		var random_x = randf_range(min_x, max_x)
		var random_y = randf_range(min_y, max_y)
		new_popup.position = Vector2(random_x, random_y)
		new_popup.close_success.connect(_on_Popup_close_success)
		new_popup.close_fail.connect(_on_Popup_close_fail)
		add_child(new_popup)

func _on_Popup_close_success() -> void:
	if game_over: return
	popups_restantes -= 1
	if popups_restantes == 0: win_game()

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

func show_instructions(text_to_show: String):
	var instruction_scene = preload("res://scenes/UI/InstructionLabel.tscn")
	var instance = instruction_scene.instantiate()
	add_child(instance)
	await instance.show_message(text_to_show)

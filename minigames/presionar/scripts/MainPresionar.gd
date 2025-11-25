extends Node2D

signal start_timer

@export var SPEED_BASE: float = 500.0
@export var SPEED_INCREASE: float = 50.0 
@export var TARGET_WIDTH: float = 150.0  

@export var audio_bgm: AudioStream
@export var audio_success: AudioStream
@export var audio_fail: AudioStream

@onready var needle = $Needle           
@onready var target_zone = $TargetZone  
@onready var ani_bomba = $AniBomba

var direction: int = 1
var current_speed: float = 0.0 
var game_active: bool = false
var center_x: float = 0.0
var limit_left: float = 0.0
var limit_right: float = 0.0

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready():
	game_active = false
	if ani_bomba: 
		ani_bomba.stop()
		ani_bomba.frame = 0
	Global.round_failed = true
	
	center_x = 1152.0 / 2.0
	limit_left = 50.0
	limit_right = 1152.0 - 50.0
	
	bgm_player = AudioStreamPlayer.new()
	if audio_bgm:
		bgm_player.stream = audio_bgm
		bgm_player.volume_db = -5
		bgm_player.autoplay = true
	add_child(bgm_player)
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	if not Global.played_games.has("presionar"):
		# [INSTRUCCIONES]
		await show_instructions("¡ATINA AL VERDE CON\n      ESPACIO!")
		Global.played_games["presionar"] = true
		
	# --- CORRECCIÓN CRÍTICA ---
	await get_tree().process_frame
	# --------------------------
	
	start_timer.emit()
	start_game()

func start_game():
	game_active = true
	if ani_bomba: ani_bomba.play()
	
	current_speed = SPEED_BASE + (Global.score * SPEED_INCREASE)
	
	if target_zone:
		target_zone.position.x = center_x
		if target_zone is ColorRect:
			target_zone.size.x = TARGET_WIDTH
			target_zone.position.x = center_x - (TARGET_WIDTH / 2.0)
		elif target_zone is Sprite2D:
			var texture_width = target_zone.texture.get_width()
			target_zone.scale.x = TARGET_WIDTH / texture_width

func _process(delta):
	if not game_active: return
	needle.position.x += current_speed * direction * delta
	if needle.position.x >= limit_right: direction = -1
	elif needle.position.x <= limit_left: direction = 1

func _input(event):
	if not game_active: return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		check_win()

func check_win():
	game_active = false
	var distance = abs(needle.position.x - center_x)
	var tolerance = TARGET_WIDTH / 2.0 
	if distance <= tolerance: _win()
	else: _lose()

func _win():
	print("¡PERFECTO!")
	Global.round_failed = false
	Global.increase_score()
	if audio_success: sfx_player.stream = audio_success; sfx_player.play()
	needle.modulate = Color.GREEN
	var t = create_tween()
	t.tween_property(needle, "scale", Vector2(1.2, 1.2), 0.1)
	t.tween_property(needle, "scale", Vector2(1.0, 1.0), 0.1)

func _lose():
	print("FALLASTE")
	Global.round_failed = true
	if audio_fail: sfx_player.stream = audio_fail; sfx_player.play()
	needle.modulate = Color.RED

func show_instructions(text_to_show: String):
	var instruction_scene = preload("res://scenes/UI/InstructionLabel.tscn")
	var instance = instruction_scene.instantiate()
	add_child(instance)
	await instance.show_message(text_to_show)

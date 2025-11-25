extends Node2D

@export var META_BASE: int = 10
@export var INCREMENTO_META: int = 2 

@export var audio_tap: AudioStream
@export var audio_bgm: AudioStream 

@onready var virus = $Virus
@onready var blaster = $DynamiteBlaster
@onready var explosion_sound = $ExplosionSound
@onready var ani_bomba = $AniBomba

var press_count: int = 0
var exploded: bool = false
var meta_actual: int
var tap_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer 
var game_active: bool = false 

func _ready():
	tap_player = AudioStreamPlayer.new()
	tap_player.max_polyphony = 10
	if audio_tap: tap_player.stream = audio_tap
	add_child(tap_player)
	
	bgm_player = AudioStreamPlayer.new()
	if audio_bgm:
		bgm_player.stream = audio_bgm
		bgm_player.volume_db = -5
		bgm_player.autoplay = true
	add_child(bgm_player)
	
	Global.round_failed = true
	game_active = false
	
	# Instrucciones
	if not Global.played_games.has("masher"):
		await show_instructions("¡MACHACA EL CLICK!")
		Global.played_games["masher"] = true
		
	apply_difficulty_settings()
	start_game()

func apply_difficulty_settings():
	meta_actual = META_BASE + (Global.score * INCREMENTO_META)

func start_game():
	game_active = true
	press_count = 0
	exploded = false
	if virus:
		virus.visible = true
		virus.scale = Vector2.ONE
		virus.modulate = Color.WHITE
	
	if ani_bomba and ani_bomba.has_method("play"): 
		ani_bomba.play("anibomba")

func _input(event):
	if not game_active or exploded: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		press_count += 1
		if audio_tap:
			tap_player.pitch_scale = randf_range(0.9, 1.1)
			tap_player.play()
		
		if virus: virus.scale += Vector2(0.05, 0.05)
		if blaster and blaster.has_method("play"): blaster.play("press")
		
		if press_count >= meta_actual:
			_on_win()

func _on_win():
	exploded = true
	# Música NO para
	Global.increase_score()
	Global.round_failed = false
	if explosion_sound: explosion_sound.play()
	if virus:
		var tween = create_tween()
		tween.tween_property(virus, "scale", virus.scale * 1.5, 0.1)
		tween.tween_property(virus, "modulate", Color(1, 1, 1, 0), 0.2)

func show_instructions(text_to_show: String):
	var instruction_scene = preload("res://scenes/UI/InstructionLabel.tscn")
	var instance = instruction_scene.instantiate()
	add_child(instance)
	await instance.show_message(text_to_show)

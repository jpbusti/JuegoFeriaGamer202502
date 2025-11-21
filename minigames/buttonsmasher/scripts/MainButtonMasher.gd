extends Node2D

@export var META_BASE: int = 10
@export var INCREMENTO_META: int = 2 

@onready var virus = $Virus
@onready var blaster = $DynamiteBlaster
@onready var explosion_sound = $ExplosionSound
@onready var ani_bomba = $AniBomba

var press_count: int = 0
var exploded: bool = false
var meta_actual: int

func _ready():
	# --- CORRECCIÓN CLAVE ---
	Global.round_failed = true
	# ------------------------
	apply_difficulty_settings()
	start_game()

func apply_difficulty_settings():
	meta_actual = META_BASE + (Global.score * INCREMENTO_META)

func start_game():
	press_count = 0
	exploded = false
	if virus:
		virus.visible = true
		virus.scale = Vector2.ONE
		
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

func _input(event):
	if exploded: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		press_count += 1
		
		if virus: virus.scale += Vector2(0.05, 0.05)
		if blaster and blaster.has_method("play"): blaster.play("press")
		
		if press_count >= meta_actual:
			_on_win()

func _on_win():
	exploded = true
	printerr("Virus explotado")
	Global.increase_score()
	
	# --- CORRECCIÓN CLAVE ---
	Global.round_failed = false
	# ------------------------
	
	if explosion_sound: explosion_sound.play()
	
	if virus:
		var tween = create_tween()
		tween.tween_property(virus, "scale", virus.scale * 1.5, 0.3)
		tween.tween_property(virus, "modulate", Color(1, 1, 1, 0), 0.3)

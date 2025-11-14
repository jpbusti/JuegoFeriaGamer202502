extends Node2D

# CONFIGURACIÓN DE DIFICULTAD
@export var META_BASE: int = 10
@export var INCREMENTO_META: int = 2  # Clicks extra por nivel  <-- AQUÍ FALTABA EL #

@onready var virus = $Virus
@onready var blaster = $DynamiteBlaster
@onready var explosion_sound = $ExplosionSound
@onready var ani_bomba = $AniBomba

var press_count: int = 0
var exploded: bool = false
var timer: Timer
var meta_actual: int

func _ready():
	printerr("🎮 ButtonMasher iniciado")
	apply_difficulty_settings()
	reset_game()
	start_game()

func apply_difficulty_settings():
	# Configurar meta según dificultad
	meta_actual = META_BASE + (Global.score * INCREMENTO_META)
	printerr("🎯 Meta: " + str(meta_actual) + " clicks")

func reset_game():
	press_count = 0
	exploded = false
	if virus:
		virus.visible = true
		virus.scale = Vector2.ONE

func start_game():
	# Temporizador de 5 segundos
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_time_out)
	timer.start()

	# Animación bomba
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not exploded:
		press_count += 1
		if virus:
			virus.scale += Vector2(0.05, 0.05)
		if blaster:
			blaster.play("press")
		if press_count >= meta_actual:
			_on_win()

func _on_win():
	exploded = true
	if explosion_sound:
		explosion_sound.play()
	if virus:
		var tween = create_tween()
		tween.tween_property(virus, "scale", virus.scale * 1.5, 0.3)
		tween.tween_property(virus, "modulate", Color(1, 1, 1, 0), 0.3)
	printerr("✅ Virus explotado - Clicks: " + str(press_count))

func _on_time_out():
	printerr("⏰ ButtonMasher terminado - Ganó: " + str(exploded) + ", Clicks: " + str(press_count) + "/" + str(meta_actual))
	
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("process_minigame_result"):
		game_manager.process_minigame_result(exploded)

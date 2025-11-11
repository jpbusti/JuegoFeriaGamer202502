extends Node2D

@export var press_goal: int = 10
@onready var virus = $Virus
@onready var blaster = $DynamiteBlaster
@onready var explosion_sound = $ExplosionSound
@onready var ani_bomba = $AniBomba

var press_count: int = 0
var exploded: bool = false
var timer: Timer
var game_manager: Node
var resultado_definitivo: bool = false

func _ready():
	# Encontrar el GameManager
	game_manager = get_node("/root/GameManager")
	reset_game()
	start_game()

func reset_game() -> void:
	press_count = 0
	exploded = false
	resultado_definitivo = false
	if virus:
		virus.visible = true
		virus.scale = Vector2.ONE

func start_game() -> void:
	# crear el temporizador principal (5 s)
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_time_out)
	timer.start()

	# reproducir animación bomba (cronómetro)
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not exploded:
		press_count += 1
		if virus:
			virus.scale += Vector2(0.05, 0.05)
		if blaster:
			blaster.play("press")
		if press_count >= int(press_goal * Global.difficulty):
			_on_win()

func _on_win() -> void:
	exploded = true
	if explosion_sound:
		explosion_sound.play()
	if virus:
		var tween = create_tween()
		tween.tween_property(virus, "scale", virus.scale * 1.5, 0.3)
		tween.tween_property(virus, "modulate", Color(1, 1, 1, 0), 0.3)
	print("✅ Virus explotado - Esperando fin del tiempo")

func _on_time_out() -> void:
	print("Tiempo agotado - Procesando resultado")
	
	if game_manager and game_manager.has_method("process_minigame_result"):
		game_manager.process_minigame_result(exploded)
	else:
		# Fallback
		if exploded:
			Global.increase_score()
			get_tree().change_scene_to_file("res://scenes/GameManager.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")

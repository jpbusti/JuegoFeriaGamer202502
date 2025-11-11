extends Node2D

@onready var zona = $ZonaObjetivo
@onready var indicador = $Indicador
@onready var ani_bomba = $AniBomba

var direccion: int = 1
var velocidad_base: float = 1800.0
var velocidad_actual: float
var limite_izquierdo: float = 100
var limite_derecho: float = 1056
var acierto: bool = false
var juego_activo: bool = false
var timer: Timer

func _ready():
	reset_game()
	start_game()

func reset_game() -> void:
	acierto = false
	juego_activo = true
	direccion = 1
	if indicador:
		indicador.position.x = 200

	# aumenta dificultad según score
	var dificultad = 1.0 + (Global.score / 3.0) * 0.25
	velocidad_actual = velocidad_base * dificultad

func start_game() -> void:
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_time_out)
	timer.start()

	# reproducir animación bomba
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

func _process(delta):
	if not juego_activo:
		return

	indicador.position.x += direccion * velocidad_actual * delta
	if indicador.position.x > limite_derecho:
		indicador.position.x = limite_derecho
		direccion = -1
	elif indicador.position.x < limite_izquierdo:
		indicador.position.x = limite_izquierdo
		direccion = 1

func _input(event):
	if not juego_activo:
		return
	if event.is_action_pressed("ui_accept"):
		comprobar_acierto()

func comprobar_acierto():
	if not zona or not indicador or acierto:
		return

	var zona_rect = zona.get_global_rect()
	var indicador_rect = Rect2()

	if indicador is Sprite2D and indicador.texture:
		var tex_size = indicador.texture.get_size() * indicador.scale
		indicador_rect = Rect2(indicador.global_position - tex_size / 2, tex_size)
	else:
		return

	juego_activo = false  # detiene movimiento al presionar

	if zona_rect.intersects(indicador_rect):
		acierto = true
	else:
		acierto = false

	# (opcional: reproducir feedback visual/sonido)
	# ani_bomba.play("anibomba")  # ya está reproduciéndose

func _on_time_out():
	juego_activo = false
	if acierto:
		Global.increase_score()
		get_tree().change_scene_to_file("res://scenes/score_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

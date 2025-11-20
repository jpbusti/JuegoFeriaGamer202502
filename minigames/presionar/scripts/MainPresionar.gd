extends Node2D

# CONFIGURACIÓN DE DIFICULTAD
@export var VELOCIDAD_BASE: float = 1000
@export var RANGO_ZONA: float = 100.0  # Tamaño de la zona objetivo
@export var INCREMENTO_DIFICULTAD: float = 0.1  # Incremento por nivel

@onready var zona = $ZonaObjetivo
@onready var indicador = $Indicador
@onready var ani_bomba = $AniBomba

var direccion: int = 1
var velocidad_actual: float
var limite_izquierdo: float = 100
var limite_derecho: float = 1000
var acierto: bool = false
var juego_activo: bool = false
var timer: Timer

func _ready():
	printerr("🎮 Minijuego Tiempo iniciado")
	apply_difficulty_settings()
	reset_game()
	start_game()

func apply_difficulty_settings():
	# Configurar dificultad según score
	var nivel_dificultad = 1 + (Global.score * INCREMENTO_DIFICULTAD)
	velocidad_actual = VELOCIDAD_BASE * nivel_dificultad
	
	# Ajustar tamaño de la zona (más pequeña en niveles altos)
	if zona:
		zona.scale = Vector2(1.0 / nivel_dificultad, 1.0)
	
	printerr("Dificultad: " + str(nivel_dificultad) + ", Velocidad: " + str(velocidad_actual))

func reset_game():
	acierto = false
	juego_activo = true
	direccion = 1
	
	if indicador:
		indicador.position.x = 200

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

	juego_activo = true

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
	if not zona or not indicador:
		return

	var zona_rect = zona.get_global_rect()
	var indicador_pos = indicador.global_position
	var indicador_size = Vector2(50, 50)
	
	var indicador_rect = Rect2(indicador_pos - indicador_size/2, indicador_size)

	if zona_rect.intersects(indicador_rect):
		acierto = true
		printerr("ACIERTO")
	else:
		acierto = false
		printerr("FALLO")
	
	juego_activo = false

func _on_time_out():
	printerr("Minijuego Tiempo terminado - Ganó: " + str(acierto))
	juego_activo = false
	
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("process_minigame_result"):
		game_manager.process_minigame_result(acierto)

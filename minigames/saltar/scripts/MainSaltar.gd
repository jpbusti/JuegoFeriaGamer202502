extends Node2D

# CONFIGURACIÓN DE DIFICULTAD - FÁCIL DE MODIFICAR
@export var VELOCIDAD_BASE: float = 600.0  # Más rápido por defecto
@export var ESCALA_CARRO: float = 0.6      # Carro más pequeño
@export var FUERZA_SALTO: float = 800.0    # Salto más rápido
@export var INTERVALO_CARROS: float = 1.0  # Tiempo entre carros
@export var CARROS_POR_NIVEL: int = 1      # Carros extra por nivel de dificultad

@onready var player_node = $Player
@onready var ani_bomba = $AniBomba
@onready var car_spawn_timer = $CarSpawnTimer

var active_cars = []  # Array para múltiples carros
var microgame_active := false
var victory := false
var timer: Timer
var cars_spawned: int = 0
var max_cars: int = 1

func _ready():
	printerr("🎮 Saltar iniciado - Configuración: " + str(VELOCIDAD_BASE) + " velocidad, " + str(ESCALA_CARRO) + " escala")
	apply_difficulty_settings()
	reset_game()
	start_game()

func apply_difficulty_settings():
	# Aplicar configuración de dificultad según el score
	var nivel_dificultad = 1 + (Global.score / 2)  # Cada 2 puntos aumenta la dificultad
	max_cars = CARROS_POR_NIVEL * nivel_dificultad
	
	printerr("🎯 Dificultad nivel: " + str(nivel_dificultad) + ", Carros máx: " + str(max_cars))

func reset_game():
	victory = false
	microgame_active = true
	active_cars = []
	cars_spawned = 0

func start_game():
	# Temporizador principal de 5 segundos
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_time_out)
	timer.start()

	# Animación bomba
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

	# Configurar spawn de múltiples carros
	car_spawn_timer.wait_time = INTERVALO_CARROS
	car_spawn_timer.timeout.connect(_spawn_car)
	car_spawn_timer.start()

	microgame_active = true

func _spawn_car():
	if not microgame_active or cars_spawned >= max_cars:
		car_spawn_timer.stop()
		return

	var car_scene = preload("res://minigames/saltar/scenes/car.tscn")
	var car = car_scene.instantiate()
	
	# Aplicar configuración de dificultad al carro
	car.speed = VELOCIDAD_BASE * (1.0 + Global.score * 0.15)  # 15% más rápido por nivel
	car.scale = Vector2(ESCALA_CARRO, ESCALA_CARRO)
	
	# Posicionar carro
	var ground = $Ground
	var ground_y = ground.global_position.y - 50
	car.global_position = Vector2(1200, ground_y)

	add_child(car)
	active_cars.append(car)
	cars_spawned += 1

	# Conectar señales
	if not car.is_connected("player_hit", Callable(self, "_on_car_player_hit")):
		car.connect("player_hit", Callable(self, "_on_car_player_hit"))
	if not car.is_connected("car_dodged", Callable(self, "_on_car_dodged")):
		car.connect("car_dodged", Callable(self, "_on_car_dodged"))
	
	printerr("Carro " + str(cars_spawned) + "/" + str(max_cars) + " generado")

func _on_car_player_hit(_body: Node, car_instance: Node):
	if not microgame_active:
		return
	
	printerr("Jugador golpeado")
	victory = false
	microgame_active = false
	car_spawn_timer.stop()
	
	if is_instance_valid(car_instance):
		car_instance.queue_free()

func _on_car_dodged():
	if not microgame_active:
		return
	
	printerr("Auto esquivado")
	victory = true
	# No detenemos el juego aquí para permitir múltiples carros

func _on_time_out():
	printerr("Saltar terminado - Ganó: " + str(victory) + ", Carros: " + str(cars_spawned))
	microgame_active = false
	car_spawn_timer.stop()
	
	# Limpiar carros
	for car in active_cars:
		if is_instance_valid(car):
			car.queue_free()
	active_cars.clear()
	
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("process_minigame_result"):
		game_manager.process_minigame_result(victory)

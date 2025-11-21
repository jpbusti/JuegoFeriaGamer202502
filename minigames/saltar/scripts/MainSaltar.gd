extends Node2D

# CONFIGURACIÓN DE DIFICULTAD
@export var VELOCIDAD_BASE: float = 600.0 
@export var ESCALA_CARRO: float = 0.6      
@export var FUERZA_SALTO: float = 800.0    
@export var INTERVALO_CARROS: float = 1.0  
@export var CARROS_POR_NIVEL: int = 1      

@onready var player_node = $Player
@onready var ani_bomba = $AniBomba
@onready var car_spawn_timer = $CarSpawnTimer

var active_cars = [] 
var microgame_active := false
var player_alive := true # Variable para saber si sobrevivió
var cars_spawned: int = 0
var max_cars: int = 1
var timer: Timer

func _ready():
	apply_difficulty_settings()
	start_game()

func apply_difficulty_settings():
	var nivel_dificultad = 1 + (Global.score / 2) 
	max_cars = CARROS_POR_NIVEL * nivel_dificultad

func start_game():
	player_alive = true
	microgame_active = true
	
	# Temporizador interno: Si llega a 0 y player_alive es true, GANAS.
	# Lo ponemos en 4.5s para asegurar que el puntaje se sume antes de que la transición tape todo.
	timer = Timer.new()
	timer.wait_time = 4.5 
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_survival_success)
	timer.start()

	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

	car_spawn_timer.wait_time = INTERVALO_CARROS
	car_spawn_timer.timeout.connect(_spawn_car)
	car_spawn_timer.start()

func _spawn_car():
	if not microgame_active: return

	var car_scene = preload("res://minigames/saltar/scenes/car.tscn")
	var car = car_scene.instantiate()
	
	car.speed = VELOCIDAD_BASE * (1.0 + Global.score * 0.15) 
	car.scale = Vector2(ESCALA_CARRO, ESCALA_CARRO)
	
	var ground = $Ground
	# Ajuste de seguridad por si no encuentra el suelo
	var ground_y = 500 
	if ground: ground_y = ground.global_position.y - 50
	
	car.global_position = Vector2(1200, ground_y)

	add_child(car)
	active_cars.append(car)
	
	# Conectamos la señal de colisión del carro
	if not car.is_connected("player_hit", _on_car_player_hit):
		car.player_hit.connect(_on_car_player_hit)

func _on_car_player_hit(_body, _car_instance):
	if not player_alive: return
	
	printerr("💥 Jugador golpeado - Perdiste esta ronda")
	player_alive = false
	# Opcional: Reproducir sonido de muerte o cambiar animación
	# NO detenemos el juego, dejamos que el GameManager lo cierre

func _on_survival_success():
	if player_alive:
		printerr("✅ Sobreviviste - Punto sumado")
		Global.increase_score()
		# Aquí podrías mostrar un texto de "¡BIEN!" o sonido de victoria

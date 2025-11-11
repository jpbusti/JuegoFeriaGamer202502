extends Node2D

@onready var player_node = $Player
@onready var ani_bomba = $AniBomba
@onready var car_spawn_timer = $CarSpawnTimer
@onready var ground_node = $Ground

var active_car: Node = null
var microgame_active := false
var game_over := false
var car_speed_base := 420.0
var car_speed_actual := 420.0
var victory := false
var game_manager: Node
var resultado_definitivo: bool = false
var tiempo_inicio: float = 0.0

func _ready():
	# Encontrar el GameManager
	game_manager = get_node("/root/GameManager")
	reset_game()
	start_game()

func reset_game() -> void:
	victory = false
	game_over = false
	microgame_active = true
	resultado_definitivo = false
	active_car = null
	tiempo_inicio = Time.get_ticks_msec()

	# dificultad según score global
	var dificultad = 1.0 + (Global.score / 3.0) * 0.2
	car_speed_actual = car_speed_base * dificultad
	print("🚗 Dificultad:", dificultad, " | Velocidad autos:", car_speed_actual)

func start_game() -> void:
	# Conectar animación bomba (cronómetro visual)
	if ani_bomba:
		if not ani_bomba.is_connected("animation_finished", Callable(self, "_on_bomba_fin_anim")):
			ani_bomba.connect("animation_finished", Callable(self, "_on_bomba_fin_anim"))
		if ani_bomba.has_method("play"):
			ani_bomba.play("anibomba")

	# Espera 0.5s y spawnea solo un auto
	if car_spawn_timer:
		car_spawn_timer.one_shot = true
		car_spawn_timer.wait_time = 0.5
		car_spawn_timer.timeout.connect(_spawn_car)
		car_spawn_timer.start()

	microgame_active = true
	print("🎮 Microjuego saltar iniciado. Duración: 5 segundos")

func _spawn_car():
	if not microgame_active:
		return
	if active_car != null and is_instance_valid(active_car):
		return  # solo un carro a la vez

	var car_scene = preload("res://minigames/saltar/car.tscn")
	var car = car_scene.instantiate()
	car.speed = car_speed_actual

	# posicionar el carro justo encima del ground
	var ground_node = $Ground
	var shape = ground_node.get_node("CollisionShape2D").shape
	var ground_y = ground_node.global_position.y - shape.extents.y * ground_node.scale.y
	car.global_position = Vector2(get_viewport_rect().size.x + 50, ground_y - 40)

	add_child(car)
	active_car = car

	# conectar señales
	if not car.is_connected("player_hit", Callable(self, "_on_car_player_hit")):
		car.connect("player_hit", Callable(self, "_on_car_player_hit"))
	if not car.is_connected("car_dodged", Callable(self, "_on_car_dodged")):
		car.connect("car_dodged", Callable(self, "_on_car_dodged"))

	print("Carro creado en", car.global_position)

func _on_car_player_hit(body: Node, car_instance: Node) -> void:
	if resultado_definitivo:
		return
	
	print("👊 Jugador golpeado - Marcando como perdido")
	victory = false
	resultado_definitivo = true
	
	# Detener el juego visualmente pero esperar los 5 segundos
	microgame_active = false
	if is_instance_valid(car_instance):
		car_instance.queue_free()
	if player_node:
		player_node.visible = false  # Ocultar personaje

func _on_car_dodged() -> void:
	if resultado_definitivo:
		return
	
	print("✅ Auto esquivado - Marcando como ganado")
	victory = true
	resultado_definitivo = true
	# El juego continúa visualmente hasta que termine el tiempo

func _finish_game() -> void:
	if not microgame_active:
		return
	microgame_active = false

	if car_spawn_timer:
		car_spawn_timer.stop()
	if active_car and is_instance_valid(active_car):
		active_car.queue_free()
	active_car = null

func _on_bomba_fin_anim() -> void:
	print("💥 Fin de animación bomba - Procesando resultado final")
	
	# Asegurar que hayan pasado al menos 5 segundos
	var tiempo_transcurrido = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
	if tiempo_transcurrido < 5.0:
		print("⏳ Esperando resto del tiempo: ", 5.0 - tiempo_transcurrido, " segundos")
		await get_tree().create_timer(5.0 - tiempo_transcurrido).timeout
	
	_finish_game()
	
	if game_manager and game_manager.has_method("process_minigame_result"):
		game_manager.process_minigame_result(victory)
	else:
		# Fallback
		if victory:
			Global.increase_score()
			get_tree().change_scene_to_file("res://scenes/GameManager.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")

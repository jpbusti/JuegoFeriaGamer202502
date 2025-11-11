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


func _ready():
	reset_game()
	start_game()


func reset_game() -> void:
	victory = false
	game_over = false
	microgame_active = true
	active_car = null

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
	print("🎮 Microjuego saltar iniciado.")


func _spawn_car():
	if not microgame_active:
		return
	if active_car != null and is_instance_valid(active_car):
		return  # solo un carro a la vez

	var car_scene = preload("res://minigames/saltar/car.tscn")
	var car = car_scene.instantiate()
	car.speed = 420.0

	# posicionar el carro justo encima del ground
	var ground_node = $Ground
	var shape = ground_node.get_node("CollisionShape2D").shape
	var ground_y = ground_node.global_position.y - shape.extents.y * ground_node.scale.y
	car.global_position = Vector2(get_viewport_rect().size.x + 50, ground_y - 40)

	add_child(car)
	active_car = car

	# conectar señales (ahora sí seguro)
	if not car.is_connected("player_hit", Callable(self, "_on_car_player_hit")):
		car.connect("player_hit", Callable(self, "_on_car_player_hit"))
	if not car.is_connected("car_dodged", Callable(self, "_on_car_dodged")):
		car.connect("car_dodged", Callable(self, "_on_car_dodged"))

	print("Carro creado en", car.global_position)


func _on_car_player_hit(body: Node, car_instance: Node) -> void:
	print("Jugador golpeado -> pierde el minijuego.")
	victory = false
	microgame_active = false
	if is_instance_valid(car_instance):
		car_instance.queue_free()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_car_dodged() -> void:
	print("Auto esquivado -> gana el minijuego.")
	victory = true
	microgame_active = false
	Global.increase_score()
	get_tree().change_scene_to_file("res://scenes/score_scene.tscn")


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
	print("Fin de animación bomba.")
	if microgame_active:
		_finish_game()

	if victory:
		Global.increase_score()
		print("Ganó el minijuego. Score total:", Global.score)
		get_tree().change_scene_to_file("res://scenes/score_scene.tscn")
	else:
		print("Perdió el minijuego.")
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
func _on_game_over():
	var score = Global.score  
	var player_name = "Jugador"  
	var score_manager = get_node_or_null("/root/ScoreManager")
	
	if score_manager:
		score_manager.add_score(player_name, score)
	else:
		print("⚠️ No se encontró el nodo ScoreManager.")
	
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

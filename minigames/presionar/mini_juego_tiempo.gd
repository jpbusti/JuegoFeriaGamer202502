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
var game_manager: Node
var resultado_definitivo: bool = false
var tiempo_inicio: float = 0.0

func _ready():
	print("🎮 Minijuego Tiempo iniciado")
	
	# Encontrar el GameManager
	game_manager = get_node("/root/GameManager")
	if game_manager:
		print("✅ GameManager encontrado en minijuego tiempo")
	else:
		print("❌ GameManager NO encontrado en minijuego tiempo")
	
	reset_game()
	start_game()

func reset_game() -> void:
	acierto = false
	juego_activo = true
	resultado_definitivo = false
	direccion = 1
	tiempo_inicio = Time.get_ticks_msec()
	
	if indicador:
		indicador.position.x = 200

	# aumenta dificultad según score
	var dificultad = 1.0 + (Global.score / 3.0) * 0.25
	velocidad_actual = velocidad_base * dificultad
	print("🎯 Dificultad: ", dificultad, " Velocidad: ", velocidad_actual)

func start_game() -> void:
	# Crear temporizador de 5 segundos
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_time_out)
	timer.start()

	# reproducir animación bomba
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

	juego_activo = true
	print("🎮 Minijuego tiempo iniciado. Duración: 5 segundos")

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
	if not juego_activo or resultado_definitivo:
		return
		
	if event.is_action_pressed("ui_accept"):
		print("🎹 Tecla espacio presionada en minijuego tiempo")
		comprobar_acierto()

func comprobar_acierto():
	print("🎯 Comprobando acierto...")
	
	if not zona or not indicador:
		print("❌ Zona o indicador no encontrados")
		return

	var zona_rect = zona.get_global_rect()
	var indicador_rect = Rect2()

	if indicador is Sprite2D and indicador.texture:
		var tex_size = indicador.texture.get_size() * indicador.scale
		indicador_rect = Rect2(indicador.global_position - tex_size / 2, tex_size)
	else:
		print("❌ Indicador no es Sprite2D o no tiene textura")
		return

	# Marcar resultado pero NO detener el juego aún
	if zona_rect.intersects(indicador_rect):
		acierto = true
		print("✅ ACIERTO - Esperando fin del tiempo")
	else:
		acierto = false
		print("❌ FALLO - Esperando fin del tiempo")
	
	resultado_definitivo = true
	# El indicador sigue moviéndose hasta que termine el tiempo

func _on_time_out():
	print("⏰ Tiempo agotado en minijuego tiempo - Procesando resultado: ", acierto)
	juego_activo = false
	
	if game_manager and game_manager.has_method("process_minigame_result"):
		print("📞 Llamando a GameManager.process_minigame_result(", acierto, ")")
		game_manager.process_minigame_result(acierto)
	else:
		print("❌ GameManager no disponible - Fallback")
		# Fallback
		if acierto:
			Global.increase_score()
			get_tree().change_scene_to_file("res://scenes/GameManager.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")

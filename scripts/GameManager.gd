extends Node2D

@export var microgame_duration: float = 5.0
# Rutas a tus minijuegos — por ahora solo ButtonMasher
@export var MINIGAMES: Array = [
	"res://minigames/buttonmasher/button_masher.tscn"
]

var current_minigame: Node = null
var last_index: int = -1

func _ready() -> void:
	randomize()
	start_random_minigame()

func start_random_minigame() -> void:
	# limpiar anterior
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null

	# elegir aleatorio (si solo uno, siempre ese)
	var idx = randi() % MINIGAMES.size()
	if MINIGAMES.size() > 1:
		while idx == last_index:
			idx = randi() % MINIGAMES.size()
	last_index = idx

	var path = MINIGAMES[idx]
	var res = load(path)
	if res == null:
		push_error("GameManager: no se pudo cargar " + path)
		game_over()
		return

	current_minigame = res.instantiate()
	add_child(current_minigame)

	# intentar resetear el minijuego si implementa reset_game()
	if current_minigame.has_method("reset_game"):
		current_minigame.reset_game()

	# esperar duración del microjuego
	await get_tree().create_timer(microgame_duration).timeout

	# comprobar resultado (usa has_won() que debe implementar el minijuego)
	var won = false
	if current_minigame.has_method("has_won"):
		won = current_minigame.has_won()
	else:
		# si no implementa has_won → asumir derrota
		won = false

	# reproducir animación de bomba si existe en minijuego
	if current_minigame.has_method("play_bomb"):
		current_minigame.play_bomb()

	# esperar breve transición para ver la bomba
	await get_tree().create_timer(1.0).timeout

	# liberar escena actual
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null

	# si ganó → sumar score y volver a la pantalla de score
	if won:
		Global.score += 1
		# ir a la escena de score (mostrará score incrementado)
		get_tree().change_scene_to_file("res://scenes/score_scene.tscn")
		return

	# si perdió o tiempo → game over
	game_over()

func game_over() -> void:
	var player_name = "Jugador"
	var score = Global.score
	print("💾 Guardando score:", score)

	if Engine.has_singleton("ScoreManager"):
		ScoreManager.add_score(player_name, score)
	else:
		push_warning("⚠ No se encontró ScoreManager autoload.")

	# Esperar un momento antes de cambiar de escena
	await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

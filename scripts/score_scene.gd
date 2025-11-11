"""extends Node2D

@onready var label_score: Label = $ScoreLabel

func _ready() -> void:

	if not label_score:
		push_error("❌ No se encontró $ScoreLabel")
	else:
		label_score.text = "SCORE: " + str(Global.score)

	# Crear un temporizador de 2 segundos y conectarlo manualmente
	var timer := Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_load_next_minigame)
	timer.start()


func _load_next_minigame() -> void:
	print(" Intentando cargar minijuego desde Global...")
	var path := Global.get_random_minigame()
	print(" Ruta del minijuego:", path)

	if path != "":
		print(" Cambiando a minijuego:", path)
		get_tree().change_scene_to_file(path)
	else:
		push_error("⚠ No se encontró ruta válida para minijuego en Global.")"""

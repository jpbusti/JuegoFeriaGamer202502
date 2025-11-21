extends Node2D

@onready var score_label: Label = $FinalScoreLabel
@onready var name_input: LineEdit = $NameInput

# Cargamos el sonido de derrota (puedes cambiar esta ruta)
var game_over_sound = preload("res://assets/assetsgenerales/Game over.mp3")
var audio_player: AudioStreamPlayer

func _ready():
	# 1. Configurar y reproducir sonido
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = game_over_sound
	add_child(audio_player)
	audio_player.play()
	
	# 2. Mostrar puntaje
	score_label.text = "Puntuación final: " + str(Global.score)
	
	name_input.text_submitted.connect(_on_name_submitted)
	name_input.grab_focus()

func _on_name_submitted(new_text: String):
	if new_text.strip_edges() == "":
		return 
	
	# Guardamos el score
	ScoreManager.add_score(new_text, Global.score)
	print("Guardando score para: ", new_text)
	
	# Volvemos al menú
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

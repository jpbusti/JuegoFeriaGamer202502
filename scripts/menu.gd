extends Control

@onready var play_button = $VBoxContainer/Jugar
@onready var score_button = $VBoxContainer/Scores
@onready var exit_button = $VBoxContainer/Salir

# Sonido de hover (opcional)
var hover_sound = preload("res://assets/assetsgenerales/Select.mp3")
var audio_player: AudioStreamPlayer

func _ready():
	# Crear reproductor de audio para UI
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Conectar señales visuales para CADA botón
	setup_button(play_button)
	setup_button(score_button)
	setup_button(exit_button)
	
	# Conectar funciones de lógica (lo que ya tenías)
	play_button.pressed.connect(_on_play_pressed)
	score_button.pressed.connect(_on_scores_pressed)
	exit_button.pressed.connect(_on_salir_pressed)

func setup_button(btn: Button):
	# Conectar señales de mouse
	btn.mouse_entered.connect(func(): _on_button_hover(btn))
	btn.mouse_exited.connect(func(): _on_button_exit(btn))
	
	# Ajustar pivote al centro para que crezca desde el medio
	btn.pivot_offset = btn.size / 2

func _on_button_hover(btn: Button):
	# Sonido
	if hover_sound: 
		audio_player.stream = hover_sound
		audio_player.play()
	
	# Animación: Crecer 10%
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
	btn.modulate = Color(1.5, 1.5, 1.5) # Brillar más

func _on_button_exit(btn: Button):
	# Animación: Volver a tamaño normal
	var t = create_tween()
	t.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
	btn.modulate = Color.WHITE
func _on_play_pressed():
	GameManager.play_ui_sound()

	GameManager.stop_music()
	
	get_tree().change_scene_to_file("res://scenes/MAIN_SCENE.tscn") 
	GameManager.start_game()

func _on_scores_pressed() -> void:
	GameManager.play_ui_sound()
	get_tree().change_scene_to_file("res://scenes/top_scores.tscn") 

func _on_salir_pressed() -> void:
	GameManager.play_ui_sound()
	get_tree().change_scene_to_file("res://scenes/Inicio.tscn")

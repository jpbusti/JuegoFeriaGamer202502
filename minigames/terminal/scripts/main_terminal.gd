extends Node2D

signal start_timer

var target_word: String = ""
var current_input: String = ""
var game_over: bool = false
var cursor_visible: bool = true
var cursor_timer: float = 0.0
var game_active: bool = false

@export var audio_bgm: AudioStream 

@onready var display = $CanvasLayer/TerminalDisplay
@onready var ani_bomba = $AniBomba
@onready var key_sound = $KeySound
@onready var win_sound = $WinSound

var sfx_key = preload("res://assets/termina/194797__jim-ph__vintage-keyboard-3.wav") 
var sfx_win = preload("res://assets/contraseña/audio/Correct.ogg")
var bgm_player: AudioStreamPlayer 

func _ready():
	# FRENADO
	game_active = false
	if ani_bomba: ani_bomba.stop(); ani_bomba.frame = 0
	Global.round_failed = true
	key_sound.stream = sfx_key
	win_sound.stream = sfx_win
	
	bgm_player = AudioStreamPlayer.new()
	if audio_bgm:
		bgm_player.stream = audio_bgm
		bgm_player.volume_db = -5
		bgm_player.autoplay = true
	add_child(bgm_player)
	
	# INSTRUCCIONES
	if not Global.played_games.has("terminal"):
		await show_instructions("¡TECLEA EL CÓDIGO!")
		Global.played_games["terminal"] = true
	
	# SINCRONIZACIÓN
	await get_tree().process_frame
	
	# ARRANQUE
	start_timer.emit()
	start_game()

func start_game():
	game_active = true
	if ani_bomba: ani_bomba.play()
	_pick_word_smartly()
	_update_display()

func _process(delta):
	if game_over or not game_active: return
	cursor_timer += delta
	if cursor_timer >= 0.5:
		cursor_timer = 0
		cursor_visible = !cursor_visible
		_update_display()

func _pick_word_smartly():
	# 1. Filtrar palabras según dificultad (Longitud)
	# Nivel 0 (fácil): 3-4 letras. Nivel Máx: > 10 letras.
	var min_len = 3 + floor(Global.score / 5.0)
	var max_len = 5 + floor(Global.score / 3.0)
	
	var candidates = []
	for item in Global.cyber_dictionary:
		var w_len = item["word"].length()
		if w_len >= min_len and w_len <= max_len:
			candidates.append(item)
	
	# Si no hay candidatos (nivel muy alto), coger cualquiera de las difíciles
	if candidates.is_empty():
		candidates = Global.cyber_dictionary.filter(func(x): return x["word"].length() > 8)
	
	# 2. Elegir una y guardarla en Global
	var selected_data = candidates.pick_random()
	target_word = selected_data["word"]
	
	# --- AQUÍ ESTÁ LA MAGIA PARA EL GAME OVER ---
	Global.last_terminal_data = selected_data
	# --------------------------------------------

func _input(event):
	if game_over or not game_active: return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_unicode = event.unicode
		if key_unicode > 0:
			var character = char(key_unicode).to_upper()
			# Aceptamos letras, números y guion bajo
			if (character >= "A" and character <= "Z") or (character >= "0" and character <= "9") or character == "_":
				_process_character(character)

func _process_character(char_typed: String):
	var next_index = current_input.length()
	if next_index >= target_word.length(): return
	var expected_char = target_word[next_index]
	if char_typed == expected_char:
		current_input += char_typed
		key_sound.pitch_scale = 1.0 + (next_index * 0.05)
		key_sound.play()
		_shake_screen(2.0)
		_update_display()
		if current_input == target_word: _win_game()
	else:
		_shake_screen(10.0)
		display.modulate = Color.RED
		var t = create_tween()
		t.tween_property(display, "modulate", Color.WHITE, 0.2)

func _update_display():
	var text_typed = "[color=#00FF00]" + current_input + "[/color]"
	var remaining_length = target_word.length() - current_input.length()
	var text_remaining = ""
	if remaining_length > 0:
		var remainder = target_word.substr(current_input.length(), remaining_length)
		text_remaining = "[color=#444444]" + remainder + "[/color]"
	var cursor = ""
	if cursor_visible and not game_over: cursor = "[color=#00FF00]_[/color]"
	elif not game_over: cursor = "[color=#000000]_[/color]" 
	display.text = "[center]" + text_typed + text_remaining + cursor + "[/center]"

func _win_game():
	game_over = true
	Global.round_failed = false
	Global.increase_score()
	win_sound.play()
	display.text = "[center][color=#00FF00]ACCESS GRANTED[/color][/center]"

func _shake_screen(intensity: float):
	var original_pos = display.position
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(display, "position", original_pos + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), 0.05)
	tween.tween_property(display, "position", original_pos, 0.05)

func show_instructions(text_to_show: String):
	var instruction_scene = preload("res://scenes/UI/InstructionLabel.tscn")
	var instance = instruction_scene.instantiate()
	add_child(instance)
	await instance.show_message(text_to_show)

extends Node2D

@export var META_BASE: int = 10
@export var INCREMENTO_META: int = 2 

# --- AUDIO NUEVO ---
@export var audio_tap: AudioStream # <--- Arrastra aquí un sonido corto (ej. 'switch-sound.mp3' o 'hit.wav')

@onready var virus = $Virus
@onready var blaster = $DynamiteBlaster
@onready var explosion_sound = $ExplosionSound
@onready var ani_bomba = $AniBomba

var press_count: int = 0
var exploded: bool = false
var meta_actual: int
var tap_player: AudioStreamPlayer # Reproductor creado por código

func _ready():
	# --- CONFIGURACIÓN DE AUDIO CLICK ---
	tap_player = AudioStreamPlayer.new()
	tap_player.max_polyphony = 10 # ¡CRUCIAL! Permite 10 sonidos simultáneos para clics rápidos
	add_child(tap_player)
	
	if audio_tap:
		tap_player.stream = audio_tap
	
	# --- RESTO DEL JUEGO ---
	Global.round_failed = true
	apply_difficulty_settings()
	start_game()

func apply_difficulty_settings():
	meta_actual = META_BASE + (Global.score * INCREMENTO_META)

func start_game():
	press_count = 0
	exploded = false
	if virus:
		virus.visible = true
		virus.scale = Vector2.ONE
		virus.modulate = Color.WHITE # Asegurar que sea visible
		
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

func _input(event):
	if exploded: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		press_count += 1
		
		# --- REPRODUCIR SONIDO CLICK ---
		if audio_tap:
			# Variamos un poco el tono (0.9 a 1.1) para que se sienta orgánico al spamear
			tap_player.pitch_scale = randf_range(0.9, 1.1)
			tap_player.play()
		
		# Feedback visual
		if virus: virus.scale += Vector2(0.05, 0.05)
		if blaster and blaster.has_method("play"): blaster.play("press")
		
		if press_count >= meta_actual:
			_on_win()

func _on_win():
	exploded = true
	print("✅ Virus explotado - WIN")
	Global.increase_score()
	Global.round_failed = false
	
	if explosion_sound: explosion_sound.play()
	
	if virus:
		var tween = create_tween()
		tween.tween_property(virus, "scale", virus.scale * 1.5, 0.1)
		tween.tween_property(virus, "modulate", Color(1, 1, 1, 0), 0.2)

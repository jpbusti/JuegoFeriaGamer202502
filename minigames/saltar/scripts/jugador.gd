extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var JUMP_FORCE: float = -500
@export var GRAVITY: float = 1500

# --- AUDIO (NUEVO) ---
@export var audio_jump: AudioStream # <--- Arrastra sonido de salto aquí

var sfx_player: AudioStreamPlayer

func _ready():
	# Crear reproductor de sonido dinámicamente
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Detectar Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()

	move_and_slide()

func jump():
	velocity.y = JUMP_FORCE
	
	# Reproducir sonido si está asignado
	if audio_jump:
		sfx_player.stream = audio_jump
		sfx_player.play()

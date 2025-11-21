extends CharacterBody2D

# IGNORAR valores del editor - forzar valores correctos
var JUMP_FORCE: float = -800.0   # NEGATIVO para saltar hacia arriba
var GRAVITY: float = 300

func _ready():
	if not is_in_group("player"):
		add_to_group("player")
	
	# Forzar valores iniciales
	JUMP_FORCE = -800.0
	GRAVITY = 1500.0
	

func _physics_process(delta: float) -> void:
	# Gravedad
	velocity.y += GRAVITY * delta
	
	# Salto con valor garantizado
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE  # Esto SIEMPRE será -800
	
	move_and_slide()

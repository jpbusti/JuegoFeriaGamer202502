extends Node2D

@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var anim: AnimationPlayer = $TransitionLayer/AnimationPlayer
@onready var top_curtain: ColorRect = $TransitionLayer/TopCurtain
@onready var bottom_curtain: ColorRect = $TransitionLayer/BottomCurtain

func _ready():
	print("🎮 GameManager Escena iniciado")
	
	# Configurar cortinas inicialmente ABIERTAS
	setup_curtains()
	
	# Configurar el TransitionLayer en el GameManager Autoload
	var game_manager_autoload = get_node("/root/GameManager")
	if game_manager_autoload and game_manager_autoload.has_method("setup_transition_layer"):
		game_manager_autoload.setup_transition_layer(transition_layer, anim)
		print("✅ TransitionLayer configurado en Autoload")
	else:
		print("❌ GameManager Autoload no encontrado")
	
	# Iniciar primer minijuego
	if game_manager_autoload and game_manager_autoload.has_method("start_first_minigame"):
		game_manager_autoload.start_first_minigame()

func setup_curtains():
	# Configurar cortinas inicialmente ABIERTAS (fuera de pantalla)
	var screen_size = get_viewport().get_visible_rect().size
	
	top_curtain.size = Vector2(screen_size.x * 1.1, screen_size.y / 2)
	top_curtain.position = Vector2(-screen_size.x * 0.05, -screen_size.y / 2)
	
	bottom_curtain.size = Vector2(screen_size.x * 1.1, screen_size.y / 2)
	bottom_curtain.position = Vector2(-screen_size.x * 0.05, screen_size.y)
	
	print("🎬 Cortinas configuradas en posición abierta")

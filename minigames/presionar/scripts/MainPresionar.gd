extends Node2D

@export var VELOCIDAD_BASE: float = 1000
@export var RANGO_ZONA: float = 100.0 
@export var INCREMENTO_DIFICULTAD: float = 0.1 

@onready var zona = $ZonaObjetivo
@onready var indicador = $Indicador
@onready var ani_bomba = $AniBomba

var direccion: int = 1
var velocidad_actual: float
var limite_izquierdo: float = 100
var limite_derecho: float = 1000
var juego_activo: bool = false
var ya_gano: bool = false

func _ready():
	# --- CORRECCIÓN CLAVE ---
	# Asumimos fallo hasta que el jugador demuestre lo contrario
	Global.round_failed = true 
	# ------------------------
	
	apply_difficulty_settings()
	start_game()

func apply_difficulty_settings():
	var nivel_dificultad = 1 + (Global.score * INCREMENTO_DIFICULTAD)
	velocidad_actual = VELOCIDAD_BASE * nivel_dificultad
	if zona:
		zona.scale = Vector2(1.0 / nivel_dificultad, 1.0)

func start_game():
	juego_activo = true
	ya_gano = false
	if indicador: indicador.position.x = 200
	
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")

func _process(delta):
	if not juego_activo: return

	indicador.position.x += direccion * velocidad_actual * delta
	if indicador.position.x > limite_derecho:
		indicador.position.x = limite_derecho
		direccion = -1
	elif indicador.position.x < limite_izquierdo:
		indicador.position.x = limite_izquierdo
		direccion = 1

func _input(event):
	if not juego_activo: return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"): 
		comprobar_acierto()

func comprobar_acierto():
	if not zona or not indicador: return

	var zona_rect = zona.get_global_rect()
	var indicador_pos = indicador.global_position
	var indicador_size = Vector2(50, 50) 
	var indicador_rect = Rect2(indicador_pos - indicador_size/2, indicador_size)

	juego_activo = false 

	if zona_rect.intersects(indicador_rect):
		printerr("✅ ACIERTO!")
		Global.increase_score()
		ya_gano = true
		
		# --- CORRECCIÓN CLAVE ---
		Global.round_failed = false # ¡Salvado!
		# ------------------------
		
		indicador.modulate = Color.GREEN
	else:
		printerr("❌ FALLO")
		indicador.modulate = Color.RED
		# Global.round_failed sigue siendo true

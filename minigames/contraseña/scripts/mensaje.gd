extends Label

# Parámetros ajustables desde el Inspector
@export var bob_amplitude: float = 3.0        # píxeles verticales máximos
@export var bob_frequency: float = 1.8        # ciclos por segundo (más -> más rápido)
@export var rotate_amplitude_deg: float = 2.5 # grados máximos de rotación
@export var rotate_speed: float = 0.7         # velocidad de oscilación de rotación
@export var scale_amplitude: float = 0.04     # variación relativa de escala (0.04 = ±4%)
@export var color_pulse_intensity: float = 0.10 # cuánto cambia el color (0..1)
@export var random_phase: bool = true         # fase aleatoria para no repetir siempre igual

# Internals
var _t: float = 0.0
var _base_pos: Vector2 = Vector2.ZERO
var _base_rotation: float = 0.0
var _base_scale: Vector2 = Vector2.ONE
var _phase_offset: float = 0.0
var _base_modulate: Color = Color(1,1,1,1)

func _ready() -> void:
	# Guardamos estado inicial
	_base_pos = position
	_base_rotation = rotation_degrees
	_base_scale = scale
	_base_modulate = modulate

	if random_phase:
		var rg: RandomNumberGenerator = RandomNumberGenerator.new()
		rg.randomize()
		_phase_offset = rg.randf_range(0.0, TAU)

	set_process(true)

func _process(delta: float) -> void:
	_t += delta

	# --- Bobbing (sube/baja) ---
	var bob: float = sin((_t * bob_frequency * TAU) + _phase_offset) * bob_amplitude
	position = _base_pos + Vector2(0.0, bob)

	# --- Rotación sutil ---
	var rot: float = sin((_t * rotate_speed * TAU) + _phase_offset * 0.7) * rotate_amplitude_deg
	rotation_degrees = _base_rotation + rot

	# --- Pulso de escala (ligero) ---
	var s: float = 1.0 + sin(_t * bob_frequency * TAU + _phase_offset * 0.5) * scale_amplitude
	scale = _base_scale * s

	# --- Pulso de color (opcional, muy sutil) ---
	var pulse: float = (sin((_t * 1.5) + _phase_offset) * 0.5 + 0.5) * color_pulse_intensity
	modulate = Color(
		clamp(_base_modulate.r + pulse, 0.0, 1.0),
		clamp(_base_modulate.g + pulse, 0.0, 1.0),
		clamp(_base_modulate.b + pulse, 0.0, 1.0),
		_base_modulate.a
	)

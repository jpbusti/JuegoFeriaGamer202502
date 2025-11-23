extends Node2D

# --- CONFIGURACIÓN ---
# 10 Niveles de dificultad (Arrays de palabras)
var word_db = [
	["TOR", "VPN", "SSH", "SSL", "KEY", "BOT", "BUG", "LOG"],
	
	# Nivel 2 (4 letras - Conceptos fundamentales)
	["HASH", "WORM", "SCAN", "DDOS", "ROOT", "SALT", "LEAK", "DARK"],
	
	# Nivel 3 (5 letras - Ataques y herramientas)
	["PHISH", "SPOOF", "CRACK", "PATCH", "TOKEN", "PROXY", "SHELL", "VIRUS"],
	
	# Nivel 4 (6 letras - Amenazas comunes)
	["TROJAN", "ATTACK", "BOTNET", "THREAT", "BYPASS", "SECURE", "ACCESS", "TARGET"],
	
	# Nivel 5 (7-8 letras - Malware y técnicas)
	["EXPLOIT", "MALWARE", "SPYWARE", "ROOTKIT", "PAYLOAD", "SNIFFER", "ADWARE", "HACKING"],
	
	# Nivel 6 (9-10 letras - Defensa y trampas)
	["ENCRYPTION", "HONEYPOT", "BACKDOOR", "PROTOCOL", "KEYLOGGER", "FIREWALL", "ANTIVIRUS"],
	
	# Nivel 7 (11-12 letras - Conceptos avanzados)
	["PENETRATION", "CREDENTIALS", "MITIGATION", "DECRYPTION", "PERMISSIONS", "RANSOMWARE"],
	
	# Nivel 8 (13-14 letras - Gestión de seguridad)
	["VULNERABILITY", "AUTHENTICATION", "AUTHORIZATION", "CYBERSECURITY", "CRYPTOGRAPHY", "STEGANOGRAPHY"],
	
	# Nivel 9 (15+ letras - Palabras maestras)
	["CONFIDENTIALITY", "DECENTRALIZATION", "WHISTLEBLOWER", "INFRASTRUCTURE", "VIRTUALIZATION"],
	
	# Nivel 10 (MODO HACKER SUPREMO - Frases de ataque)
	["SQL_INJECTION", "MAN_IN_THE_MIDDLE", "SOCIAL_ENGINEERING", "DENIAL_OF_SERVICE", "CROSS_SITE_SCRIPTING"]
]

var target_word: String = ""
var current_input: String = ""
var game_over: bool = false
var cursor_visible: bool = true
var cursor_timer: float = 0.0

# --- NODOS ---
@onready var display = $CanvasLayer/TerminalDisplay
@onready var ani_bomba = $AniBomba
@onready var key_sound = $KeySound
@onready var win_sound = $WinSound

# Sonidos (ajusta las rutas si es necesario)
var sfx_key = preload("res://assets/contraseña/audio/078.wav") 
var sfx_win = preload("res://assets/contraseña/audio/Correct.ogg")

func _ready():
	Global.round_failed = true
	
	key_sound.stream = sfx_key
	win_sound.stream = sfx_win
	
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")
	
	_pick_word_by_difficulty()
	_update_display()

func _process(delta):
	if game_over: return
	
	# Lógica del cursor parpadeante
	cursor_timer += delta
	if cursor_timer >= 0.5:
		cursor_timer = 0
		cursor_visible = !cursor_visible
		_update_display()

func _pick_word_by_difficulty():
	# Calculamos el nivel de dificultad (0 a 9)
	# Cada 3 puntos subes de nivel. Tope en nivel 9 (Nivel 10 en humano).
	var difficulty_index = min(floor(Global.score / 3.0), 9)
	
	var possible_words = word_db[difficulty_index]
	target_word = possible_words.pick_random()
	
	# Imprimir en consola para ver qué nivel tocó
	print("Score: ", Global.score, " -> Nivel Terminal: ", difficulty_index + 1, " (Palabra: ", target_word, ")")

func _input(event):
	if game_over: return
	
	if event is InputEventKey and event.pressed and not event.echo:
		var key_unicode = event.unicode
		if key_unicode > 0:
			var character = char(key_unicode).to_upper()
			
			# Aceptamos A-Z, 0-9 y AHORA TAMBIÉN EL GUION BAJO (_)
			if (character >= "A" and character <= "Z") or (character >= "0" and character <= "9") or character == "_":
				_process_character(character)

func _process_character(char_typed: String):
	var next_index = current_input.length()
	if next_index >= target_word.length(): return
	
	var expected_char = target_word[next_index]
	
	if char_typed == expected_char:
		# ¡CORRECTO!
		current_input += char_typed
		# Subida de tono más suave (0.05) para palabras largas no suenen muy agudo
		key_sound.pitch_scale = 1.0 + (next_index * 0.05)
		key_sound.play()
		_shake_screen(2.0)
		_update_display()
		
		if current_input == target_word:
			_win_game()
	else:
		# ¡ERROR!
		_shake_screen(10.0) # Temblor fuerte
		display.modulate = Color.RED # Flash rojo
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
	if cursor_visible and not game_over:
		cursor = "[color=#00FF00]_[/color]"
	elif not game_over:
		cursor = "[color=#000000]_[/color]" 
		
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

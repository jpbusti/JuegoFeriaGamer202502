extends Node

var score: int = 0
var difficulty: float = 1.0
var played_games = {}
var round_failed: bool = false 

var last_terminal_data = {} 
var cyber_dictionary = [
	{"word": "VPN", "def": "Red privada que cifra tu conexión para navegar de forma segura y anónima."},
	{"word": "TOR", "def": "Navegador que rebota tu conexión por varios nodos para ocultar tu identidad."},
	{"word": "SSL", "def": "Certificado que asegura que la conexión entre tu navegador y la web es segura (candado)."},
	{"word": "KEY", "def": "Clave criptográfica necesaria para encriptar o desencriptar información privada."},
	{"word": "BUG", "def": "Error en el código de un programa que puede ser explotado por atacantes."},
	
	{"word": "HASH", "def": "Huella digital única de un archivo. Si el archivo cambia, el hash cambia."},
	{"word": "WORM", "def": "Malware que se replica a sí mismo para propagarse a otros ordenadores."},
	{"word": "DDOS", "def": "Ataque que satura un servidor con tráfico falso para dejarlo fuera de servicio."},
	{"word": "ROOT", "def": "El usuario con control total y permisos absolutos en un sistema (Admin)."},
	
	{"word": "PHISHING", "def": "Engaño por correo o web falsa que suplanta identidad para robar tus datos."},
	{"word": "PATCH", "def": "Actualización de software diseñada para corregir errores o vulnerabilidades."},
	{"word": "PROXY", "def": "Intermediario entre tú e internet. Oculta tu IP pero no siempre cifra datos."},
	{"word": "VIRUS", "def": "Programa que necesita un archivo anfitrión para infectar y dañar el equipo."},
	
	{"word": "TROJAN", "def": "Software que parece legítimo e inofensivo pero esconde funciones maliciosas."},
	{"word": "BOTNET", "def": "Red de equipos infectados (zombies) controlados remotamente por un hacker."},
	{"word": "BYPASS", "def": "Técnica para saltarse las medidas de autenticación o seguridad de un sistema."},
	
	{"word": "EXPLOIT", "def": "Fragmento de código o ataque que aprovecha una vulnerabilidad específica."},
	{"word": "MALWARE", "def": "Término general para cualquier 'Software Malicioso' (virus, troyanos, etc)."},
	{"word": "SPYWARE", "def": "Software espía que recopila información de tu equipo sin tu permiso."},
	{"word": "ADWARE", "def": "Software no deseado que muestra publicidad intrusiva automáticamente."},
	{"word": "HACKING", "def": "Uso de conocimientos técnicos para superar un problema o barrera de seguridad."},
	
	{"word": "FIREWALL", "def": "Barrera de seguridad que controla y bloquea el tráfico de red no autorizado."},
	{"word": "HONEYPOT", "def": "Sistema trampa diseñado para atraer hackers y estudiar cómo atacan."},
	{"word": "BACKDOOR", "def": "Puerta trasera oculta para acceder a un sistema saltándose la autenticación."},
	{"word": "KEYLOGGER", "def": "Malware que registra y roba cada tecla que pulsas en tu teclado."},
	
	{"word": "RANSOMWARE", "def": "Malware que cifra tus archivos y exige un rescate (dinero) para liberarlos."},
	{"word": "ENCRYPTION", "def": "Proceso de codificar datos para que sean ilegibles sin la clave correcta."},
	{"word": "MITIGATION", "def": "Acciones tomadas para reducir la gravedad o el impacto de una amenaza."},
	
	{"word": "VULNERABILITY", "def": "Debilidad o fallo en un sistema que puede ser aprovechado por una amenaza."},
	{"word": "AUTHENTICATION", "def": "Proceso de verificar la identidad de un usuario (ej. contraseña, huella)."},
	{"word": "CYBERSECURITY", "def": "Práctica de proteger sistemas, redes y programas de ataques digitales."},
	
	{"word": "SQL_INJECTION", "def": "Ataque que inserta código malicioso en bases de datos a través de formularios web."},
	{"word": "ZERO_DAY", "def": "Vulnerabilidad recién descubierta que los desarrolladores aún no han arreglado."},
	{"word": "SOCIAL_ENGINEERING", "def": "Manipular psicológicamente a las personas para que revelen información confidencial."}
]

func reset():
	score = 0
	difficulty = 1
	round_failed = false
	last_terminal_data = {} 

func increase_score():
	score += 1
	if score % 3 == 0:
		difficulty += 0.5
		

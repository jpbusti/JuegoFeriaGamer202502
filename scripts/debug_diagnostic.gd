extends Control

func _ready():
	print("🎯 PRINT NORMAL")
	
	# Método alternativo 1
	printerr("🔴 PRINT ERROR")
	
	# Método alternativo 2  
	push_warning("⚠️ PRINT WARNING")
	
	# Método alternativo 3 - Escribir a archivo
	var file = FileAccess.open("user://debug_log.txt", FileAccess.WRITE)
	if file:
		file.store_string("📝 DEBUG: Script ejecutado\n")
		file.close()
	
	# Método visual
	var label = Label.new()
	label.text = "✅ SCRIPT EJECUTADO\nRevisa:\n1. Panel Salida\n2. Archivo user://debug_log.txt"
	label.position = Vector2(50, 50)
	add_child(label)
	
	# Verificar autoloads
	check_autoloads()

func check_autoloads():
	var autoloads = [
		"/root/Global",
		"/root/GameManager", 
		"/root/ScoreManager"
	]
	
	for path in autoloads:
		if has_node(path):
			print("✅ " + path + " cargado")
			printerr("✅ " + path + " cargado")
		else:
			print("❌ " + path + " NO cargado")
			printerr("❌ " + path + " NO cargado")

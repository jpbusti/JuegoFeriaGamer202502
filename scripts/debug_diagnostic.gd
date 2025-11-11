extends Control

func _ready():
	print("🔍 DEBUG DIAGNÓSTICO INICIADO")
	
	# Verificar Autoloads
	print("📋 VERIFICANDO AUTOLOADS:")
	if has_node("/root/Global"):
		print("✅ Global encontrado")
	else:
		print("❌ Global NO encontrado")
		
	if has_node("/root/GameManager"):
		print("✅ GameManager encontrado")
		var gm = get_node("/root/GameManager")
		print("📊 GameManager methods:", gm.get_method_list().size() if gm else "NULL")
	else:
		print("❌ GameManager NO encontrado")
		
	if has_node("/root/ScoreManager"):
		print("✅ ScoreManager encontrado")
	else:
		print("❌ ScoreManager NO encontrado")
	
	# Verificar Input
	print("🎹 VERIFICANDO INPUT:")
	print("ui_accept actions:", InputMap.has_action("ui_accept"))
	
	# Verificar rutas de minijuegos
	print("📁 VERIFICANDO RUTAS:")
	var paths = [
		"res://minigames/buttonsmasher/button_masher.tscn",
		"res://minigames/presionar/mini_juego_tiempo.tscn", 
		"res://minigames/saltar/saltar.tscn"
	]
	
	for path in paths:
		if ResourceLoader.exists(path):
			print("✅ ", path)
		else:
			print("❌ ", path)
	
	# Forzar un cambio de escena después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	print("🎮 Cargando GameManager...")
	get_tree().change_scene_to_file("res://scenes/GameManager.tscn")

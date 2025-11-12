extends CanvasLayer

var top_curtain: ColorRect
var bottom_curtain: ColorRect
var anim: AnimationPlayer
var score_label: Label
var audio_player: AudioStreamPlayer

func _ready():
	printerr("🎬 Transición ULTRA RÁPIDA iniciada")
	create_everything()
	setup_curtains()
	setup_score_display()
	start_ultra_fast_transition_sequence()

func create_everything():
	# Crear AnimationPlayer si no existe
	anim = get_node_or_null("AnimationPlayer")
	if not anim:
		anim = AnimationPlayer.new()
		anim.name = "AnimationPlayer"
		add_child(anim)
	
	# Crear cortinas
	create_curtains()
	# Crear animaciones ULTRA RÁPIDAS
	create_ultra_fast_animations()
	# Crear AudioStreamPlayer
	create_audio_player()

func create_audio_player():
	audio_player = AudioStreamPlayer.new()
	audio_player.name = "AudioStreamPlayer"
	add_child(audio_player)
	var sound = preload("res://assets/assetsgenerales/switch-sound.mp3")  
	if sound:
		audio_player.stream = sound
	else:
		printerr("❌ Sonido de transición no encontrado")

func create_curtains():
	# Crear TopCurtain
	top_curtain = ColorRect.new()
	top_curtain.name = "TopCurtain"
	add_child(top_curtain)
	
	# Crear BottomCurtain
	bottom_curtain = ColorRect.new()
	bottom_curtain.name = "BottomCurtain"
	add_child(bottom_curtain)

func create_ultra_fast_animations():
	# Animación ULTRA RÁPIDA curtains_close (0.2 segundos)
	if not anim.has_animation("curtains_close"):
		var close_anim = Animation.new()
		var track_idx = close_anim.add_track(Animation.TYPE_VALUE)
		close_anim.track_set_path(track_idx, "TopCurtain:position:y")
		close_anim.track_insert_key(track_idx, 0.0, -400.0)
		close_anim.track_insert_key(track_idx, 0.2, 0.0)  # Ultra rápido: 0.2 segundos
		
		track_idx = close_anim.add_track(Animation.TYPE_VALUE)
		close_anim.track_set_path(track_idx, "BottomCurtain:position:y")
		close_anim.track_insert_key(track_idx, 0.0, 800.0)
		close_anim.track_insert_key(track_idx, 0.2, 400.0)
		
		close_anim.length = 0.2
		anim.add_animation("curtains_close", close_anim)
	
	# Animación ULTRA RÁPIDA curtains_open (0.2 segundos)
	if not anim.has_animation("curtains_open"):
		var open_anim = Animation.new()
		var track_idx = open_anim.add_track(Animation.TYPE_VALUE)
		open_anim.track_set_path(track_idx, "TopCurtain:position:y")
		open_anim.track_insert_key(track_idx, 0.0, 0.0)
		open_anim.track_insert_key(track_idx, 0.2, -400.0)
		
		track_idx = open_anim.add_track(Animation.TYPE_VALUE)
		open_anim.track_set_path(track_idx, "BottomCurtain:position:y")
		open_anim.track_insert_key(track_idx, 0.0, 400.0)
		open_anim.track_insert_key(track_idx, 0.2, 800.0)
		
		open_anim.length = 0.2
		anim.add_animation("curtains_open", open_anim)

func setup_curtains():
	var screen_size = get_viewport().get_visible_rect().size
	
	top_curtain.size = Vector2(screen_size.x + 100, screen_size.y / 2)
	top_curtain.position = Vector2(-50, -screen_size.y / 2)
	top_curtain.color = Color(0, 0, 0, 0.9)
	
	bottom_curtain.size = Vector2(screen_size.x + 100, screen_size.y / 2)  
	bottom_curtain.position = Vector2(-50, screen_size.y)
	bottom_curtain.color = Color(0, 0, 0, 0.9)

func setup_score_display():
	# Crear y configurar label de score
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "SCORE: " + str(Global.score)
	score_label.add_theme_font_size_override("font_size", 48)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.position = Vector2(50, 50)
	add_child(score_label)
	
	printerr("📊 Score mostrado: " + str(Global.score))

func start_ultra_fast_transition_sequence():
	printerr("⚡ Transición ULTRA RÁPIDA iniciada (0.45 segundos total)")
	
	# 1. CERRAR CORTINAS ULTRA RÁPIDO (0.15s)
	anim.play("curtains_close")
	await anim.animation_finished
	printerr("✅ Cortinas cerradas")
	
	# Reproducir sonido exactamente cuando acaba la animación de cerrar
	if audio_player:
		audio_player.play()
		printerr("🔊 Sonido de transición reproducido")
	
	# 2. PAUSA MUY CORTA con cortinas cerradas (0.15s)
	await get_tree().create_timer(0.15).timeout
	
	# 3. Notificar al GameManager
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.has_method("complete_transition"):
		game_manager.complete_transition()
	
	# 4. ABRIR CORTINAS ULTRA RÁPIDO (0.15s)
	anim.play("curtains_open") 
	await anim.animation_finished
	printerr("✅ Cortinas abiertas")
	
	# 5. Eliminar escena de transición
	queue_free()

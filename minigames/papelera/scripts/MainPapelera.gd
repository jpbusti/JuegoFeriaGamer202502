extends Node2D

signal start_timer

@onready var virus_container = $VirusContainer
@onready var trash = $Trash
@onready var win_sound = $WinSound
@onready var lose_sound = $LoseSound
@onready var bgm_player = $BgmPlayer
@onready var virus_progress_bar = $CanvasLayer/VirusProgressBar
@onready var time_label = $CanvasLayer/TimeLabel
@onready var ani_bomba = $AniBomba
@onready var game_timer = $GameTimer 

var virus_scene = preload("res://minigames/papelera/scenes/virus.tscn")
var viruses_to_spawn = 0
var viruses_remaining = 0
var screen_size = Vector2(1152, 648)
var game_finished = false
var game_active = false 

func _ready():
	Global.round_failed = true
	game_finished = false
	
	game_active = false
	if game_timer: game_timer.stop()
	if ani_bomba: 
		ani_bomba.stop()
		ani_bomba.frame = 0
	
	viruses_to_spawn = 2 + floor(Global.score / 7.0)
	viruses_remaining = viruses_to_spawn
	
	if virus_progress_bar:
		virus_progress_bar.max_value = viruses_to_spawn
		virus_progress_bar.value = viruses_remaining
	if time_label: time_label.text = "¡LIMPIA EL SISTEMA!"
	
	if bgm_player: bgm_player.play()
	
	if not Global.played_games.has("papelera"):
		await show_instructions("¡BOTA LOS VIRUS!")
		Global.played_games["papelera"] = true
	
	await get_tree().process_frame
	
	start_timer.emit()
	start_game()

func start_game():
	game_active = true
	if ani_bomba: ani_bomba.play()
	if game_timer: game_timer.start()
	spawn_viruses()

func spawn_viruses():
	for i in range(viruses_to_spawn):
		var virus = virus_scene.instantiate()
		virus_container.add_child(virus)
		virus.add_to_group("virus")
		var spawn_x = randf_range(100, screen_size.x - 300) 
		var spawn_y = randf_range(100, screen_size.y - 150)
		virus.position = Vector2(spawn_x, spawn_y)
		virus.virus_deleted.connect(_on_virus_deleted)
		if Global.score > 10: virus.enable_shake(3.0 + (Global.score * 0.1))
		virus.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(virus, "scale", Vector2(0.7, 0.7), 0.3).set_trans(Tween.TRANS_BACK)

func _on_virus_deleted():
	if game_finished: return
	viruses_remaining -= 1
	if virus_progress_bar: virus_progress_bar.value = viruses_remaining
	if viruses_remaining <= 0: win_game()

func win_game():
	game_finished = true
	Global.round_failed = false
	Global.increase_score()
	if win_sound: win_sound.play()
	if time_label:
		time_label.text = "¡COMPLETADO!"
		time_label.modulate = Color.GREEN
	if trash:
		var tween = create_tween()
		tween.tween_property(trash, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(trash, "scale", Vector2(1.0, 1.0), 0.1)

func show_instructions(text_to_show: String):
	var instruction_scene = preload("res://scenes/UI/InstructionLabel.tscn")
	var instance = instruction_scene.instantiate()
	add_child(instance)
	await instance.show_message(text_to_show)

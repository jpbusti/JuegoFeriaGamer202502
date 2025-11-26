extends Control

const NEXT_SCENE = "res://scenes/Inicio.tscn"

@export var video_file: VideoStream 

@onready var video_player = $VideoStreamPlayer
@onready var skip_label = $SkipLabel

var skipped: bool = false

func _ready():
	if video_file:
		video_player.stream = video_file
		video_player.play()
	else:
		_on_video_finished()
		return
	
	video_player.finished.connect(_on_video_finished)
	
	skip_label.text = "PRESIONA CUALQUIER TECLA PARA SALTAR..."
	skip_label.add_theme_color_override("font_color", Color.WHITE)
	skip_label.modulate.a = 0.8
func _input(event):
	if skipped: return
	
	if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
		_on_video_finished() 

func _on_video_finished():
	if skipped: return
	skipped = true
	
	video_player.stop()

	get_tree().change_scene_to_file(NEXT_SCENE)

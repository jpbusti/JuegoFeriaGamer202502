extends CharacterBody2D

@export var JUMP_FORCE: float = -500
@export var GRAVITY: float = 1500

@export var audio_jump: AudioStream 

var sfx_player: AudioStreamPlayer

func _ready():
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump()

	move_and_slide()

func jump():
	velocity.y = JUMP_FORCE
	
	if audio_jump:
		sfx_player.stream = audio_jump
		sfx_player.play()

extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var top_curtain: ColorRect = $TopCurtain
@onready var bottom_curtain: ColorRect = $BottomCurtain
@onready var sound_player: AudioStreamPlayer = $SoundPlayer # <-- Nuevo nodo

var transition_speed: float = 4

func _ready():
	top_curtain.scale.y = 0
	bottom_curtain.scale.y = 0
	
	if anim_player.has_animation("RESET"):
		anim_player.play("RESET")

func play_close():
	if anim_player.has_animation("curtains_close"):
		anim_player.play("curtains_close", -1, transition_speed)
		await anim_player.animation_finished

		if sound_player.stream != null:
			sound_player.play()
	else:
		await get_tree().create_timer(0.2).timeout

func play_open():
	if anim_player.has_animation("curtains_open"):
		anim_player.play("curtains_open", -1, transition_speed)
		await anim_player.animation_finished
	else:
		await get_tree().create_timer(0.2).timeout

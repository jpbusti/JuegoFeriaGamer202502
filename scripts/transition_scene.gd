extends CanvasLayer # ¡Asegúrate que extienda de CanvasLayer!

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func play_close():
	anim_player.play("curtains_close") 
	await anim_player.animation_finished

func play_open():
	# Mueve las cortinas para abrir (ver juego)
	anim_player.play("curtains_open")
	await anim_player.animation_finished

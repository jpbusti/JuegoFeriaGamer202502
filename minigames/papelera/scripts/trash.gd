extends Area2D

@onready var sprite = $Sprite2D
@onready var recycle_sound = $RecycleSound 
@onready var original_scale = sprite.scale

func _ready():
	add_to_group("trash")
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area):
	if area.is_in_group("virus"):
		recycle_sound.play()
		# Animación cuando un virus entra
		var tween = create_tween()
		tween.tween_property(sprite, "scale", original_scale * 1.2, 0.1)
		tween.tween_property(sprite, "scale", original_scale, 0.1)

func _on_area_exited(area):
	if area.is_in_group("virus"):
		# Volver a escala normal
		var tween = create_tween()
		tween.tween_property(sprite, "scale", original_scale, 0.1)

extends Area2D

signal virus_deleted

var dragging = false
var drag_offset = Vector2.ZERO
var original_position = Vector2.ZERO
var target_position = Vector2.ZERO
var lerp_speed = 15.0
var shake_amount = 0.0
var shake_speed = 5.0
var time_passed = 0.0

@onready var sprite = $AnimatedSprite2D
@onready var scream_sound = $ScreamSound
@onready var original_scale = sprite.scale

func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	original_position = global_position
	target_position = global_position
	
	sprite.play("idle")  

func _process(delta):
	time_passed += delta
	
	if dragging:
		var mouse_pos = get_global_mouse_position()
		target_position = mouse_pos + drag_offset
		global_position = global_position.lerp(target_position, lerp_speed * delta)
		
		rotation = lerp_angle(rotation, sin(time_passed * 5) * 0.1, delta * 5)
	else:
		if shake_amount > 0:
			var shake_x = sin(time_passed * shake_speed) * shake_amount
			var shake_y = cos(time_passed * shake_speed * 1.5) * shake_amount
			position = original_position + Vector2(shake_x, shake_y)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag()
			else:
				stop_drag()

func start_drag():
	dragging = true
	drag_offset = global_position - get_global_mouse_position()
	z_index = 10  
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale * 1.2, 0.1)

func stop_drag():
	if not dragging:
		return
		
	dragging = false
	z_index = 0
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale, 0.1)
	
	check_trash_collision()

func check_trash_collision():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("trash"):
			delete_with_animation()
			return
	
	return_to_original_position()

func delete_with_animation():
	scream_sound.play()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "rotation", rotation + PI * 2, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	emit_signal("virus_deleted")
	queue_free()

func return_to_original_position():
	var tween = create_tween()
	tween.tween_property(self, "global_position", original_position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", 0.0, 0.3)

func enable_shake(amount: float):
	shake_amount = amount
	original_position = position

func _on_mouse_entered():
	if not dragging:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", original_scale * 1.1, 0.1)

func _on_mouse_exited():
	if not dragging:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", original_scale, 0.1)

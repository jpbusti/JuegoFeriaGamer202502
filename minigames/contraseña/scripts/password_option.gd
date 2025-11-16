# password_option.gd - MANTENER EL ORIGINAL QUE FUNCIONABA
extends Area2D

signal chose_correct
signal chose_wrong

var is_secure: bool = false
var password_text: String = ""

@onready var password_text_label: Label = $PasswordText

func _ready():
	password_text_label.text = password_text

func set_password_text(text: String):
	password_text = text
	if password_text_label:
		password_text_label.text = password_text

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_secure:
			chose_correct.emit()
		else:
			chose_wrong.emit()

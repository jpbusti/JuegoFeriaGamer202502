extends Area2D

signal chose_correct
signal chose_wrong

var is_secure: bool = false
var password_text: String = "" # 1. Variable para *guardar* el texto temporalmente

# 2. El @onready var se queda igual
@onready var password_text_label: Label = $PasswordText


# 3. _ready() se llama DESPUÉS de que las variables @onready se cargan.
func _ready():
	# Ahora que 'password_text_label' SÍ existe, 
	# le ponemos el texto que guardamos.
	password_text_label.text = password_text


# 4. Esta función (llamada por principal.gd) AHORA SÓLO GUARDA el texto.
func set_password_text(text: String):
	# Ya no usamos 'password_text_label' aquí
	password_text = text


# 5. La lógica del clic sigue igual
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_secure:
			emit_signal("chose_correct")
		else:
			emit_signal("chose_wrong")

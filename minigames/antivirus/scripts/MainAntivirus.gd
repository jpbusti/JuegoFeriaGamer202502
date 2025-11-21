extends Node2D

# --- CONFIGURACIÓN DE DIFICULTAD ---
@export var SPAWN_RATE_BASE: float = 1.2 # Un poco más rápido para que haya más "tráfico"
@export var SPEED_BASE: float = 150.0    
@export var SPEED_MULTIPLIER: float = 12.0 

# --- TEXTURAS ---
@export var texture_arrow: Texture2D
@export var texture_virus: Texture2D
@export var texture_safe_1: Texture2D
@export var texture_safe_2: Texture2D

# --- CONSTANTES ---
const DISTANCE_SPAWN = 350.0 
const HIT_RADIUS = 40.0      
const INDEX_ROTATION_OFFSET = -90 

# --- ESTADO ---
var current_direction: int = 0 
var spawn_timer: float = 0.0
var active_items: Array = [] 
var game_active: bool = true

# --- NODOS ---
@onready var arrow = $Center/Arrow
@onready var items_container = $Items
@onready var message_label = $MessageLabel
@onready var ani_bomba = $AniBomba

class IncomingItem:
	var node: Sprite2D
	var type: String 
	var direction: int 
	var speed: float

func _ready() -> void:
	Global.round_failed = false 
	
	for child in items_container.get_children():
		child.queue_free()
	
	if ani_bomba and ani_bomba.has_method("play"):
		ani_bomba.play("anibomba")
	
	# Instrucciones claras
	message_label.text = "¡BLOQUEA VIRUS, PERO DEJA PASAR LOS ARCHIVOS!"
	_update_arrow_visuals(true)

func _process(delta: float) -> void:
	if not game_active: return
	
	# 1. SPAWNER
	var current_spawn_rate = max(0.4, SPAWN_RATE_BASE - (Global.score * 0.05))
	spawn_timer += delta
	if spawn_timer >= current_spawn_rate:
		spawn_timer = 0
		_spawn_item()
	
	# 2. MOVER Y DETECTAR
	for i in range(active_items.size() - 1, -1, -1):
		var item_data = active_items[i]
		var node = item_data.node
		
		node.position = node.position.move_toward(Vector2.ZERO, item_data.speed * delta)
		
		if node.position.length() < HIT_RADIUS:
			_handle_impact(item_data, i)

func _spawn_item():
	var item_data = IncomingItem.new()
	item_data.direction = randi() % 4
	
	var spawn_vector = Vector2.ZERO
	match item_data.direction:
		0: spawn_vector = Vector2.UP    
		1: spawn_vector = Vector2.RIGHT 
		2: spawn_vector = Vector2.DOWN  
		3: spawn_vector = Vector2.LEFT  
	
	item_data.speed = SPEED_BASE + (Global.score * SPEED_MULTIPLIER)
	
	var is_virus = randf() > 0.6 
	item_data.type = "virus" if is_virus else "safe"
	
	var sprite = Sprite2D.new()
	if is_virus:
		sprite.texture = texture_virus
		sprite.scale = Vector2(0.2, 0.2) 
	else:
		sprite.texture = texture_safe_1 if randf() > 0.5 else texture_safe_2
		sprite.scale = Vector2(0.1, 0.1)
		
	sprite.position = spawn_vector * DISTANCE_SPAWN
	items_container.add_child(sprite)
	item_data.node = sprite
	active_items.append(item_data)

func _input(event: InputEvent) -> void:
	if not game_active: return
	
	if event.is_action_pressed("ui_up"):
		current_direction = 0
		_update_arrow_visuals()
	elif event.is_action_pressed("ui_right"):
		current_direction = 1
		_update_arrow_visuals()
	elif event.is_action_pressed("ui_down"):
		current_direction = 2
		_update_arrow_visuals()
	elif event.is_action_pressed("ui_left"):
		current_direction = 3
		_update_arrow_visuals()

func _update_arrow_visuals(instant: bool = false):
	var target_rot = (current_direction * 90) + INDEX_ROTATION_OFFSET
	if instant:
		arrow.rotation_degrees = target_rot
	else:
		var t = create_tween()
		t.tween_property(arrow, "rotation_degrees", target_rot, 0.05).set_trans(Tween.TRANS_SINE)

func _handle_impact(item: IncomingItem, index: int):
	
	if item.type == "virus":
		# Lógica Virus (Igual que antes)
		if current_direction == item.direction:
			_on_virus_blocked(item.node) # ¡Bien hecho!
			Global.increase_score()
		else:
			_game_over("¡INFECTADO! DEBES BLOQUEAR LOS VIRUS") # Mal hecho
			
	else:
		if current_direction == item.direction:
			_game_over("¡ERROR! BLOQUEASTE UN ARCHIVO SEGURO")
		else:
			_on_safe_passed(item.node)
	
	active_items.remove_at(index)

func _on_virus_blocked(node: Node2D):
	# Efecto de golpe
	var t = create_tween()
	t.tween_property(arrow, "scale", Vector2(1.2, 1.2), 0.05)
	t.tween_property(arrow, "scale", Vector2(0.7, 0.7), 0.05)
	node.queue_free()

func _on_safe_passed(node: Node2D):
	# Efecto visual suave: el archivo entra al sistema (se encoge y desaparece)
	var t = create_tween()
	t.tween_property(node, "scale", Vector2.ZERO, 0.1)
	t.tween_callback(node.queue_free)

func _game_over(reason: String):
	print("GAME OVER: ", reason)
	game_active = false
	Global.round_failed = true
	
	message_label.text = reason
	message_label.add_theme_color_override("font_color", Color.RED)
	arrow.modulate = Color.RED

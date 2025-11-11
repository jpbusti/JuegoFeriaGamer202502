extends Area2D

signal car_dodged
signal player_hit(body, car_instance)

@export var speed: float = 400.0
var _hit_processed: bool = false

func _ready() -> void:
	monitoring = true
	monitorable = true
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if _hit_processed:
		return
	position.x -= speed * delta
	if position.x < -100:
		_hit_processed = true
		car_dodged.emit()
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _hit_processed:
		return
	if body and body.is_in_group("player"):
		print("🚗 Carro tocó al jugador:", body.name)
		_hit_processed = true
		player_hit.emit(body, self)
		queue_free()

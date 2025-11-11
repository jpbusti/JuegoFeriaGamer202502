extends Node

var score: int = 0
var difficulty: float = 1.0
var microgames = [
	"res://minigames/buttonsmasher/button_masher.tscn", 
	"res://minigames/presionar/mini_juego_tiempo.tscn",
	"res://minigames/saltar/saltar.tscn"
	
]

func reset():
	score = 0
	difficulty = 1

func increase_score():
	score += 1
	if score % 3 == 0:
		difficulty += 0.5
		
func get_random_minigame() -> String:
	if microgames.is_empty():
		return ""
	return microgames[randi() % microgames.size()]

extends Node

var score: int = 0
var difficulty: float = 1.0

# Variable NUEVA para saber si perdió la ronda actual
var round_failed: bool = false 

func reset():
	score = 0
	difficulty = 1
	round_failed = false # Reseteamos esto también

func increase_score():
	score += 1
	if score % 3 == 0:
		difficulty += 0.5

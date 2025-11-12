extends Node

var score: int = 0
var difficulty: float = 1.0

func reset():
	score = 0
	difficulty = 1

func increase_score():
	score += 1
	if score % 3 == 0:
		difficulty += 0.5

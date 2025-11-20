extends Node

var scores: Array = [] 
var score_linked_list: ScoreList = ScoreList.new()

const SAVE_PATH := "user://scores.csv"
func _ready():
	load_scores()

func add_score(player_name: String, score_value: int) -> void:
	score_linked_list.insert_sorted(player_name, score_value)
	
	scores = score_linked_list.to_array()
	
	save_scores()

func save_scores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var current_node = score_linked_list.head
		while current_node != null:
			file.store_line("%s,%d" % [current_node.player_name, current_node.score])
			current_node = current_node.next 
		file.close()
		print("✅ Scores guardados en:", SAVE_PATH)
	else:
		push_error("❌ No se pudo guardar el archivo de puntajes.")


func load_scores() -> void:
	score_linked_list.clear() 
	scores.clear()          
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("No hay archivo de scores aún.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "":
			continue
		var parts = line.split(",")
		if parts.size() == 2:

			score_linked_list.insert_sorted(parts[0], int(parts[1]))
			
	file.close()
	
	scores = score_linked_list.to_array()
	print("Scores cargados en Lista Enlazada:", scores)

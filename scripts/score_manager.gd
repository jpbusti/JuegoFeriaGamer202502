extends Node

var scores: Array = []
const SAVE_PATH := "res://scores.csv"  # se guardará dentro del proyecto

func _ready():
	load_scores()

# Agregar puntaje nuevo
func add_score(player_name: String, score_value: int) -> void:
	var entry = {"name": player_name, "score": score_value}
	scores.append(entry)
	scores.sort_custom(func(a, b): return b["score"] < a["score"]) # orden descendente
	if scores.size() > 10:
		scores.resize(10)
	save_scores()

# Guardar en CSV
func save_scores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		for entry in scores:
			file.store_line("%s,%d" % [entry["name"], entry["score"]])
		file.close()
		print("✅ Scores guardados en:", SAVE_PATH)
	else:
		push_error("❌ No se pudo guardar el archivo de puntajes.")

# Cargar CSV
func load_scores() -> void:
	scores.clear()
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠ No hay archivo de scores aún.")
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "":
			continue
		var parts = line.split(",")
		if parts.size() == 2:
			scores.append({"name": parts[0], "score": int(parts[1])})
	file.close()
	print("📂 Scores cargados:", scores)

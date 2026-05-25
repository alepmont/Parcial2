extends Node

const SAVE_PATH := "user://savegame.json"
const MAX_SCORES := 5

var player_name := "Jugador"
var best_scores: Array = []
var last_score := 0

func _ready() -> void:
	load_data()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_data()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var content := file.get_as_text()
	file.close()

	if content.strip_edges().is_empty():
		save_data()
		return

	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		save_data()
		return

	player_name = str(parsed.get("player_name", "Jugador")).strip_edges()
	if player_name.is_empty():
		player_name = "Jugador"

	best_scores = []
	for entry in parsed.get("best_scores", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		best_scores.append({
			"name": str(entry.get("name", "Jugador")),
			"score": int(entry.get("score", 0)),
			"date": str(entry.get("date", ""))
		})

	_sort_and_trim_scores()

func save_data() -> void:
	var data := {
		"player_name": player_name,
		"best_scores": best_scores
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func set_player_name(name: String) -> void:
	var clean_name := name.strip_edges()
	if clean_name.is_empty():
		clean_name = "Jugador"
	player_name = clean_name
	save_data()

func add_score(score: int) -> void:
	last_score = max(score, 0)
	best_scores.append({
		"name": player_name,
		"score": last_score,
		"date": Time.get_datetime_string_from_system()
	})
	_sort_and_trim_scores()
	save_data()

func _sort_and_trim_scores() -> void:
	best_scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	if best_scores.size() > MAX_SCORES:
		best_scores.resize(MAX_SCORES)

func get_high_scores_text() -> String:
	if best_scores.is_empty():
		return "Sin puntuaciones guardadas"

	var lines: Array[String] = []
	for i in range(best_scores.size()):
		var entry: Dictionary = best_scores[i]
		lines.append("%d. %s - %d" % [i + 1, str(entry.get("name", "Jugador")), int(entry.get("score", 0))])
	return "\n".join(lines)

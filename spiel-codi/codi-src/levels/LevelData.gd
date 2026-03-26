## Ressource für Level-Konfiguration.
##
## Speichert alle Informationen über ein Level wie Name, Beschreibung,
## verfügbare Blöcke, initiale Blöcke und Ziele.
## Kann aus JSON-Dateien geladen werden.
extends Resource
class_name LevelData

## Name des Levels
@export var level_name: String = ""

## Beschreibung des Levels
@export var level_description: String = ""

## Schwierigkeitsgrad (1-10)
@export var difficulty: int = 1

## Verfügbare Blöcke für dieses Level (Anzahl pro Typ).
## -1 bedeutet unbegrenzt verfügbar.
@export var available_blocks: Dictionary = {
	"base_blocks": 0,
	"condition_blocks": 0,
	"case_distinction_blocks": 0,
	"loop_blocks": 0
}

## Initial gespawnte Blöcke (Array von Dictionaries)
@export var initial_blocks: Array = []

## Level-Ziele (Array von Strings)
@export var goals: Array = []

## Hilfe-Texte (Array von Strings)
@export var hints: Array = []

## Lädt LevelData aus einem JSON-String.
##
## @param json_string: Der JSON-String
## @return: Die geladene LevelData oder null bei Fehler
static func from_json(json_string: String) -> LevelData:
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		push_error("[LevelData] JSON Parse Error: %s" % json.get_error_message())
		return null
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[LevelData] JSON ist kein Dictionary")
		return null
	
	var level_data = LevelData.new()
	level_data.level_name = data.get("level_name", "Unnamed Level")
	level_data.level_description = data.get("level_description", "")
	level_data.difficulty = data.get("difficulty", 1)
	
	if data.has("available_blocks"):
		level_data.available_blocks = data.get("available_blocks", {})
	
	if data.has("initial_blocks"):
		level_data.initial_blocks = data.get("initial_blocks", [])
	
	if data.has("goals"):
		level_data.goals = data.get("goals", [])
	
	if data.has("hints"):
		level_data.hints = data.get("hints", [])
	
	return level_data

## Lädt LevelData aus einer Datei.
##
## @param path: Der Pfad zur JSON-Datei
## @return: Die geladene LevelData oder null bei Fehler
static func from_file(path: String) -> LevelData:
	if not FileAccess.file_exists(path):
		push_error("[LevelData] Datei nicht gefunden: %s" % path)
		return null
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("[LevelData] Konnte Datei nicht öffnen: %s" % path)
		return null
	
	var json_string = file.get_as_text()
	file.close()
	
	return from_json(json_string)

## Gibt eine lesbare String-Repräsentation zurück.
##
## @return: String-Repräsentation der LevelData
func _to_string() -> String:
	return "[LevelData: %s (Difficulty: %d)]" % [level_name, difficulty]

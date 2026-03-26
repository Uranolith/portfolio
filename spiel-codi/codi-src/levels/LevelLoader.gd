## Lädt Levels aus JSON-Dateien und spawnt Blöcke.
##
## Verwaltet verfügbare Block-Kontingente pro Level und
## koordiniert das Spawnen und Löschen von Blöcken.
class_name LevelLoader
extends Node

## Signal wird gesendet, wenn ein Level geladen wurde
##
## @param level_data: Die geladene LevelData
signal level_loaded(level_data: LevelData)

## Signal wird gesendet, wenn ein Block gespawnt wurde
##
## @param block: Der gespawnte Block
signal block_spawned(block: DraggableBlock)

## Signal wird gesendet, wenn ein Block gelöscht wurde
##
## @param block: Der gelöschte Block
signal block_deleted(block: DraggableBlock)

## Signal wird gesendet, wenn das Block-Limit erreicht wurde
##
## @param block_type: Der Typ des Blocks
signal block_limit_reached(block_type: String)

## Aktuell geladenes Level
var current_level: LevelData = null

## Verbleibende Blöcke pro Typ (Kontingent)
var remaining_blocks: Dictionary = {}

## Referenz zum Blocks-Container in der Szene
var blocks_container: Node = null

## Referenz zum ProgramBlock (wird automatisch gefunden oder erstellt)
var program_block: ProgramBlock = null

## Dictionary zum Tracken von tree_exiting Verbindungen (Block-Instanz-ID → bool)
var _connected_blocks: Dictionary = {}

## Initialisiert den LevelLoader.
func _ready():
	add_to_group("level_loader")
	_find_blocks_container()
	
	call_deferred("_connect_existing_blocks")

## Findet den Blocks-Container in der Szene.
func _find_blocks_container():
	var root = get_tree().root
	if root:
		var ui_control = root.get_node_or_null("UI_Control")
		if ui_control:
			blocks_container = ui_control.get_node_or_null("Blocks")
	
	if not blocks_container:
		var all_nodes = get_tree().get_nodes_in_group("blocks_container")
		if all_nodes.size() > 0:
			blocks_container = all_nodes[0]
	
	if not blocks_container:
		push_error("[LevelLoader] Blocks-Container nicht gefunden!")
	else:
		if BlockSpawner:
			BlockSpawner.set_blocks_container(blocks_container)
			BlockSpawner.set_level_loader(self)
		else:
			push_warning("[LevelLoader] BlockSpawner-Autoload noch nicht verfügbar")

## Verbindet alle existierenden Blöcke mit tree_exiting Signal.
##
## Wird beim Start aufgerufen, um bereits vorhandene Blöcke zu tracken.
func _connect_existing_blocks():
	if not blocks_container:
		return
	
	for child in blocks_container.get_children():
		if child is DraggableBlock:
			var block = child as DraggableBlock
			var block_id = block.get_instance_id()
			
			if not _connected_blocks.has(block_id):
				block.tree_exiting.connect(_on_block_deleted.bind(block))
				_connected_blocks[block_id] = true
				print("[LevelLoader] Connecting existing block with tree_exiting: %s" % block.block_name)

## Lädt ein Level aus einer JSON-Datei.
##
## @param level_path: Der Pfad zur Level-JSON-Datei
## @return: true wenn erfolgreich, false bei Fehler
func load_level(level_path: String) -> bool:
	print("[LevelLoader] Loading level: %s" % level_path)
	
	var level_data = LevelData.from_file(level_path)
	if not level_data:
		push_error("[LevelLoader] Could not load level: %s" % level_path)
		return false
	
	return load_level_from_data(level_data)

## Lädt ein Level aus LevelData.
##
## @param level_data: Die LevelData
## @return: true wenn erfolgreich, false bei Fehler
func load_level_from_data(level_data: LevelData) -> bool:
	if not level_data:
		push_error("[LevelLoader] No LevelData provided")
		return false
	
	print("[LevelLoader] Loading level: %s" % level_data.level_name)
	
	clear_level()
	
	current_level = level_data
	
	remaining_blocks = _convert_available_blocks_to_block_ids(level_data.available_blocks)
	
	_spawn_initial_blocks()
	
	level_loaded.emit(level_data)
	
	print("[LevelLoader] Level successfully loaded: %s" % level_data.level_name)
	print("[LevelLoader] Available blocks: %s" % str(remaining_blocks))
	
	return true

## Löscht alle Blöcke im Level (außer geschützte).
func clear_level():
	if not blocks_container:
		_find_blocks_container()
		if not blocks_container:
			return
	
	print("[LevelLoader] Clearing level...")
	
	var blocks_to_remove: Array[Node] = []
	
	for child in blocks_container.get_children():
		if child is DraggableBlock:
			if not child.delete_protection:
				blocks_to_remove.append(child)
	
	for block in blocks_to_remove:
		block.queue_free()
	
	_connected_blocks.clear()
	
	print("[LevelLoader] %d blocks deleted" % blocks_to_remove.size())

## Spawnt die initialen Blöcke des Levels.
func _spawn_initial_blocks():
	if not current_level:
		return
	
	if not blocks_container:
		_find_blocks_container()
		if not blocks_container:
			push_error("[LevelLoader] Blocks container not found!")
			return
	
	print("[LevelLoader] Spawning %d initial blocks..." % current_level.initial_blocks.size())
	
	for block_config in current_level.initial_blocks:
		var _block = _spawn_block_from_config(block_config)

## Spawnt einen Block basierend auf einer Konfiguration.
##
## @param config: Dictionary mit Block-Konfiguration (type, position, protected)
## @return: Der gespawnte Block oder null
func _spawn_block_from_config(config: Dictionary) -> DraggableBlock:
	var block_type = config.get("type", "")
	var position = config.get("position", {"x": 0, "y": 0})
	var protected = config.get("protected", false)
	
	if not blocks_container:
		push_error("[LevelLoader] Blocks-Container nicht gefunden!")
		return null
	
	var pos = Vector2(position.get("x", 0), position.get("y", 0))
	
	var block = BlockSpawner.spawn_block(block_type, pos, true)
	
	if block:
		block.delete_protection = protected
		
		if block_type == "program":
			program_block = block as ProgramBlock
	else:
		push_error("[LevelLoader] BlockSpawner.spawn_block() gab null zurück!")
	
	return block

## Versucht einen Block zu spawnen (prüft Kontingent).
##
## @param block_type: Der Typ des zu spawnenden Blocks
## @param position: Die Spawn-Position
## @return: Der gespawnte Block oder null wenn Limit erreicht
func try_spawn_block(block_type: String, position: Vector2) -> DraggableBlock:
	if not has_blocks_remaining(block_type):
		block_limit_reached.emit(block_type)
		print("[LevelLoader] Limit reached for block type: %s" % block_type)
		return null
	
	if not blocks_container:
		push_error("[LevelLoader] Blocks-Container nicht gefunden!")
		return null
	
	if not BlockSpawner:
		push_error("[LevelLoader] BlockSpawner-Autoload nicht verfügbar!")
		return null
	
	var block = BlockSpawner.spawn_block(block_type, position, true)
	
	if block:
		var category = _map_block_id_to_category(block_type)
		remaining_blocks[category] -= 1
		block_spawned.emit(block)
		print("[LevelLoader] Block spawned: %s (remaining: %d)" % [block_type, remaining_blocks[category]])
	
	return block

## Prüft ob noch Blöcke dieses Typs gespawnt werden dürfen.
##
## @param block_type: Der zu prüfende Block-Typ
## @return: true wenn noch Blöcke verfügbar sind
func has_blocks_remaining(block_type: String) -> bool:
	var category = _map_block_id_to_category(block_type)
	
	if not remaining_blocks.has(category):
		return false
	
	var limit = remaining_blocks[category]
	
	# -1 bedeutet unbegrenzt (praktisch unendlich)
	if limit == -1:
		return true
	
	var current_count = _count_blocks_of_type(category)
	
	return current_count < limit

## Zählt wie viele Blöcke eines bestimmten Typs aktuell existieren.
##
## @param block_type: Der zu zählende Block-Typ
## @return: Die Anzahl existierender Blöcke dieses Typs
func _count_blocks_of_type(block_type: String) -> int:
	if not blocks_container:
		return 0
	
	var count = 0
	
	for child in blocks_container.get_children():
		if not child is DraggableBlock:
			continue
		
		if child is ProgramBlock:
			continue
		
		var block = child as DraggableBlock
		
		var block_id = _get_block_id_from_block(block)
		if block_id == block_type:
			count += 1
	
	return count

## Bestimmt die Block-ID aus einem Block (über seine BlockData).
##
## @param block: Der Block dessen ID bestimmt werden soll
## @return: Die Block-ID als String
func _get_block_id_from_block(block: DraggableBlock) -> String:
	if not block.data:
		return ""
	
	match block.data.block_type:
		BlockData.BlockType.BASE:
			return "base"
		BlockData.BlockType.CONDITION:
			return "condition"
		BlockData.BlockType.CASE_DISTINCTION:
			return "case_distinction"
		BlockData.BlockType.LOOP:
			return "loop"
	
	return ""

## Gibt die Anzahl verbleibender Blöcke zurück (Limit - aktuell existierende).
##
## Bei -1 (unbegrenzt) wird 999999 zurückgegeben.
##
## @param block_type: Der Block-Typ
## @return: Anzahl verbleibender Blöcke
func get_remaining_blocks(block_type: String) -> int:
	var category = _map_block_id_to_category(block_type)
	
	if not remaining_blocks.has(category):
		return 0
	
	var limit = remaining_blocks[category]
	
	# -1 bedeutet unbegrenzt
	if limit == -1:
		return 999999  # "unbegrenzt"
	
	var current_count = _count_blocks_of_type(category)
	
	return max(0, limit - current_count)

## Wird vom BlockSpawner aufgerufen, wenn ein Block gespawnt wurde.
##
## Emittiert das block_spawned Signal für Listener (z.B. LevelInfoPanel).
##
## @param block: Der gespawnte Block
func notify_block_spawned(block: DraggableBlock):
	if not block or not is_instance_valid(block):
		return
	
	block_spawned.emit(block)
	
	var block_id = block.get_instance_id()
	if not _connected_blocks.has(block_id):
		block.tree_exiting.connect(_on_block_deleted.bind(block))
		_connected_blocks[block_id] = true

## Wird aufgerufen, wenn ein Block aus dem Baum entfernt wird.
##
## @param block: Der gelöschte Block
func _on_block_deleted(block: DraggableBlock):
	var block_name = "unknown"
	var block_type = ""
	var block_id = 0
	
	if block and is_instance_valid(block):
		block_name = block.block_name if "block_name" in block else "unknown"
		block_type = _get_block_id_from_block(block)
		block_id = block.get_instance_id()
		
		if _connected_blocks.has(block_id):
			_connected_blocks.erase(block_id)
	
	block_deleted.emit(block)
	
	print("[LevelLoader] Block deleted: %s (type: %s)" % [block_name, block_type])

## Findet den ProgramBlock in der Szene.
##
## @return: Der gefundene ProgramBlock oder null
func _find_program_block() -> ProgramBlock:
	if not blocks_container:
		return null
	
	for child in blocks_container.get_children():
		if child is ProgramBlock:
			return child as ProgramBlock
	
	return null


## Konvertiert available_blocks von Level-Namen zu Block-IDs.
##
## @param available_blocks: Dictionary mit Level-Namen als Keys
## @return: Dictionary mit Block-IDs als Keys
func _convert_available_blocks_to_block_ids(available_blocks: Dictionary) -> Dictionary:
	var converted: Dictionary = {}
	
	for key in available_blocks.keys():
		var count = available_blocks[key]
		
		match key:
			"base_blocks":
				converted["base"] = count
			"condition_blocks":
				converted["condition"] = count
			"case_distinction_blocks", "case_blocks", "case_if", "case_if_else", "cases":
				if converted.has("case_distinction"):
					converted["case_distinction"] += count
				else:
					converted["case_distinction"] = count
			"loop_blocks", "loop_while", "loop_for", "loop_do_while", "loops":
				if converted.has("loop"):
					converted["loop"] += count
				else:
					converted["loop"] = count
			"program":
				pass
			_:
				if key != "program":
					converted[key] = count
	
	return converted

## Mappt eine spezifische Block-ID auf ihre Kategorie.
##
## @param block_id: Die Block-ID (z.B. "base_move_forward")
## @return: Die Kategorie (z.B. "base")
func _map_block_id_to_category(block_id: String) -> String:
	if block_id in ["base", "condition", "case_distinction", "loop"]:
		return block_id
	
	# Mappe spezifische Block-IDs auf ihre Kategorien
	if block_id.begins_with("case_"):
		return "case_distinction"
	elif block_id.begins_with("loop_"):
		return "loop"
	elif block_id.begins_with("base_"):
		return "base"
	elif block_id == "base":
		return "base"
	elif block_id == "condition":
		return "condition"
	
	# Fallback: gebe die Block-ID zurück (für unbekannte IDs)
	return block_id

## Gibt Level-Info als Dictionary zurück.
##
## @return: Dictionary mit Level-Informationen
func get_level_info() -> Dictionary:
	if not current_level:
		return {}
	
	return {
		"name": current_level.level_name,
		"level_description": current_level.level_description,
		"difficulty": current_level.difficulty,
		"remaining_blocks": remaining_blocks.duplicate(),
		"goals": current_level.goals.duplicate(),
		"hints": current_level.hints.duplicate()
	}

## Gibt alle verfügbaren Level-Dateien zurück.
##
## @return: Array mit Pfaden zu allen Level-JSON-Dateien
static func get_available_levels() -> Array[String]:
	var levels: Array[String] = []
	var dir = DirAccess.open("res://levels/data/")
	
	if not dir:
		push_error("[LevelLoader] Konnte levels-Verzeichnis nicht öffnen")
		return levels
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			levels.append("res://levels/" + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	levels.sort()
	return levels

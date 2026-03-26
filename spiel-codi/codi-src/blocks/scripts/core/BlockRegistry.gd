## Zentrale Verwaltung aller Block-Definitionen.
##
## Diese Klasse implementiert das Registry-Pattern für projektweiten Zugriff
## auf Block-Metadaten. Sie verwaltet alle verfügbaren Block-Typen und deren
## Konfigurationen als Singleton.
class_name BlockRegistry
extends Resource

## Repräsentiert eine Block-Definition im Registry.
##
## Enthält alle Metadaten, die zum Spawnen und Konfigurieren
## eines Blocks benötigt werden.
class BlockDefinition:
	## Eindeutige ID des Blocks (z.B. "case_if", "loop_while")
	var block_id: String
	
	## Anzeigename des Blocks (z.B. "If", "While")
	var block_name: String
	
	## Pfad zur .tscn Datei
	var scene_path: String
	
	## Klassen-Name (z.B. "CaseDistinctionBlock", "LoopBlock")
	var block_class: String
	
	## Kategorie des Blocks (z.B. "case_distinction", "loop", "base", "condition")
	var category: String
	
	## Sub-Typ für spezifische Varianten (z.B. "IF", "WHILE")
	var sub_type: String
	
	## Action-Typ für BaseBlocks (z.B. "MOVE_FORWARD", "TURN_LEFT")
	var action_type: String
	
	func _init(p_id: String, p_name: String, p_path: String, p_class: String, p_category: String, p_sub_type: String = "", p_action: String = ""):
		block_id = p_id
		block_name = p_name
		scene_path = p_path
		block_class = p_class
		category = p_category
		sub_type = p_sub_type
		action_type = p_action

## Basis-Pfad zum Szenen-Ordner
const SCENES_BASE_PATH = "res://blocks/scenes/"

## Registry aller verfügbaren Block-Definitionen
static var _block_definitions: Dictionary = {}

## Initialisierungs-Flag
static var _initialized: bool = false

## Initialisiert das Registry mit allen verfügbaren Block-Definitionen.
##
## Diese Methode muss einmalig aufgerufen werden, bevor Blöcke
## abgerufen werden können. Sie registriert alle verfügbaren Block-Typen.
static func initialize():
	if _initialized:
		return
	
	_block_definitions.clear()
	
	# Base Blocks mit verschiedenen Aktionen
	_register_block(BlockDefinition.new(
		"base",
		"Base Block",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"NONE"
	))
	
	_register_block(BlockDefinition.new(
		"base_move_forward",
		"Move Forward",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"MOVE_FORWARD"
	))
	
	_register_block(BlockDefinition.new(
		"base_move_backward",
		"Move Backward",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"MOVE_BACKWARD"
	))
	
	_register_block(BlockDefinition.new(
		"base_turn_left",
		"Turn Left",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"TURN_LEFT"
	))
	
	_register_block(BlockDefinition.new(
		"base_turn_right",
		"Turn Right",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"TURN_RIGHT"
	))
	
	_register_block(BlockDefinition.new(
		"base_jump",
		"Jump",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"JUMP"
	))
	
	_register_block(BlockDefinition.new(
		"base_interact",
		"Interact",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"INTERACT"
	))
	
	_register_block(BlockDefinition.new(
		"base_wait",
		"Wait",
		SCENES_BASE_PATH + "base_block.tscn",
		"BaseBlock",
		"base",
		"",
		"WAIT"
	))
	
	# Condition Blocks - mit verschiedenen Presets
	_register_block(BlockDefinition.new(
		"condition",
		"Condition",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"CAN_MOVE_FORWARD"
	))
	
	_register_block(BlockDefinition.new(
		"condition_can_move_forward",
		"Can Move Forward",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"CAN_MOVE_FORWARD"
	))
	
	_register_block(BlockDefinition.new(
		"condition_can_move_backward",
		"Can Move Backward",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"CAN_MOVE_BACKWARD"
	))
	
	_register_block(BlockDefinition.new(
		"condition_has_object_ahead",
		"Has Object Ahead",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"HAS_OBJECT_AHEAD"
	))
	
	_register_block(BlockDefinition.new(
		"condition_is_at_goal",
		"Is At Goal",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"IS_AT_GOAL"
	))
	
	_register_block(BlockDefinition.new(
		"condition_is_at_edge",
		"Is At Edge",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"IS_AT_EDGE"
	))
	
	_register_block(BlockDefinition.new(
		"condition_can_interact",
		"Can Interact",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"CAN_INTERACT"
	))
	
	_register_block(BlockDefinition.new(
		"condition_path_is_clear",
		"Path Is Clear",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"PATH_IS_CLEAR"
	))
	
	_register_block(BlockDefinition.new(
		"condition_repeat_count",
		"Repeat X Times",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"REPEAT_COUNT"
	))
	
	_register_block(BlockDefinition.new(
		"condition_repeat_until_edge",
		"Repeat Until Edge",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"REPEAT_UNTIL_EDGE"
	))
	
	_register_block(BlockDefinition.new(
		"condition_repeat_until_goal",
		"Repeat Until Goal",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"REPEAT_UNTIL_GOAL"
	))
	
	_register_block(BlockDefinition.new(
		"condition_repeat_until_object",
		"Repeat Until Object",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"REPEAT_UNTIL_OBJECT"
	))
	
	_register_block(BlockDefinition.new(
		"condition_repeat_until_blocked",
		"Repeat Until Blocked",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"REPEAT_UNTIL_BLOCKED"
	))
	
	_register_block(BlockDefinition.new(
		"condition_counter_equals",
		"Counter ==",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"COUNTER_EQUALS"
	))
	
	_register_block(BlockDefinition.new(
		"condition_counter_not_equals",
		"Counter !=",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"COUNTER_NOT_EQUALS"
	))
	
	_register_block(BlockDefinition.new(
		"condition_counter_greater",
		"Counter >",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"COUNTER_GREATER_THAN"
	))
	
	_register_block(BlockDefinition.new(
		"condition_counter_less",
		"Counter <",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"COUNTER_LESS_THAN"
	))
	
	_register_block(BlockDefinition.new(
		"condition_counter_greater_equal",
		"Counter >=",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"COUNTER_GREATER_EQUAL"
	))
	
	_register_block(BlockDefinition.new(
		"condition_counter_less_equal",
		"Counter <=",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"COUNTER_LESS_EQUAL"
	))
	
	_register_block(BlockDefinition.new(
		"condition_is_facing_north",
		"Is Facing North",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"IS_FACING_NORTH"
	))
	
	_register_block(BlockDefinition.new(
		"condition_is_facing_east",
		"Is Facing East",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"IS_FACING_EAST"
	))
	
	_register_block(BlockDefinition.new(
		"condition_is_facing_south",
		"Is Facing South",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"IS_FACING_SOUTH"
	))
	
	_register_block(BlockDefinition.new(
		"condition_is_facing_west",
		"Is Facing West",
		SCENES_BASE_PATH + "condition_block.tscn",
		"ConditionBlock",
		"condition",
		"",
		"IS_FACING_WEST"
	))
	
	# Case Distinction Blocks (If/Else)
	_register_block(BlockDefinition.new(
		"case_if",
		"If",
		SCENES_BASE_PATH + "case_distinction_block.tscn",
		"CaseDistinctionBlock",
		"case_distinction",
		"IF"
	))
	
	_register_block(BlockDefinition.new(
		"case_if_else",
		"If-Else",
		SCENES_BASE_PATH + "case_distinction_block.tscn",
		"CaseDistinctionBlock",
		"case_distinction",
		"IF_ELSE"
	))
	
	# Loop Blocks
	_register_block(BlockDefinition.new(
		"loop_while",
		"While",
		SCENES_BASE_PATH + "loop_block.tscn",
		"LoopBlock",
		"loop",
		"WHILE"
	))
	
	_register_block(BlockDefinition.new(
		"loop_for",
		"For",
		SCENES_BASE_PATH + "loop_block.tscn",
		"LoopBlock",
		"loop",
		"FOR"
	))
	
	_register_block(BlockDefinition.new(
		"loop_do_while",
		"Do-While",
		SCENES_BASE_PATH + "loop_block.tscn",
		"LoopBlock",
		"loop",
		"DO_WHILE"
	))
	
	# Program Block
	_register_block(BlockDefinition.new(
		"program",
		"Program",
		SCENES_BASE_PATH + "program_block.tscn",
		"ProgramBlock",
		"program"
	))
	
	_initialized = true
	print("[BlockRegistry] Initialisiert mit %d Block-Definitionen" % _block_definitions.size())

## Registriert eine Block-Definition im Registry.
##
## @param definition: Die zu registrierende Block-Definition
static func _register_block(definition: BlockDefinition):
	_block_definitions[definition.block_id] = definition

## Gibt die Definition eines Blocks zurück.
##
## @param block_id: Die eindeutige ID des Blocks
## @return: Die Block-Definition oder null, falls die ID unbekannt ist
static func get_block_definition(block_id: String) -> BlockDefinition:
	if not _initialized:
		initialize()
	
	if not _block_definitions.has(block_id):
		push_error("[BlockRegistry] Unbekannte Block-ID: %s" % block_id)
		return null
	
	return _block_definitions[block_id]

## Gibt den Szenen-Pfad für einen Block zurück.
##
## @param block_id: Die eindeutige ID des Blocks
## @return: Der Pfad zur .tscn Datei oder leerer String
static func get_scene_path(block_id: String) -> String:
	var definition = get_block_definition(block_id)
	return definition.scene_path if definition else ""

## Gibt alle Block-Definitionen einer Kategorie zurück.
##
## @param category: Die Kategorie (z.B. "base", "condition", "loop", "case_distinction")
## @return: Array mit allen Block-Definitionen dieser Kategorie
static func get_blocks_by_category(category: String) -> Array[BlockDefinition]:
	if not _initialized:
		initialize()
	
	var result: Array[BlockDefinition] = []
	for definition in _block_definitions.values():
		if definition.category == category:
			result.append(definition)
	
	return result

## Gibt alle registrierten Block-IDs zurück.
##
## @return: Array mit allen verfügbaren Block-IDs
static func get_all_block_ids() -> Array[String]:
	if not _initialized:
		initialize()
	
	var result: Array[String] = []
	result.assign(_block_definitions.keys())
	return result

## Gibt alle Block-Definitionen zurück.
##
## @return: Array mit allen registrierten Block-Definitionen
static func get_all_definitions() -> Array[BlockDefinition]:
	if not _initialized:
		initialize()
	
	var result: Array[BlockDefinition] = []
	result.assign(_block_definitions.values())
	return result

## Prüft ob eine Block-ID existiert.
##
## @param block_id: Die zu prüfende Block-ID
## @return: true wenn die ID existiert, false sonst
static func has_block(block_id: String) -> bool:
	if not _initialized:
		initialize()
	
	return _block_definitions.has(block_id)

## Mappt einen Level-JSON-Typ zu einer Block-ID.
##
## Wird verwendet um Level-Definitionen in Block-IDs zu übersetzen.
##
## @param level_type: Der Typ aus der Level-Definition
## @return: Die entsprechende Block-ID
static func map_level_type_to_block_id(level_type: String) -> String:
	if has_block(level_type):
		return level_type
	
	# Fallback-Mappings falls nötig
	match level_type:
		"base_blocks":
			return "base"
		"condition_blocks":
			return "condition"
		_:
			return level_type

## Zentrale Autoload-Klasse zum Spawnen von Blöcken.
##
## Kapselt die Logik zum Erstellen und Konfigurieren von Block-Instanzen.
## Als Autoload verfügbar über: BlockSpawner
extends Node

## Referenz zum BlockRegistry-Script
static var BLOCK_REGISTRY: Script = null

## Signal wird gesendet, wenn ein Block gespawnt wurde.
##
## @param block: Der neu gespawnte Block
signal block_spawned(block: DraggableBlock)

## Container, in dem Blöcke gespawnt werden
var blocks_container: Node = null

## Optional: LevelLoader für Level-basierte Spawn-Limits
var level_loader = null

func _ready():
	BLOCK_REGISTRY = load("res://blocks/scripts/core/BlockRegistry.gd")
	BLOCK_REGISTRY.initialize()

## Setzt den Container für gespawnte Blöcke.
##
## @param container: Der Container-Node
func set_blocks_container(container: Node):
	blocks_container = container

## Setzt den LevelLoader für Level-basierte Limits.
##
## @param loader: Der LevelLoader
func set_level_loader(loader):
	level_loader = loader

## Spawnt einen Block anhand seiner Registry-ID.
##
## @param block_id: Die ID aus dem BlockRegistry (z.B. "case_if", "loop_while")
## @param position: Die World-Position, an der der Block gespawnt werden soll
## @param ignore_limits: Wenn true, werden Level-Limits ignoriert (für initiale Blöcke)
## @return: Die gespawnte Block-Instanz oder null bei Fehler
func spawn_block(block_id: String, position: Vector2 = Vector2.ZERO, ignore_limits: bool = false) -> DraggableBlock:
	if not blocks_container:
		push_error("[BlockSpawner] Blocks-Container nicht gesetzt!")
		return null
	
	if not ignore_limits and not _can_spawn_block(block_id):
		return null
	
	var definition = BLOCK_REGISTRY.get_block_definition(block_id)
	if not definition:
		push_error("[BlockSpawner] Keine Definition für Block-ID '%s' gefunden!" % block_id)
		return null
	
	var scene = load(definition.scene_path)
	if not scene:
		push_error("[BlockSpawner] Konnte Szene nicht laden: %s" % definition.scene_path)
		return null
	
	var block_instance = scene.instantiate()
	if not block_instance:
		push_error("[BlockSpawner] Konnte Block nicht instanziieren: %s" % definition.scene_path)
		return null
	
	_pre_configure_block_data(block_instance, definition)
	
	blocks_container.add_child(block_instance)
	
	block_instance.call_deferred("set", "global_position", position)
	
	if block_instance.data:
		var set_data_position = func():
			block_instance.data.position = position
		set_data_position.call_deferred()
	
	_configure_block(block_instance, definition)
	
	block_spawned.emit(block_instance)
	
	# Informiere den LevelLoader, falls vorhanden
	if level_loader and level_loader.has_method("notify_block_spawned"):
		level_loader.notify_block_spawned(block_instance)
	
	return block_instance

## Spawnt mehrere Blöcke auf einmal.
##
## @param block_configs: Array von Dictionaries mit {"block_id": String, "position": Vector2}
## @return: Array der gespawnten Block-Instanzen
func spawn_blocks(block_configs: Array) -> Array[DraggableBlock]:
	var spawned_blocks: Array[DraggableBlock] = []
	
	for config in block_configs:
		if not config is Dictionary:
			push_warning("[BlockSpawner] Ungültige Block-Konfiguration - erwartet Dictionary")
			continue
		
		if not config.has("block_id"):
			push_warning("[BlockSpawner] Block-Konfiguration ohne 'block_id'")
			continue
		
		var block_id: String = config.get("block_id", "")
		var pos: Vector2 = config.get("position", Vector2.ZERO)
		
		var block = spawn_block(block_id, pos)
		if block:
			spawned_blocks.append(block)
	
	return spawned_blocks

## Prüft ob ein Block-Typ gespawnt werden darf (Level-Modus).
##
## @param block_id: Die Block-ID
## @return: true wenn der Block gespawnt werden darf, false sonst
func _can_spawn_block(block_id: String) -> bool:
	if not level_loader:
		return true
	
	if level_loader.has_method("has_blocks_remaining"):
		return level_loader.has_blocks_remaining(block_id)
	
	return true

## Pre-konfiguriert BlockData VOR add_child, damit _ready() den korrekten Zustand sieht.
##
## @param block: Der zu konfigurierende Block
## @param definition: Die Block-Definition aus dem Registry
func _pre_configure_block_data(block: DraggableBlock, definition):
	if not block:
		return
	
	if not block.data:
		if block.has_method("_init_default_data"):
			block._init_default_data()
	
	# Setze action_type für BaseBlocks
	if definition.category == "base" and definition.action_type != "":
		if block.data:
			var action_enum_value = _get_action_type_from_string(definition.action_type)
			block.data.action_type = action_enum_value
	
	match definition.category:
		"case_distinction":
			if block.data and block.data is CaseDistinctionBlockData:
				var case_data = block.data as CaseDistinctionBlockData
				match definition.sub_type:
					"IF":
						case_data.case_type = CaseDistinctionBlockData.CaseType.IF
					"IF_ELSE":
						case_data.case_type = CaseDistinctionBlockData.CaseType.IF_ELSE
		"loop":
			if block.data and block.data is LoopBlockData:
				var loop_data = block.data as LoopBlockData
				match definition.sub_type:
					"WHILE":
						loop_data.loop_type = LoopBlockData.LoopType.WHILE
					"FOR":
						loop_data.loop_type = LoopBlockData.LoopType.FOR
					"DO_WHILE":
						loop_data.loop_type = LoopBlockData.LoopType.DO_WHILE

## Konvertiert einen Action-Type String in den entsprechenden Enum-Wert.
##
## @param action_string: Der Action-Type als String
## @return: Der entsprechende ActionType-Enum-Wert
func _get_action_type_from_string(action_string: String) -> BlockData.ActionType:
	match action_string:
		"MOVE_FORWARD":
			return BlockData.ActionType.MOVE_FORWARD
		"MOVE_BACKWARD":
			return BlockData.ActionType.MOVE_BACKWARD
		"TURN_LEFT":
			return BlockData.ActionType.TURN_LEFT
		"TURN_RIGHT":
			return BlockData.ActionType.TURN_RIGHT
		"JUMP":
			return BlockData.ActionType.JUMP
		"INTERACT":
			return BlockData.ActionType.INTERACT
		"WAIT":
			return BlockData.ActionType.WAIT
		_:
			return BlockData.ActionType.NONE

## Konvertiert einen Condition-Type String in den entsprechenden Enum-Wert.
##
## @param condition_string: Der Condition-Type als String
## @return: Der entsprechende ConditionType-Enum-Wert
func _get_condition_type_from_string(condition_string: String) -> ConditionBlockData.ConditionType:
	match condition_string:
		"CAN_MOVE_FORWARD":
			return ConditionBlockData.ConditionType.CAN_MOVE_FORWARD
		"CAN_MOVE_BACKWARD":
			return ConditionBlockData.ConditionType.CAN_MOVE_BACKWARD
		"HAS_OBJECT_AHEAD":
			return ConditionBlockData.ConditionType.HAS_OBJECT_AHEAD
		"IS_AT_GOAL":
			return ConditionBlockData.ConditionType.IS_AT_GOAL
		"IS_AT_EDGE":
			return ConditionBlockData.ConditionType.IS_AT_EDGE
		"CAN_INTERACT":
			return ConditionBlockData.ConditionType.CAN_INTERACT
		"PATH_IS_CLEAR":
			return ConditionBlockData.ConditionType.PATH_IS_CLEAR
		"REPEAT_COUNT":
			return ConditionBlockData.ConditionType.REPEAT_COUNT
		"REPEAT_UNTIL_EDGE":
			return ConditionBlockData.ConditionType.REPEAT_UNTIL_EDGE
		"REPEAT_UNTIL_GOAL":
			return ConditionBlockData.ConditionType.REPEAT_UNTIL_GOAL
		"REPEAT_UNTIL_OBJECT":
			return ConditionBlockData.ConditionType.REPEAT_UNTIL_OBJECT
		"REPEAT_UNTIL_BLOCKED":
			return ConditionBlockData.ConditionType.REPEAT_UNTIL_BLOCKED
		"COUNTER_EQUALS":
			return ConditionBlockData.ConditionType.COUNTER_EQUALS
		"COUNTER_NOT_EQUALS":
			return ConditionBlockData.ConditionType.COUNTER_NOT_EQUALS
		"COUNTER_GREATER_THAN":
			return ConditionBlockData.ConditionType.COUNTER_GREATER_THAN
		"COUNTER_LESS_THAN":
			return ConditionBlockData.ConditionType.COUNTER_LESS_THAN
		"COUNTER_GREATER_EQUAL":
			return ConditionBlockData.ConditionType.COUNTER_GREATER_EQUAL
		"COUNTER_LESS_EQUAL":
			return ConditionBlockData.ConditionType.COUNTER_LESS_EQUAL
		"IS_FACING_NORTH":
			return ConditionBlockData.ConditionType.IS_FACING_NORTH
		"IS_FACING_EAST":
			return ConditionBlockData.ConditionType.IS_FACING_EAST
		"IS_FACING_SOUTH":
			return ConditionBlockData.ConditionType.IS_FACING_SOUTH
		"IS_FACING_WEST":
			return ConditionBlockData.ConditionType.IS_FACING_WEST
		_:
			return ConditionBlockData.ConditionType.CAN_MOVE_FORWARD

## Konfiguriert einen Block nach dem Spawnen.
##
## @param block: Der zu konfigurierende Block
## @param definition: Die Block-Definition aus dem Registry
func _configure_block(block: DraggableBlock, definition):
	if not block or not is_instance_valid(block):
		return
	
	if block.has_method("set_block_name"):
		block.call("set_block_name", definition.block_name)
	elif "block_name" in block:
		block.block_name = definition.block_name
	
	match definition.category:
		"case_distinction":
			_configure_case_distinction_block(block, definition.sub_type)
		"loop":
			_configure_loop_block(block, definition.sub_type)
		"condition":
			_configure_condition_block(block, definition)
		"base":
			_configure_base_block(block, definition)
			_configure_base_block(block, definition)

## Konfiguriert einen Case-Distinction-Block.
##
## @param block: Der zu konfigurierende Block
## @param sub_type: Der Sub-Typ ("IF" oder "IF_ELSE")
func _configure_case_distinction_block(block: Node, sub_type: String):
	if not block is CaseDistinctionBlock:
		return
	
	var case_block = block as CaseDistinctionBlock
	
	match sub_type:
		"IF":
			if case_block.get_case_type() != CaseDistinctionBlock.CaseType.IF:
				case_block.set_case_type(CaseDistinctionBlock.CaseType.IF)
		"IF_ELSE":
			if case_block.get_case_type() != CaseDistinctionBlock.CaseType.IF_ELSE:
				case_block.set_case_type(CaseDistinctionBlock.CaseType.IF_ELSE)

## Konfiguriert einen Loop-Block.
##
## @param block: Der zu konfigurierende Block
## @param sub_type: Der Sub-Typ ("WHILE", "FOR" oder "DO_WHILE")
func _configure_loop_block(block: Node, sub_type: String):
	if not block is LoopBlock:
		return
	
	var loop_block = block as LoopBlock
	
	match sub_type:
		"WHILE":
			if loop_block.get_loop_type() != LoopBlock.LoopType.WHILE:
				loop_block.set_loop_type(LoopBlock.LoopType.WHILE)
		"FOR":
			if loop_block.get_loop_type() != LoopBlock.LoopType.FOR:
				loop_block.set_loop_type(LoopBlock.LoopType.FOR)
		"DO_WHILE":
			if loop_block.get_loop_type() != LoopBlock.LoopType.DO_WHILE:
				loop_block.set_loop_type(LoopBlock.LoopType.DO_WHILE)

## Konfiguriert einen Condition-Block.
##
## @param block: Der zu konfigurierende Block
## @param definition: Die Block-Definition aus dem Registry
func _configure_condition_block(block: Node, definition):
	if not block is ConditionBlock:
		return
	
	var condition_block = block as ConditionBlock
	
	# Setze condition_type wenn in der Definition vorhanden
	if definition.action_type != "":
		var condition_enum_value = _get_condition_type_from_string(definition.action_type)
		condition_block.set_condition_type(condition_enum_value)

## Konfiguriert einen Base-Block.
##
## @param block: Der zu konfigurierende Block
## @param definition: Die Block-Definition aus dem Registry
func _configure_base_block(block: Node, definition):
	if not block is BaseBlock:
		return
	
	var base_block = block as BaseBlock
	
	# Setze action_type wenn in der Definition vorhanden
	if definition.action_type != "":
		var action_enum_value = _get_action_type_from_string(definition.action_type)
		base_block.set_action_type(action_enum_value)

## Spawnt einen Block aus BlockData (für Level-Loading).
##
## @param data: Die BlockData mit der Konfiguration
## @param position: Die Spawn-Position
## @return: Der gespawnte Block oder null bei Fehler
func spawn_from_data(data: BlockData, position: Vector2 = Vector2.ZERO) -> DraggableBlock:
	if not data:
		push_error("[BlockSpawner] Keine BlockData übergeben!")
		return null
	
	var block_id = _get_block_id_from_data(data)
	if block_id.is_empty():
		push_error("[BlockSpawner] Konnte Block-ID nicht aus BlockData ermitteln!")
		return null
	
	var block = spawn_block(block_id, position)
	if not block:
		return null
	
	if block.has_method("set_data"):
		block.set_data(data)
	elif "data" in block:
		block.data = data
	
	return block

## Bestimmt die Block-ID aus BlockData.
##
## Analysiert die BlockData und ermittelt die entsprechende Registry-ID.
##
## @param data: Die BlockData
## @return: Die Block-ID oder leerer String bei Fehler
func _get_block_id_from_data(data: BlockData) -> String:
	match data.block_type:
		BlockData.BlockType.BASE:
			# Prüfe auf action_type
			match data.action_type:
				BlockData.ActionType.MOVE_FORWARD:
					return "base_move_forward"
				BlockData.ActionType.MOVE_BACKWARD:
					return "base_move_backward"
				BlockData.ActionType.TURN_LEFT:
					return "base_turn_left"
				BlockData.ActionType.TURN_RIGHT:
					return "base_turn_right"
				BlockData.ActionType.JUMP:
					return "base_jump"
				BlockData.ActionType.INTERACT:
					return "base_interact"
				BlockData.ActionType.WAIT:
					return "base_wait"
				_:
					return "base"
		BlockData.BlockType.CONDITION:
			if data is ConditionBlockData:
				match (data as ConditionBlockData).condition_type:
					ConditionBlockData.ConditionType.CAN_MOVE_FORWARD:
						return "condition_can_move_forward"
					ConditionBlockData.ConditionType.CAN_MOVE_BACKWARD:
						return "condition_can_move_backward"
					ConditionBlockData.ConditionType.HAS_OBJECT_AHEAD:
						return "condition_has_object_ahead"
					ConditionBlockData.ConditionType.IS_AT_GOAL:
						return "condition_is_at_goal"
					ConditionBlockData.ConditionType.IS_AT_EDGE:
						return "condition_is_at_edge"
					ConditionBlockData.ConditionType.CAN_INTERACT:
						return "condition_can_interact"
					ConditionBlockData.ConditionType.PATH_IS_CLEAR:
						return "condition_path_is_clear"
					ConditionBlockData.ConditionType.REPEAT_COUNT:
						return "condition_repeat_count"
					ConditionBlockData.ConditionType.REPEAT_UNTIL_EDGE:
						return "condition_repeat_until_edge"
					ConditionBlockData.ConditionType.REPEAT_UNTIL_GOAL:
						return "condition_repeat_until_goal"
					ConditionBlockData.ConditionType.REPEAT_UNTIL_OBJECT:
						return "condition_repeat_until_object"
					ConditionBlockData.ConditionType.REPEAT_UNTIL_BLOCKED:
						return "condition_repeat_until_blocked"
					ConditionBlockData.ConditionType.COUNTER_EQUALS:
						return "condition_counter_equals"
					ConditionBlockData.ConditionType.COUNTER_NOT_EQUALS:
						return "condition_counter_not_equals"
					ConditionBlockData.ConditionType.COUNTER_GREATER_THAN:
						return "condition_counter_greater"
					ConditionBlockData.ConditionType.COUNTER_LESS_THAN:
						return "condition_counter_less"
					ConditionBlockData.ConditionType.COUNTER_GREATER_EQUAL:
						return "condition_counter_greater_equal"
					ConditionBlockData.ConditionType.COUNTER_LESS_EQUAL:
						return "condition_counter_less_equal"
					ConditionBlockData.ConditionType.IS_FACING_NORTH:
						return "condition_is_facing_north"
					ConditionBlockData.ConditionType.IS_FACING_EAST:
						return "condition_is_facing_east"
					ConditionBlockData.ConditionType.IS_FACING_SOUTH:
						return "condition_is_facing_south"
					ConditionBlockData.ConditionType.IS_FACING_WEST:
						return "condition_is_facing_west"
			return "condition"
		BlockData.BlockType.CASE_DISTINCTION:
			if data is CaseDistinctionBlockData:
				match (data as CaseDistinctionBlockData).case_type:
					CaseDistinctionBlockData.CaseType.IF:
						return "case_if"
					CaseDistinctionBlockData.CaseType.IF_ELSE:
						return "case_if_else"
			return "case_if_else"
		BlockData.BlockType.LOOP:
			if data is LoopBlockData:
				match (data as LoopBlockData).loop_type:
					LoopBlockData.LoopType.WHILE:
						return "loop_while"
					LoopBlockData.LoopType.FOR:
						return "loop_for"
					LoopBlockData.LoopType.DO_WHILE:
						return "loop_do_while"
			return "loop_while"
	
	return ""

## Löscht einen Block und erhält die Struktur.
##
## Entfernt einen Block aus der Szene und verbindet die benachbarten Blöcke.
## Geschützte Blöcke (delete_protection = true) können nicht gelöscht werden.
##
## @param block: Der zu löschende Block (oder null für aktuell selektierten Block)
## @return: true wenn erfolgreich gelöscht, false sonst
func delete_block(block: DraggableBlock = null) -> bool:
	# Verwende selektierten Block falls keiner übergeben wurde
	if not block:
		block = DraggableBlock.selected_block
	
	if not block or not is_instance_valid(block):
		push_warning("[BlockSpawner] Kein gültiger Block zum Löschen")
		return false
	
	if block.delete_protection:
		print("[BlockSpawner] Block '%s' is protected by delete_protection" % block.block_name)
		return false
	
	print("[BlockSpawner] Deleting block: %s" % block.block_name)
	
	if block.has_method("_deselect_block"):
		block._deselect_block()
	else:
		block.is_selected = false
		DraggableBlock.selected_block = null
		block.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	var top = block.block_above
	var bottom = block.block_below
	var parent = block.instruction_parent
	
	if top and is_instance_valid(top) and bottom and is_instance_valid(bottom):
		top.block_below = bottom
		bottom.block_above = top
		
		var head = top.get_chain_head()
		if head and is_instance_valid(head):
			head.reflow_chain_with_anchor(head.global_position)
	
	elif top and is_instance_valid(top):
		top.block_below = null
	
	elif bottom and is_instance_valid(bottom):
		bottom.block_above = null
	
	if parent and is_instance_valid(parent):
		if parent is ContainerBlock:
			for zone_data in parent.instruction_zones:
				var zone_child = zone_data.get_first_child()
				if zone_child == block:
					if bottom and is_instance_valid(bottom):
						parent.set_instruction_zone_child(zone_data.zone_name, bottom)
						bottom.block_above = null
						bottom.instruction_parent = parent
					else:
						parent.set_instruction_zone_child(zone_data.zone_name, null)
					break
			
			if parent.has_method("_update_block_size"):
				parent.call_deferred("_update_block_size")
	
	if "condition_parent" in block:
		var cond_parent = block.get("condition_parent")
		if cond_parent and is_instance_valid(cond_parent):
			if cond_parent.has_method("clear_condition_zone_child"):
				if "condition_zones" in cond_parent:
					for zone_data in cond_parent.condition_zones:
						if zone_data.get_child() == block:
							cond_parent.clear_condition_zone_child(zone_data.zone_name, block)
							break
	
	block.queue_free()
	
	print("[BlockSpawner] Block successfully deleted")
	return true

## Löscht alle Blöcke (außer geschützte).
##
## Entfernt alle DraggableBlock-Instanzen aus dem Container.
## Geschützte Blöcke können optional auch gelöscht werden.
##
## @param include_protected: Wenn true, werden auch geschützte Blöcke gelöscht
## @return: Anzahl der gelöschten Blöcke
func delete_all_blocks(include_protected: bool = false) -> int:
	if not blocks_container:
		push_warning("[BlockSpawner] Blocks-Container not set!")
		return 0
	
	var deleted_count = 0
	var blocks_to_delete: Array[DraggableBlock] = []
	
	for child in blocks_container.get_children():
		if child is DraggableBlock:
			var block = child as DraggableBlock
			if include_protected or not block.delete_protection:
				blocks_to_delete.append(block)
	
	for block in blocks_to_delete:
		if delete_block(block):
			deleted_count += 1
	
	print("[BlockSpawner] %d blocks deleted" % deleted_count)
	return deleted_count

## Kontextmenü zum Spawnen neuer Blöcke.
##
## Wird mit Strg+A oder Strg+Rechtsklick aufgerufen.
## Bietet Untermenüs für verschiedene Block-Typen: Base Actions, Conditions, Cases, Loops.
class_name BlockSpawnMenu
extends PopupMenu

## Signal wird gesendet wenn ein Block gespawnt wurde
##
## @param block: Der gespawnte Block
signal block_spawned(block: DraggableBlock)

## Preload BlockRegistry für sichere Referenzierung
const BLOCK_REGISTRY = preload("res://blocks/scripts/core/BlockRegistry.gd")

## Menü-IDs für alle verfügbaren Block-Typen
enum MenuID {
	CASE_LOGIC,
	CASE_IF,
	CASE_IF_ELSE,
	LOOP_LOGIC,
	LOOP_WHILE,
	LOOP_FOR,
	LOOP_DO_WHILE,
	CONDITION_LOGIC,
	# Boolean Conditions
	CONDITION_CAN_MOVE_FORWARD,
	CONDITION_CAN_MOVE_BACKWARD,
	CONDITION_HAS_OBJECT_AHEAD,
	CONDITION_IS_AT_GOAL,
	CONDITION_IS_AT_EDGE,
	CONDITION_CAN_INTERACT,
	CONDITION_PATH_IS_CLEAR,
	# Loop Conditions
	CONDITION_REPEAT_COUNT,
	CONDITION_REPEAT_UNTIL_EDGE,
	CONDITION_REPEAT_UNTIL_GOAL,
	CONDITION_REPEAT_UNTIL_OBJECT,
	CONDITION_REPEAT_UNTIL_BLOCKED,
	# Counter Conditions
	CONDITION_COUNTER_EQUALS,
	CONDITION_COUNTER_NOT_EQUALS,
	CONDITION_COUNTER_GREATER,
	CONDITION_COUNTER_LESS,
	CONDITION_COUNTER_GREATER_EQUAL,
	CONDITION_COUNTER_LESS_EQUAL,
	# Directional Conditions
	CONDITION_IS_FACING_NORTH,
	CONDITION_IS_FACING_EAST,
	CONDITION_IS_FACING_SOUTH,
	CONDITION_IS_FACING_WEST,
	BASE_BLOCK,
	BASE_MOVE_FORWARD,
	BASE_MOVE_BACKWARD,
	BASE_TURN_LEFT,
	BASE_TURN_RIGHT,
	BASE_JUMP,
	BASE_INTERACT,
	BASE_WAIT
}

## Untermenü für Case-Distinction-Blöcke
var case_submenu: PopupMenu

## Untermenü für Loop-Blöcke
var loop_submenu: PopupMenu

## Untermenü für Condition-Blöcke
var condition_submenu: PopupMenu

## Untermenü für Character-Conditions
var condition_character_submenu: PopupMenu

## Untermenü für Math-Conditions
var condition_math_submenu: PopupMenu

## Untermenü für Base-Action-Blöcke
var base_submenu: PopupMenu

## Spawn-Position (wird bei jedem Öffnen gesetzt)
var spawn_position: Vector2 = Vector2.ZERO

## Referenz zur Blocks-Node (Parent für neue Blöcke)
var blocks_container: Node = null

## Referenz zum LevelLoader (falls vorhanden)
var level_loader: LevelLoader = null

## Initialisiert das Menü und alle Untermenüs.
func _ready():
	_setup_canvas_layer()
	
	case_submenu = PopupMenu.new()
	case_submenu.name = "CaseSubmenu"
	case_submenu.add_item("If", MenuID.CASE_IF)
	case_submenu.add_item("If-Else", MenuID.CASE_IF_ELSE)
	case_submenu.id_pressed.connect(_on_case_submenu_id_pressed)
	add_child(case_submenu)
	
	loop_submenu = PopupMenu.new()
	loop_submenu.name = "LoopSubmenu"
	loop_submenu.add_item("While", MenuID.LOOP_WHILE)
	loop_submenu.add_item("For", MenuID.LOOP_FOR)
	loop_submenu.add_item("Do-While", MenuID.LOOP_DO_WHILE)
	loop_submenu.id_pressed.connect(_on_loop_submenu_id_pressed)
	add_child(loop_submenu)
	
	# Character Conditions Submenu (für Character-bezogene Checks)
	condition_character_submenu = PopupMenu.new()
	condition_character_submenu.name = "ConditionCharacterSubmenu"
	condition_character_submenu.add_item("Can Move Forward", MenuID.CONDITION_CAN_MOVE_FORWARD)
	condition_character_submenu.add_item("Can Move Backward", MenuID.CONDITION_CAN_MOVE_BACKWARD)
	condition_character_submenu.add_item("Has Object Ahead", MenuID.CONDITION_HAS_OBJECT_AHEAD)
	condition_character_submenu.add_item("Is At Goal", MenuID.CONDITION_IS_AT_GOAL)
	condition_character_submenu.add_item("Is At Edge", MenuID.CONDITION_IS_AT_EDGE)
	condition_character_submenu.add_item("Can Interact", MenuID.CONDITION_CAN_INTERACT)
	condition_character_submenu.add_item("Path Is Clear", MenuID.CONDITION_PATH_IS_CLEAR)
	condition_character_submenu.add_separator()
	condition_character_submenu.add_item("Is Facing North", MenuID.CONDITION_IS_FACING_NORTH)
	condition_character_submenu.add_item("Is Facing East", MenuID.CONDITION_IS_FACING_EAST)
	condition_character_submenu.add_item("Is Facing South", MenuID.CONDITION_IS_FACING_SOUTH)
	condition_character_submenu.add_item("Is Facing West", MenuID.CONDITION_IS_FACING_WEST)
	condition_character_submenu.id_pressed.connect(_on_condition_submenu_id_pressed)
	
	# Boolean Algebra Conditions Submenu (für Counter/Loop-Logik)
	condition_math_submenu = PopupMenu.new()
	condition_math_submenu.name = "ConditionMathSubmenu"
	condition_math_submenu.add_item("Repeat X Times", MenuID.CONDITION_REPEAT_COUNT)
	condition_math_submenu.add_item("Repeat Until Edge", MenuID.CONDITION_REPEAT_UNTIL_EDGE)
	condition_math_submenu.add_item("Repeat Until Goal", MenuID.CONDITION_REPEAT_UNTIL_GOAL)
	condition_math_submenu.add_item("Repeat Until Object", MenuID.CONDITION_REPEAT_UNTIL_OBJECT)
	condition_math_submenu.add_item("Repeat Until Blocked", MenuID.CONDITION_REPEAT_UNTIL_BLOCKED)
	condition_math_submenu.add_separator()
	condition_math_submenu.add_item("Counter ==", MenuID.CONDITION_COUNTER_EQUALS)
	condition_math_submenu.add_item("Counter !=", MenuID.CONDITION_COUNTER_NOT_EQUALS)
	condition_math_submenu.add_item("Counter >", MenuID.CONDITION_COUNTER_GREATER)
	condition_math_submenu.add_item("Counter <", MenuID.CONDITION_COUNTER_LESS)
	condition_math_submenu.add_item("Counter >=", MenuID.CONDITION_COUNTER_GREATER_EQUAL)
	condition_math_submenu.add_item("Counter <=", MenuID.CONDITION_COUNTER_LESS_EQUAL)
	condition_math_submenu.id_pressed.connect(_on_condition_submenu_id_pressed)
	
	condition_submenu = PopupMenu.new()
	condition_submenu.name = "ConditionSubmenu"
	# Füge die Submenüs als Einträge hinzu
	condition_submenu.add_child(condition_character_submenu)
	condition_submenu.add_submenu_item("Character", "ConditionCharacterSubmenu")
	condition_submenu.add_child(condition_math_submenu)
	condition_submenu.add_submenu_item("Math", "ConditionMathSubmenu")
	add_child(condition_submenu)
	
	base_submenu = PopupMenu.new()
	base_submenu.name = "BaseSubmenu"
	base_submenu.add_item("Move Forward", MenuID.BASE_MOVE_FORWARD)
	base_submenu.add_item("Move Backward", MenuID.BASE_MOVE_BACKWARD)
	base_submenu.add_item("Turn Left", MenuID.BASE_TURN_LEFT)
	base_submenu.add_item("Turn Right", MenuID.BASE_TURN_RIGHT)
	base_submenu.add_item("Jump", MenuID.BASE_JUMP)
	base_submenu.add_item("Interact", MenuID.BASE_INTERACT)
	base_submenu.add_item("Wait", MenuID.BASE_WAIT)
	base_submenu.id_pressed.connect(_on_base_submenu_id_pressed)
	add_child(base_submenu)
	
	add_submenu_item("Base Actions", "BaseSubmenu")
	add_separator()
	add_submenu_item("Conditional Logic", "ConditionSubmenu")
	add_submenu_item("Case Distinction Logic", "CaseSubmenu")
	add_submenu_item("Loop Logic", "LoopSubmenu")
	
	id_pressed.connect(_on_main_menu_id_pressed)

	_find_blocks_container()
	_find_level_loader()

## Verschiebt das Menü in einen eigenen CanvasLayer, damit es vom Canvas-Zoom unabhängig ist.
func _setup_canvas_layer():
	var parent = get_parent()
	if parent is CanvasLayer:
		return
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "BlockSpawnMenuLayer"
	canvas_layer.layer = 10000
	
	if parent:
		parent.call_deferred("add_child", canvas_layer)
		
		parent.call_deferred("remove_child", self)
		canvas_layer.call_deferred("add_child", self)

## Verarbeitet Eingaben um das Menü zu schließen.
##
## @param event: Das Input-Event
func _input(event: InputEvent):
	if visible and event.is_action_pressed("close_overlays"):
		hide()
		get_viewport().set_input_as_handled()


## Löscht den aktuell selektierten Block.
##
## Delegiert an BlockSpawner für konsistente Block-Verwaltung.
func delete_selected_block():
	if not BlockSpawner:
		push_error("[BlockSpawnMenu] BlockSpawner-Autoload nicht verfügbar!")
		return
	
	# Delegiere an BlockSpawner
	BlockSpawner.delete_block()

## Findet den Blocks-Container in der Szene.
func _find_blocks_container():
	# Versuche zuerst über die Root-Node
	var root = get_tree().root
	if root:
		var ui_control = root.get_node_or_null("UI_Control")
		if ui_control:
			blocks_container = ui_control.get_node_or_null("Blocks")
	
	# Fallback: Suche in der gesamten Szene
	if not blocks_container:
		var all_nodes = get_tree().get_nodes_in_group("blocks_container")
		if all_nodes.size() > 0:
			blocks_container = all_nodes[0]
	
	# Konfiguriere BlockSpawner Autoload
	if BlockSpawner and blocks_container:
		BlockSpawner.set_blocks_container(blocks_container)

## Findet den LevelLoader in der Szene.
func _find_level_loader():
	var root = get_tree().root
	if root:
		var ui_control = root.get_node_or_null("UI_Control")
		if ui_control:
			level_loader = ui_control.get_node_or_null("LevelLoader")
	
	if not level_loader:
		var all_loaders = get_tree().get_nodes_in_group("level_loader")
		if all_loaders.size() > 0:
			level_loader = all_loaders[0]
	
	# Konfiguriere BlockSpawner Autoload
	if BlockSpawner and level_loader:
		BlockSpawner.set_level_loader(level_loader)
	
	if not level_loader:
		print("[BlockSpawnMenu] Kein LevelLoader gefunden - Freies Spawning erlaubt")

## Zeigt das Menü an der angegebenen Position an.
##
## @param world_pos: Position in World-Space für das Spawnen der Blöcke
## @param screen_pos: Position in Screen-Space für die Anzeige des Menüs
func show_at_position(world_pos: Vector2, screen_pos: Vector2 = Vector2.ZERO):
	spawn_position = world_pos
	
	if screen_pos == Vector2.ZERO:
		screen_pos = world_pos
	
	position = Vector2i(screen_pos)
	popup()

## Handler für Case Distinction Logic Untermenü.
##
## @param id: Die Menü-ID
func _on_case_submenu_id_pressed(id: int):
	match id:
		MenuID.CASE_IF:
			_spawn_block_by_id("case_if")
		MenuID.CASE_IF_ELSE:
			_spawn_block_by_id("case_if_else")

## Handler für Loop Logic Untermenü.
##
## @param id: Die Menü-ID
func _on_loop_submenu_id_pressed(id: int):
	match id:
		MenuID.LOOP_WHILE:
			_spawn_block_by_id("loop_while")
		MenuID.LOOP_FOR:
			_spawn_block_by_id("loop_for")
		MenuID.LOOP_DO_WHILE:
			_spawn_block_by_id("loop_do_while")

## Handler für Base Block Untermenü.
##
## @param id: Die Menü-ID
func _on_base_submenu_id_pressed(id: int):
	match id:
		MenuID.BASE_MOVE_FORWARD:
			_spawn_block_by_id("base_move_forward")
		MenuID.BASE_MOVE_BACKWARD:
			_spawn_block_by_id("base_move_backward")
		MenuID.BASE_TURN_LEFT:
			_spawn_block_by_id("base_turn_left")
		MenuID.BASE_TURN_RIGHT:
			_spawn_block_by_id("base_turn_right")
		MenuID.BASE_JUMP:
			_spawn_block_by_id("base_jump")
		MenuID.BASE_INTERACT:
			_spawn_block_by_id("base_interact")
		MenuID.BASE_WAIT:
			_spawn_block_by_id("base_wait")

## Handler für Condition Logic Untermenü.
##
## @param id: Die Menü-ID
func _on_condition_submenu_id_pressed(id: int):
	match id:
		# Boolean Conditions
		MenuID.CONDITION_CAN_MOVE_FORWARD:
			_spawn_condition_block(ConditionBlockData.ConditionType.CAN_MOVE_FORWARD)
		MenuID.CONDITION_CAN_MOVE_BACKWARD:
			_spawn_condition_block(ConditionBlockData.ConditionType.CAN_MOVE_BACKWARD)
		MenuID.CONDITION_HAS_OBJECT_AHEAD:
			_spawn_condition_block(ConditionBlockData.ConditionType.HAS_OBJECT_AHEAD)
		MenuID.CONDITION_IS_AT_GOAL:
			_spawn_condition_block(ConditionBlockData.ConditionType.IS_AT_GOAL)
		MenuID.CONDITION_IS_AT_EDGE:
			_spawn_condition_block(ConditionBlockData.ConditionType.IS_AT_EDGE)
		MenuID.CONDITION_CAN_INTERACT:
			_spawn_condition_block(ConditionBlockData.ConditionType.CAN_INTERACT)
		MenuID.CONDITION_PATH_IS_CLEAR:
			_spawn_condition_block(ConditionBlockData.ConditionType.PATH_IS_CLEAR)
		# Loop Conditions
		MenuID.CONDITION_REPEAT_COUNT:
			_spawn_condition_block(ConditionBlockData.ConditionType.REPEAT_COUNT)
		MenuID.CONDITION_REPEAT_UNTIL_EDGE:
			_spawn_condition_block(ConditionBlockData.ConditionType.REPEAT_UNTIL_EDGE)
		MenuID.CONDITION_REPEAT_UNTIL_GOAL:
			_spawn_condition_block(ConditionBlockData.ConditionType.REPEAT_UNTIL_GOAL)
		MenuID.CONDITION_REPEAT_UNTIL_OBJECT:
			_spawn_condition_block(ConditionBlockData.ConditionType.REPEAT_UNTIL_OBJECT)
		MenuID.CONDITION_REPEAT_UNTIL_BLOCKED:
			_spawn_condition_block(ConditionBlockData.ConditionType.REPEAT_UNTIL_BLOCKED)
		# Counter Conditions
		MenuID.CONDITION_COUNTER_EQUALS:
			_spawn_condition_block(ConditionBlockData.ConditionType.COUNTER_EQUALS)
		MenuID.CONDITION_COUNTER_NOT_EQUALS:
			_spawn_condition_block(ConditionBlockData.ConditionType.COUNTER_NOT_EQUALS)
		MenuID.CONDITION_COUNTER_GREATER:
			_spawn_condition_block(ConditionBlockData.ConditionType.COUNTER_GREATER_THAN)
		MenuID.CONDITION_COUNTER_LESS:
			_spawn_condition_block(ConditionBlockData.ConditionType.COUNTER_LESS_THAN)
		MenuID.CONDITION_COUNTER_GREATER_EQUAL:
			_spawn_condition_block(ConditionBlockData.ConditionType.COUNTER_GREATER_EQUAL)
		MenuID.CONDITION_COUNTER_LESS_EQUAL:
			_spawn_condition_block(ConditionBlockData.ConditionType.COUNTER_LESS_EQUAL)
		# Directional Conditions
		MenuID.CONDITION_IS_FACING_NORTH:
			_spawn_condition_block(ConditionBlockData.ConditionType.IS_FACING_NORTH)
		MenuID.CONDITION_IS_FACING_EAST:
			_spawn_condition_block(ConditionBlockData.ConditionType.IS_FACING_EAST)
		MenuID.CONDITION_IS_FACING_SOUTH:
			_spawn_condition_block(ConditionBlockData.ConditionType.IS_FACING_SOUTH)
		MenuID.CONDITION_IS_FACING_WEST:
			_spawn_condition_block(ConditionBlockData.ConditionType.IS_FACING_WEST)

## Spawnt einen Condition-Block mit voreingestelltem Typ.
##
## @param condition_type: Der Typ der Condition
func _spawn_condition_block(condition_type: ConditionBlockData.ConditionType):
	if not BlockSpawner:
		return
	
	if not blocks_container:
		_find_blocks_container()
		if not blocks_container:
			return
	
	var block_instance = BlockSpawner.spawn_block("condition", spawn_position)
	
	
	if block_instance and block_instance is ConditionBlock:
		
		await get_tree().process_frame
		
		if block_instance.data and block_instance.data is ConditionBlockData:
			print("[BlockSpawnMenu] Setze Condition-Typ: %d (%s)" % [condition_type, ConditionBlockData.get_display_name(condition_type)])
			block_instance.data.condition_type = condition_type
			block_instance._sync_from_data()
			print("[BlockSpawnMenu] _sync_from_data() abgeschlossen")
		
		block_spawned.emit(block_instance)
		
		hide()
	else:
		print("[BlockSpawnMenu] Konnte Condition-Block nicht spawnen")

## Handler für Haupt-Menü.
##
## @param _id: Die Menü-ID (nicht verwendet)
func _on_main_menu_id_pressed(_id: int):
	# Haupt-Menü hat aktuell keine direkten Items mehr
	pass

## Spawnt einen Block anhand seiner Registry-ID.
##
## @param block_id: Die Registry-ID des Blocks
func _spawn_block_by_id(block_id: String):
	if not BlockSpawner:
		push_error("[BlockSpawnMenu] BlockSpawner-Autoload nicht verfügbar!")
		return
	
	if not blocks_container:
		_find_blocks_container()
		if not blocks_container:
			push_error("[BlockSpawnMenu] Blocks-Container nicht gefunden!")
			return
	
	var block_instance = BlockSpawner.spawn_block(block_id, spawn_position)
	
	if block_instance:
		block_spawned.emit(block_instance)
		
		print("[BlockSpawnMenu] Block gespawnt an Position %v" % spawn_position)
		
		hide()
	else:
		print("[BlockSpawnMenu] Konnte Block '%s' nicht spawnen" % block_id)

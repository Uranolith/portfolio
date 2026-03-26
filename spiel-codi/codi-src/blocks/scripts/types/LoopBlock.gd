## Loop-Block für Schleifen (While, Do-While, For).
##
## Implementiert verschiedene Schleifentypen mit einer Condition-Zone
## und einer Instruction-Zone für den Loop-Body.
## Kann den Loop-Typ dynamisch zwischen WHILE, DO_WHILE und FOR wechseln.
class_name LoopBlock
extends ContainerBlock

## Unterstützte Loop-Typen
enum LoopType {
	WHILE,      ## While-Schleife (Bedingung vor dem Body)
	DO_WHILE,   ## Do-While-Schleife (Bedingung nach dem Body)
	FOR         ## For-Schleife (feste Anzahl Wiederholungen)
}

## Condition-Zone Indikator
@export var snap_condition_color_rect: ColorRect

## Instruction-Zone Indikator
@export var snap_instruction_color_rect: ColorRect

## Container für For-Loop-Darstellung (oben)
@export var top_for_container_h_box_container: HBoxContainer

## Container für While-Loop-Darstellung (oben)
@export var top_while_container_panel: Panel

## Container für Do-While-Loop-Darstellung (unten)
@export var bottom_do_container_panel: Panel

## Container für Do-While-Loop-Darstellung (oben)
@export var top_do_container_panel: Panel

## Innerer Container für Instructions
@export var inner_container_panel: Panel

## Label für den Instruction-Bereich
@export var inner_label_label: Label

## Label für die Condition
@export var condition_label_label: Label

@onready var snap_indicator_condition: ColorRect = snap_condition_color_rect
@onready var snap_indicator_instruction: ColorRect = snap_instruction_color_rect

@onready var top_for_container = top_for_container_h_box_container
@onready var top_while_container = top_while_container_panel
@onready var bottom_do_container = bottom_do_container_panel
@onready var top_do_container = top_do_container_panel
@onready var inner_container = inner_container_panel
@onready var inner_label = inner_label_label
@onready var condition_label: Label = condition_label_label

## Initiale innere Höhe des Loop-Bodys
var _initial_inner_height: float = 0.0

## SnapZone für Instructions
var instruction_zone: SnapZone = null

## Property für Godot-Szenen-Kompatibilität (fängt @export loop_type aus alten Szenen ab).
##
## Zugriff auf den Loop-Typ über LoopBlockData.
var loop_type: LoopType:
	get:
		return get_loop_type()
	set(value):
		set_loop_type(value)

## Gibt den aktuellen Loop-Typ zurück.
##
## Liest den Typ aus LoopBlockData und konvertiert ihn.
##
## @return: Der aktuelle LoopType
func get_loop_type() -> LoopType:
	if data and data is LoopBlockData:
		# Konvertiere LoopBlockData.LoopType zu LoopBlock.LoopType
		match (data as LoopBlockData).loop_type:
			LoopBlockData.LoopType.WHILE:
				return LoopType.WHILE
			LoopBlockData.LoopType.DO_WHILE:
				return LoopType.DO_WHILE
			LoopBlockData.LoopType.FOR:
				return LoopType.FOR
	return LoopType.WHILE

## Setzt den Loop-Typ und aktualisiert die Darstellung.
##
## Konvertiert den LoopBlock.LoopType zu LoopBlockData.LoopType.
##
## @param value: Der neue LoopType
func set_loop_type(value: LoopType):
	if data and data is LoopBlockData:
		# Konvertiere LoopBlock.LoopType zu LoopBlockData.LoopType
		match value:
			LoopType.WHILE:
				(data as LoopBlockData).loop_type = LoopBlockData.LoopType.WHILE
			LoopType.DO_WHILE:
				(data as LoopBlockData).loop_type = LoopBlockData.LoopType.DO_WHILE
			LoopType.FOR:
				(data as LoopBlockData).loop_type = LoopBlockData.LoopType.FOR
		
		if is_inside_tree():
			_update_loop_type()

func _ready():
	snap_category = SnapCategory.FLOW
	
	_initialize_sizes()
	
	# Frühe Phase: Zonen-Konfigurationen erstellen (VOR super._ready())
	_setup_loop_instruction_zones_early()
	_setup_loop_condition_zones_early()
		
	super._ready()
	
	# Späte Phase: SnapZones erstellen und verlinken (NACH super._ready())
	_setup_custom_snap_zones()
	_link_instruction_zones()
	_link_condition_zones()
	
	# Registriere ALLE Zonen-Labels beim Renderer (nach dem Linken!)
	if USE_LABEL_RENDERER:
		_setup_zone_labels_for_renderer()
	
	_update_loop_type()
	
	await get_tree().process_frame

	_update_indicator_positions()
	
	_hide_snap_indicators()

## Setup für die Condition-Zone (frühe Phase - VOR super._ready()).
##
## Konfiguriert die Zone für die Loop-Bedingung.
func _setup_loop_condition_zones_early():
	var cond_config := {
		"zone_name": "case",
		"display_label": "Bedingung",
		"indicator": snap_indicator_condition,
		"label": condition_label,
		"offset_x": 10.0,
		"offset_y": 10.0,
		"accepts": indicator_condition_accepts
	}
	setup_condition_zones([cond_config])

## Setup für die Instruction-Zone (frühe Phase - VOR super._ready()).
##
## Konfiguriert die Zone für den Loop-Body.
func _setup_loop_instruction_zones_early():
	var instruction_zone_config := {
		"zone_name": "body",
		"display_label": "Loop Body",
		"offset_y_base": 45.0,
		"initial_height": _initial_inner_height,
		"padding_bottom": padding_bottom
	}
	setup_instruction_zones([instruction_zone_config])

## Verlinkt die Instruction-SnapZones (späte Phase - NACH super._ready()).
func _link_instruction_zones():
	if instruction_zones.size() >= 1:
		instruction_zones[0].zone = instruction_zone
		instruction_zones[0].inner_container = inner_container
		instruction_zones[0].indicator = snap_indicator_instruction
		instruction_zones[0].label = inner_label
		instruction_zones[0].initial_height = _initial_inner_height
		instruction_zones[0].current_height = _initial_inner_height

## Erstellt die SnapZones für Instruction-Zonen.
func _setup_custom_snap_zones():
	if snap_indicator_instruction:
		instruction_zone = SnapZone.new(
			self,
			snap_indicator_instruction,
			SnapZone.ZoneType.INSTRUCTION,
			indicator_instruction_accepts,
			"snap_body"
		)
		register_snap_zone(instruction_zone)

## Initialisiert die Größen-Werte.
func _initialize_sizes():
	if inner_container:
		_initial_inner_height = inner_container.custom_minimum_size.y
		if _initial_inner_height == 0.0:
			_initial_inner_height = 25.0
	
	_initial_block_height = custom_minimum_size.y
	if _initial_block_height == 0.0:
		_initial_block_height = 80.0
	
	_current_valid_height = _initial_block_height

## Aktualisiert die Darstellung basierend auf dem Loop-Typ.
##
## Zeigt/versteckt die entsprechenden UI-Container für den aktuellen Loop-Typ.
func _update_loop_type():
	if not is_inside_tree():
		return
		
	if not top_for_container or not top_while_container or not bottom_do_container:
		await get_tree().process_frame
	
	var current_type = get_loop_type()
	
	match current_type:
		LoopType.WHILE:
			top_for_container.visible = false
			top_while_container.visible = true
			bottom_do_container.visible = false
			top_do_container.visible = false
		LoopType.DO_WHILE:
			top_for_container.visible = false
			top_while_container.visible = false
			bottom_do_container.visible = true
			top_do_container.visible = true
		LoopType.FOR:
			top_for_container.visible = true
			top_while_container.visible = false
			bottom_do_container.visible = false
			top_do_container.visible = false


## Überschreibt die Basis-Methode für Loop-spezifische Größenanpassung.
func _update_block_size():
	_update_block_size_generic()


## Initialisiert LoopBlockData.
func _init_default_data():
	var loop_data = LoopBlockData.new()
	loop_data.block_type = BlockData.BlockType.LOOP
	loop_data.block_id = _generate_block_id()
	loop_data.position = global_position
	loop_data.loop_type = LoopBlockData.LoopType.WHILE
	data = loop_data

## Synchronisiert UI von LoopBlockData.
func _sync_from_data():
	if not data or not data is LoopBlockData:
		return
	
	# Basis-Synchronisation (Position) wird in DraggableBlock gemacht
	
	# Aktualisiere UI basierend auf loop_type
	_update_loop_type()

## Synchronisiert LoopBlockData von UI.
func _sync_to_data():
	if not data:
		return
	
	data.position = global_position
	
	if not data is LoopBlockData:
		return
	
	var loop_data = data as LoopBlockData
	
	# Extrahiere Condition aus Condition-Zone
	if condition_zones.size() > 0:
		var cond_child = condition_zones[0].get_child()
		if cond_child and cond_child is ConditionBlock:
			loop_data.case_condition = cond_child.to_block_data() as ConditionBlockData
		else:
			loop_data.case_condition = null
	
	# Extrahiere Body aus Instruction-Zone
	loop_data.body.clear()
	if instruction_zones.size() > 0:
		var body_child = instruction_zones[0].get_first_child()
		while body_child and is_instance_valid(body_child):
			loop_data.body.append(body_child.to_block_data())
			body_child = body_child.block_below

## Extrahiert LoopBlockData aus diesem Block (inkl. verschachtelter Blöcke).
##
## @return: Die LoopBlockData dieses Blocks
func to_block_data() -> LoopBlockData:
	_sync_to_data()
	
	if data and data is LoopBlockData:
		return data.duplicate_data() as LoopBlockData
	
	# Fallback
	return LoopBlockData.new()

## Factory-Methode: Erstellt LoopBlock aus LoopBlockData.
##
## @param block_data: Die LoopBlockData mit der Konfiguration
## @param block_scene: Die PackedScene für den Block
## @return: Der erstellte LoopBlock oder null bei Fehler
static func create_from_data(block_data: LoopBlockData, block_scene: PackedScene) -> LoopBlock:
	if not block_scene:
		push_error("[LoopBlock] create_from_data: Kein block_scene übergeben")
		return null
	
	var block = block_scene.instantiate() as LoopBlock
	if not block:
		push_error("[LoopBlock] create_from_data: Konnte Block nicht instanziieren")
		return null
	
	block.data = block_data
	return block

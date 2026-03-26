## Case-Distinction-Block für If und If-Else Verzweigungen.
##
## Implementiert bedingte Verzweigungen mit einer Condition-Zone
## und einer oder zwei Instruction-Zonen (True/False).
## Kann zwischen IF und IF_ELSE Typen wechseln.
class_name CaseDistinctionBlock
extends ContainerBlock

## Unterstützte Case-Typen
enum CaseType {
	IF,       ## Einfache If-Verzweigung (nur True-Branch)
	IF_ELSE   ## If-Else-Verzweigung (True- und False-Branch)
}

## Condition-Zone Indikator
@export var snap_condition_color_rect: ColorRect

## True-Branch Instruction-Zone Indikator
@export var snap_true_color_rect: ColorRect

## False-Branch Instruction-Zone Indikator
@export var snap_false_color_rect: ColorRect

## Label für die Condition
@export var condition_label_label: Label

## Label für den Else-Branch
@export var else_label_label: Label

## Label für den If-Instruction-Bereich
@export var if_inner_label_label: Label

## Label für den Else-Instruction-Bereich
@export var else_inner_label_label: Label

## Innerer Container für If-Instructions
@export var if_inner_container_container: Control

## Innerer Container für Else-Instructions
@export var else_inner_container_container: Control

@onready var snap_indicator_condition: ColorRect = snap_condition_color_rect
@onready var snap_indicator_true_instruction: ColorRect = snap_true_color_rect
@onready var snap_indicator_false_instruction: ColorRect = snap_false_color_rect

@onready var condition_label: Label = condition_label_label
@onready var if_inner_label: Label = if_inner_label_label
@onready var else_inner_label: Label = else_inner_label_label
@onready var if_inner_container: Control = if_inner_container_container
@onready var else_inner_container: Control = else_inner_container_container
@onready var else_label: Label = else_label_label

## Initiale Höhe des If-Bereichs
var _initial_if_height: float = 0.0

## Initiale Höhe des Else-Bereichs
var _initial_else_height: float = 0.0

## SnapZone für True-Branch
var true_instruction_zone: SnapZone = null

## SnapZone für False-Branch
var false_instruction_zone: SnapZone = null

## LabelRenderer-Integration für das else-Label
var _else_label_id: int = -1

## Property für Godot-Szenen-Kompatibilität (fängt @export case_type aus alten Szenen ab).
##
## Zugriff auf den Case-Typ über CaseDistinctionBlockData.
var case_type: CaseType:
	get:
		return get_case_type()
	set(value):
		set_case_type(value)

## Gibt den aktuellen Case-Typ zurück.
##
## Liest den Typ aus CaseDistinctionBlockData und konvertiert ihn.
##
## @return: Der aktuelle CaseType
func get_case_type() -> CaseType:
	if data and data is CaseDistinctionBlockData:
		# Konvertiere CaseDistinctionBlockData.CaseType zu CaseDistinctionBlock.CaseType
		match (data as CaseDistinctionBlockData).case_type:
			CaseDistinctionBlockData.CaseType.IF:
				return CaseType.IF
			CaseDistinctionBlockData.CaseType.IF_ELSE:
				return CaseType.IF_ELSE
	return CaseType.IF_ELSE

## Setzt den Case-Typ und aktualisiert die Darstellung.
##
## Konvertiert CaseDistinctionBlock.CaseType zu CaseDistinctionBlockData.CaseType.
##
## @param value: Der neue CaseType
func set_case_type(value: CaseType):
	if data and data is CaseDistinctionBlockData:
		# Konvertiere CaseDistinctionBlock.CaseType zu CaseDistinctionBlockData.CaseType
		match value:
			CaseType.IF:
				(data as CaseDistinctionBlockData).case_type = CaseDistinctionBlockData.CaseType.IF
			CaseType.IF_ELSE:
				(data as CaseDistinctionBlockData).case_type = CaseDistinctionBlockData.CaseType.IF_ELSE
		
		if is_inside_tree():
			_update_case_type()

func _ready():
	snap_category = SnapCategory.FLOW
	
	_initialize_sizes()
	
	# Frühe Phase: Zonen-Konfigurationen erstellen (VOR super._ready())
	_setup_case_instruction_zones_early()
	_setup_case_condition_zones_early()
	
	super._ready()
	
	# Späte Phase: SnapZones erstellen und verlinken (NACH super._ready())
	_setup_custom_snap_zones()
	_link_instruction_zones()
	_link_condition_zones()
	
	# Registriere ALLE Zonen-Labels beim Renderer (nach dem Linken!)
	if USE_LABEL_RENDERER:
		_setup_zone_labels_for_renderer()
		_setup_else_label_for_renderer()
	
	_update_case_type()
	
	await get_tree().process_frame

	_update_indicator_positions()
	
	_hide_snap_indicators()

## Registriert das else-Label beim LabelRenderer.
func _setup_else_label_for_renderer():
	if not _label_renderer:
		_label_renderer = LabelRenderer.get_instance(get_tree())
	
	if else_label and is_instance_valid(else_label):
		else_label.modulate.a = 0.0
		
		_else_label_id = _label_renderer.register_label(
			else_label,
			else_label.text,
			Vector2.ZERO,
			Color(-1, -1, -1, -1),
			else_label.horizontal_alignment,
			else_label.vertical_alignment,
			else_label.size.x,
			else_label.size.y
		)

## Aufräumen beim Entfernen des Blocks.
func _exit_tree():
	super._exit_tree()
	
	if USE_LABEL_RENDERER and _label_renderer and _else_label_id >= 0:
		_label_renderer.unregister_label(_else_label_id)
		_else_label_id = -1

## Setup für die Condition-Zone (frühe Phase - VOR super._ready()).
##
## Konfiguriert die Zone für die If-Bedingung.
func _setup_case_condition_zones_early():
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

## Setup für die beiden Instruction-Zonen (frühe Phase - VOR super._ready()).
##
## Konfiguriert die Zonen für True-Branch (If) und False-Branch (Else).
func _setup_case_instruction_zones_early():
	var true_zone_config := {
		"zone_name": "true",
		"display_label": "If",
		"offset_y_base": 45.0,
		"initial_height": _initial_if_height,
		"padding_bottom": padding_bottom
	}
	
	var false_zone_config := {
		"zone_name": "false",
		"display_label": "Else",
		"offset_y_base": 0.0,  # Wird dynamisch berechnet
		"offset_y_dynamic": _calculate_false_offset,
		"initial_height": _initial_else_height,
		"padding_bottom": padding_bottom
	}
	
	setup_instruction_zones([true_zone_config, false_zone_config])

## Verlinkt die SnapZones mit den instruction_zones (späte Phase - NACH super._ready()).
func _link_instruction_zones():
	if instruction_zones.size() >= 2:
		# True-Zone (Index 0)
		instruction_zones[0].zone = true_instruction_zone
		instruction_zones[0].inner_container = if_inner_container
		instruction_zones[0].indicator = snap_indicator_true_instruction
		instruction_zones[0].label = if_inner_label
		instruction_zones[0].initial_height = _initial_if_height
		instruction_zones[0].current_height = _initial_if_height
		
		# False-Zone (Index 1)
		instruction_zones[1].zone = false_instruction_zone
		instruction_zones[1].inner_container = else_inner_container
		instruction_zones[1].indicator = snap_indicator_false_instruction
		instruction_zones[1].label = else_inner_label
		instruction_zones[1].initial_height = _initial_else_height
		instruction_zones[1].current_height = _initial_else_height

## Berechnet den dynamischen Offset für die False-Zone.
##
## @return: Der Y-Offset für die Else-Zone
func _calculate_false_offset() -> float:
	var if_height = if_inner_container.size.y if if_inner_container else _initial_if_height
	return 45.0 + if_height + 35.0 + 2  # If-Offset + If-Höhe + Else-Label + Indikator


## Erstellt die SnapZones für Instruction-Zonen.
func _setup_custom_snap_zones():
	# True Instruction SnapZone (If-Branch)
	if snap_indicator_true_instruction:
		true_instruction_zone = SnapZone.new(
			self,
			snap_indicator_true_instruction,
			SnapZone.ZoneType.INSTRUCTION,
			indicator_instruction_accepts,
			"snap_true"
		)
		register_snap_zone(true_instruction_zone)
	
	# False Instruction SnapZone (Else-Branch)
	if snap_indicator_false_instruction:
		false_instruction_zone = SnapZone.new(
			self,
			snap_indicator_false_instruction,
			SnapZone.ZoneType.INSTRUCTION,
			indicator_instruction_accepts,
			"snap_false"
		)
		register_snap_zone(false_instruction_zone)

## Initialisiert die Größen-Werte.
func _initialize_sizes():
	if if_inner_container:
		_initial_if_height = if_inner_container.custom_minimum_size.y
		if _initial_if_height == 0.0:
			_initial_if_height = 25.0
	
	if else_inner_container:
		_initial_else_height = else_inner_container.custom_minimum_size.y
		if _initial_else_height == 0.0:
			_initial_else_height = 25.0
	
	if _initial_block_height == 0.0:
		if get_case_type() == CaseType.IF:
			_initial_block_height = 80.0
		else:
			_initial_block_height = 140.0
		custom_minimum_size.y = _initial_block_height
		size.y = _initial_block_height
	
	_current_valid_height = _initial_block_height

## Aktualisiert die Darstellung basierend auf dem Case-Typ.
##
## Zeigt/versteckt die Else-Zone je nach Typ (IF oder IF_ELSE).
func _update_case_type():
	if not is_inside_tree():
		return
	
	if not if_inner_container or not else_inner_container:
		await get_tree().process_frame
	
	var current_type = get_case_type()
	
	match current_type:
		CaseType.IF:
			if USE_LABEL_RENDERER and _label_renderer and _else_label_id >= 0:
				_label_renderer.update_label_visibility(_else_label_id, false)
			elif else_label:
				else_label.visible = false
			if else_inner_container:
				else_inner_container.visible = false
			if USE_LABEL_RENDERER:
				_update_renderer_zone_label_visibility("instr_false", false)
		CaseType.IF_ELSE:
			if USE_LABEL_RENDERER and _label_renderer and _else_label_id >= 0:
				_label_renderer.update_label_visibility(_else_label_id, true)
			elif else_label:
				else_label.visible = true
			if else_inner_container:
				else_inner_container.visible = true

	_initialize_sizes()
	call_deferred("_update_block_size")
	await get_tree().process_frame
	_update_indicator_positions()
	_update_all_zone_labels()


## Überschreibt die Basis-Methode für Case-spezifische Größenanpassung.
##
## Filtert Zonen basierend auf dem Case-Typ (IF zeigt nur True-Zone).
func _update_block_size():
	var filter_func = func(zone_data: InstructionZoneData) -> bool:
		if get_case_type() == CaseType.IF:
			return zone_data.zone_name == "true"
		return true
	
	_update_block_size_generic(filter_func)



## Initialisiert CaseDistinctionBlockData.
func _init_default_data():
	var cond_data = CaseDistinctionBlockData.new()
	cond_data.block_type = BlockData.BlockType.CASE_DISTINCTION
	cond_data.block_id = _generate_block_id()
	cond_data.position = global_position
	cond_data.case_type = CaseDistinctionBlockData.CaseType.IF_ELSE
	data = cond_data

## Synchronisiert UI von CaseDistinctionBlockData.
func _sync_from_data():
	if not data or not data is CaseDistinctionBlockData:
		return
	
	# Basis-Synchronisation (Position) wird in DraggableBlock gemacht
	
	# Aktualisiere UI basierend auf case_type
	_update_case_type()

## Synchronisiert CaseDistinctionBlockData von UI.
func _sync_to_data():
	if not data:
		return
	
	data.position = global_position
	
	if not data is CaseDistinctionBlockData:
		return
	
	var cond_data = data as CaseDistinctionBlockData
	
	# Extrahiere Condition aus Condition-Zone
	if condition_zones.size() > 0:
		var cond_child = condition_zones[0].get_child()
		if cond_child and cond_child is ConditionBlock:
			cond_data.case_condition = cond_child.to_block_data() as ConditionBlockData
		else:
			cond_data.case_condition = null
	
	# Extrahiere True-Branch aus Instruction-Zone
	cond_data.true_branch.clear()
	if instruction_zones.size() > 0:
		var true_child = instruction_zones[0].get_first_child()
		while true_child and is_instance_valid(true_child):
			cond_data.true_branch.append(true_child.to_block_data())
			true_child = true_child.block_below
	
	# Extrahiere False-Branch aus Instruction-Zone
	cond_data.false_branch.clear()
	if instruction_zones.size() > 1:
		var false_child = instruction_zones[1].get_first_child()
		while false_child and is_instance_valid(false_child):
			cond_data.false_branch.append(false_child.to_block_data())
			false_child = false_child.block_below

## Extrahiert CaseDistinctionBlockData aus diesem Block (inkl. verschachtelter Blöcke).
##
## @return: Die CaseDistinctionBlockData dieses Blocks
func to_block_data() -> CaseDistinctionBlockData:
	_sync_to_data()
	
	if data and data is CaseDistinctionBlockData:
		return data.duplicate_data() as CaseDistinctionBlockData
	
	# Fallback
	return CaseDistinctionBlockData.new()

## Factory-Methode: Erstellt CaseDistinctionBlock aus CaseDistinctionBlockData.
##
## @param block_data: Die CaseDistinctionBlockData mit der Konfiguration
## @param block_scene: Die PackedScene für den Block
## @return: Der erstellte CaseDistinctionBlock oder null bei Fehler
static func create_from_data(block_data: CaseDistinctionBlockData, block_scene: PackedScene) -> CaseDistinctionBlock:
	if not block_scene:
		push_error("[CaseDistinctionBlock] create_from_data: Kein block_scene übergeben")
		return null
	
	var block = block_scene.instantiate() as CaseDistinctionBlock
	if not block:
		push_error("[CaseDistinctionBlock] create_from_data: Konnte Block nicht instanziieren")
		return null
	
	block.data = block_data
	return block

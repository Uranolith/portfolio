## Haupt-Ausführungsblock (Program-Block).
##
## Alles innerhalb dieses Blocks wird als ausführbares Programm behandelt.
## Dies ist der Einstiegspunkt für die Code-Ausführung.
## Typischerweise gibt es nur einen ProgramBlock pro Level.
class_name ProgramBlock
extends ContainerBlock

## Instruction-Zone Indikator
@export var snap_instruction_color_rect: ColorRect

## Innerer Container für Instructions
@export var inner_container_panel: Panel

## Label für den Instruction-Bereich
@export var inner_label_label: Label

@onready var snap_indicator_instruction: ColorRect = snap_instruction_color_rect
@onready var inner_container: Panel = inner_container_panel
@onready var inner_label: Label = inner_label_label

## Initiale innere Höhe
var _initial_inner_height: float = 0.0

## SnapZone für Instructions
var instruction_zone: SnapZone = null

## Markiert diesen Block als Programm-Einstiegspunkt
var is_program_entry: bool = true

## Initialisiert den ProgramBlock und richtet alle Zonen ein.
func _ready():
	snap_category = SnapCategory.NONE
	
	_initialize_sizes()
	
	# Frühe Phase: Zonen-Konfigurationen erstellen (VOR super._ready())
	_setup_program_instruction_zones_early()
	
	super._ready()
	
	# Späte Phase: SnapZones erstellen und verlinken (NACH super._ready())
	_setup_custom_snap_zones()
	_link_instruction_zones()
	
	# Registriere Labels beim Renderer
	if USE_LABEL_RENDERER:
		_setup_zone_labels_for_renderer()
	
	await get_tree().process_frame
	
	_update_indicator_positions()
	
	_hide_snap_indicators()

## Setup für die Instruction-Zone (frühe Phase - VOR super._ready()).
##
## Konfiguriert die Hauptzone für das Programm.
func _setup_program_instruction_zones_early():
	var instruction_zone_config := {
		"zone_name": "main",
		"display_label": "Programm-Code",
		"offset_y_base": 45.0,
		"initial_height": _initial_inner_height,
		"padding_bottom": padding_bottom
	}
	setup_instruction_zones([instruction_zone_config])

## Verlinkt die Instruction-SnapZones (späte Phase - NACH super._ready()).
func _link_instruction_zones():
	if instruction_zones.size() >= 1 and instruction_zone:
		instruction_zones[0].zone = instruction_zone
		instruction_zones[0].inner_container = inner_container
		instruction_zones[0].indicator = snap_indicator_instruction
		instruction_zones[0].label = inner_label
		instruction_zones[0].initial_height = _initial_inner_height
		instruction_zones[0].current_height = _initial_inner_height

## Erstellt die SnapZones (wird von ContainerBlock._ready() aufgerufen).
func _setup_custom_snap_zones():
	if snap_indicator_instruction and is_instance_valid(snap_indicator_instruction):
		instruction_zone = SnapZone.new(
			self,
			snap_indicator_instruction,
			SnapZone.ZoneType.INSTRUCTION,
			indicator_instruction_accepts,
			"snap_instruction"
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
		_initial_block_height = 70.0
	
	_current_valid_height = _initial_block_height


## Überschreibt die Basis-Methode für Programm-spezifische Größenanpassung.
func _update_block_size():
	_update_block_size_generic()

## Program-Blöcke zeigen kein Standard Block-Name-Label.
##
## @return: Immer false
func _should_show_block_name_label() -> bool:
	return true

## Initialisiert die Standard-BlockData für ProgramBlock.
func _init_default_data():
	if not data:
		data = BlockData.new()
		data.block_type = BlockData.BlockType.PROGRAM
		data.block_id = _generate_block_id()
		data.position = global_position


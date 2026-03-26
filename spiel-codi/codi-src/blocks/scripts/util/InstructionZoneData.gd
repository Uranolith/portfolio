## Daten-Container für eine Instruction-Zone.
##
## Ermöglicht generische Behandlung von N Instruction-Zonen in ContainerBlock.
## Speichert Layout-Informationen, Referenzen zu Nodes und verwaltet die Zone-Höhe.
class_name InstructionZoneData
extends RefCounted

## Name der Zone (z.B. "instruction", "true", "false")
var zone_name: String = ""

## Anzeige-Label der Zone (z.B. "Loop", "If", "Else")
var display_label: String = ""

## Die SnapZone dieser Instruction-Zone
var zone: SnapZone = null

## Der innere Container (Control) für diese Zone
var inner_container: Control = null

## Der Indikator (ColorRect) für diese Zone
var indicator: ColorRect = null

## Das Label für diese Zone
var label: Label = null

## Basis Y-Offset (statisch)
var offset_y_base: float = 0.0

## Optionale Callable für dynamischen Y-Offset
var offset_y_dynamic: Callable

## Initiale Höhe der Zone
var initial_height: float = 80.0

## Padding am unteren Rand
var padding_bottom: float = 10.0

## Aktuelle Höhe der Zone
var current_height: float = 80.0

## Das erste Kind (Kopf der Chain) in dieser Zone
var _first_child: DraggableBlock = null

## Konstruktor.
##
## @param config: Dictionary mit Konfigurationswerten
func _init(config: Dictionary = {}):
	if config.has("zone_name"):
		zone_name = config.zone_name
	if config.has("display_label"):
		display_label = config.display_label
	if config.has("offset_y_base"):
		offset_y_base = config.offset_y_base
	if config.has("offset_y_dynamic"):
		offset_y_dynamic = config.offset_y_dynamic
	if config.has("initial_height"):
		initial_height = config.initial_height
	if config.has("padding_bottom"):
		padding_bottom = config.padding_bottom
	
	current_height = initial_height

## Berechnet den aktuellen Y-Offset.
##
## Kann dynamisch sein wenn offset_y_dynamic gesetzt ist.
##
## @return: Der Y-Offset
func get_offset_y() -> float:
	if offset_y_dynamic and offset_y_dynamic.is_valid():
		return offset_y_dynamic.call()
	return offset_y_base

## Gibt das erste Child dieser Zone zurück (Kopf der Chain).
##
## @return: Der erste Block oder null
func get_first_child() -> DraggableBlock:
	return _first_child

## Setzt das erste Child dieser Zone.
##
## @param child: Der neue erste Block
func set_first_child(child: DraggableBlock):
	_first_child = child

## Berechnet die Höhe der gesamten Chain in dieser Zone.
##
## @param visited: Dictionary zur Zyklus-Erkennung
## @return: Die Gesamthöhe aller Blöcke in der Chain
func calculate_chain_height(visited: Dictionary = {}) -> float:
	var height := 0.0
	var current := get_first_child()
	var safety := 0
	
	while current and is_instance_valid(current) and safety < 1000:
		if visited.has(current):
			push_warning("[InstructionZoneData] Zyklus in calculate_chain_height erkannt bei: %s" % current.block_name)
			break
		if current.has_method("get_total_height"):
			height += current.call("get_total_height", visited)
		else:
			height += current.size.y
		current = current.block_below
		safety += 1
	
	if safety >= 1000:
		push_error("[InstructionZoneData] calculate_chain_height: Abgebrochen wegen zu vielen Schritten")
	
	return height

## Aktualisiert die Container-Höhe basierend auf der Chain.
##
## @param visited: Dictionary zur Zyklus-Erkennung
## @return: Die neue Höhe
func update_container_height(visited: Dictionary = {}) -> float:
	var chain_height := calculate_chain_height(visited)
	var new_height = max(initial_height, chain_height + padding_bottom)
	
	if inner_container:
		inner_container.custom_minimum_size.y = new_height
	
	current_height = new_height
	return new_height

## Gibt die Höhendifferenz zur Initial-Höhe zurück.
##
## @return: Die Differenz (current_height - initial_height)
func get_height_diff() -> float:
	return current_height - initial_height

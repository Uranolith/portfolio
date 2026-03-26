## Daten-Container für eine Condition-Zone.
##
## Ermöglicht generische Behandlung von N Condition-Zonen in ContainerBlock.
## Im Unterschied zu InstructionZoneData kann hier nur EIN Block angedockt werden (keine Kette).
class_name ConditionZoneData
extends RefCounted

## Name der Zone (z.B. "condition", "case", "case_0")
var zone_name: String = ""

## Anzeige-Label der Zone (z.B. "Bedingung", "Wert")
var display_label: String = ""

## Die SnapZone für diese Condition
var zone: SnapZone = null

## Der visuelle Indikator (ColorRect)
var indicator: ColorRect = null

## Das Label (sichtbar wenn Zone leer ist)
var label: Label = null

## X-Offset relativ zum Container
var offset_x: float = 0.0

## Y-Offset relativ zum Container
var offset_y: float = 0.0

## Optional: Dynamische Offset-Berechnung
var offset_dynamic: Callable

## Akzeptierte Block-Kategorien
var accepts: Array[int] = [SnapCategory.CONDITION]

## Aktuelles Kind dieser Zone (nur ein Block, keine Kette)
var _child_block: DraggableBlock = null

## Konstruktor.
##
## @param config: Dictionary mit Konfigurationswerten
func _init(config: Dictionary = {}):
	if config.has("zone_name"):
		zone_name = config.zone_name
	if config.has("display_label"):
		display_label = config.display_label
	if config.has("offset_x"):
		offset_x = config.offset_x
	if config.has("offset_y"):
		offset_y = config.offset_y
	if config.has("offset_dynamic"):
		offset_dynamic = config.offset_dynamic
	if config.has("accepts"):
		accepts = config.accepts
	if config.has("indicator"):
		indicator = config.indicator
	if config.has("label"):
		label = config.label

## Berechnet die aktuelle Position (kann dynamisch sein).
##
## @return: Der Offset als Vector2
func get_offset() -> Vector2:
	if offset_dynamic and offset_dynamic.is_valid():
		return offset_dynamic.call()
	return Vector2(offset_x, offset_y)

## Gibt das Child dieser Zone zurück.
##
## @return: Der Block in dieser Zone oder null
func get_child() -> DraggableBlock:
	return _child_block

## Setzt das Child dieser Zone.
##
## @param child: Der neue Block
func set_child(child: DraggableBlock):
	_child_block = child
	# Auch in der SnapZone aktualisieren
	if zone:
		zone.child_block = child

## Prüft ob die Zone belegt ist.
##
## @return: true wenn ein gültiger Block vorhanden ist
func has_child() -> bool:
	return _child_block != null and is_instance_valid(_child_block)

## Löscht das Child wenn es dem übergebenen Block entspricht.
##
## @param child: Der zu löschende Block (oder null für bedingungsloses Löschen)
## @return: true wenn gelöscht wurde
func clear_child(child: DraggableBlock = null) -> bool:
	if child == null:
		# Lösche bedingungslos
		_child_block = null
		if zone:
			zone.child_block = null
		return true
	
	if _child_block == child:
		_child_block = null
		if zone:
			zone.child_block = null
		return true
	
	return false

## Aktualisiert die Label-Sichtbarkeit.
##
## Label ist nur sichtbar wenn Zone leer ist.
func update_label_visibility():
	if label and is_instance_valid(label):
		label.visible = not has_child()

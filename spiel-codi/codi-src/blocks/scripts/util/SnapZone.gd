## Repräsentiert eine Snap-Zone auf einem Block.
##
## Jeder Block kann mehrere SnapZones haben (z.B. Top, Bottom, Condition, Instruction).
##
## NEUES SYSTEM: Virtuelle Rects
## Statt ColorRect-Nodes werden virtuelle Rechtecke verwendet.
## Die Anzeige erfolgt über den zentralen SnapIndicatorRenderer mit _draw().
## Dies reduziert die Draw Calls erheblich.
class_name SnapZone
extends RefCounted

## Typen von Snap-Zonen
enum ZoneType {
	TOP,          ## Standard Top-Indikator (block_above)
	BOTTOM,       ## Standard Bottom-Indikator (block_below)
	CONDITION,    ## Condition-Slot (nur ein Kind)
	INSTRUCTION   ## Instruction-Slot (Kette von Kindern)
}

## Besitzer-Block dieser Zone
var owner_block: DraggableBlock

## Typ dieser Zone
var zone_type: ZoneType

## Akzeptierte Block-Kategorien
var accepted_categories: Array[int]

## Snap-Modus String (z.B. "snap_above", "snap_below")
var snap_mode_string: String

## Ist diese Zone aktiv?
var active: bool = true 

## Aktuelles Kind-Block (nur für CONDITION, bei INSTRUCTION ist es der Kopf der Kette)
var child_block: DraggableBlock = null


## Legacy ColorRect (für Rückwärtskompatibilität, wird nicht mehr gezeichnet)
var indicator: ColorRect = null

## Virtuelles Rechteck für den Indikator
var indicator_rect: Rect2 = Rect2()

## Farbe des Indikators
var indicator_color: Color = Color.CYAN

## Ist der Indikator sichtbar?
var indicator_visible: bool = false

## Breite des Indikators
var indicator_width: float = 150.0

## Höhe des Indikators
var indicator_height: float = 2.0

## Offset vom Besitzer-Block (relativ)
var indicator_offset: Vector2 = Vector2.ZERO

## Für Container-Interne Zonen: Referenz auf das Container-Element für Position
var position_reference_node: Control = null

## Standard-Farben für verschiedene Indikator-Typen
const COLORS = {
	"top_bottom": Color(0, 0.909804, 0.909804, 1),    # Cyan für Top/Bottom
	"instruction": Color(0.005836, 0.9642499, 0, 1),  # Grün für Instruction
	"condition": Color(1, 1, 0, 1)                     # Gelb für Condition
}

## LEGACY Constructor (mit ColorRect) - für Rückwärtskompatibilität.
##
## @param p_owner: Der Besitzer-Block
## @param p_indicator: Das ColorRect (kann null sein)
## @param p_zone_type: Der Typ der Zone
## @param p_accepted_categories: Array der akzeptierten Kategorien
## @param p_snap_mode: Optional: Der Snap-Modus String
func _init(p_owner: DraggableBlock, p_indicator: ColorRect, p_zone_type: ZoneType, p_accepted_categories: Array[int], p_snap_mode: String = ""):
	self.owner_block = p_owner
	self.indicator = p_indicator
	self.zone_type = p_zone_type
	self.accepted_categories = p_accepted_categories
	self.snap_mode_string = p_snap_mode if p_snap_mode != "" else _get_default_snap_mode()
	
	_setup_indicator_color()
	
	if indicator and is_instance_valid(indicator):
		indicator_width = indicator.size.x
		indicator_height = indicator.size.y
		indicator_color = indicator.color
		indicator.visible = false
		# Position wird dynamisch berechnet

## Factory-Methode: Erstellt eine virtuelle SnapZone (ohne ColorRect).
##
## @param p_owner: Der Besitzer-Block
## @param p_zone_type: Der Typ der Zone
## @param p_accepted_categories: Array der akzeptierten Kategorien
## @param p_snap_mode: Optional: Der Snap-Modus String
## @param p_offset: Offset vom Besitzer
## @param p_width: Breite des Indikators
## @return: Die erstellte SnapZone
static func create_virtual(p_owner: DraggableBlock, p_zone_type: ZoneType, p_accepted_categories: Array[int], p_snap_mode: String = "", p_offset: Vector2 = Vector2.ZERO, p_width: float = 150.0) -> SnapZone:
	var zone = SnapZone.new(p_owner, null, p_zone_type, p_accepted_categories, p_snap_mode)
	zone.indicator_offset = p_offset
	zone.indicator_width = p_width
	return zone

## Richtet die Indikator-Farbe basierend auf dem Zone-Typ ein.
func _setup_indicator_color():
	match zone_type:
		ZoneType.TOP, ZoneType.BOTTOM:
			indicator_color = COLORS.top_bottom
		ZoneType.INSTRUCTION:
			indicator_color = COLORS.instruction
		ZoneType.CONDITION:
			indicator_color = COLORS.condition

## Gibt den Default-Snap-Modus basierend auf dem Zone-Typ zurück.
##
## @return: Der Standard Snap-Modus String
func _get_default_snap_mode() -> String:
	match zone_type:
		ZoneType.TOP:
			return "snap_above"
		ZoneType.BOTTOM:
			return "snap_below"
		ZoneType.CONDITION:
			return "snap_condition"
		ZoneType.INSTRUCTION:
			return "snap_instruction"
		_:
			return "snap_below"

## Berechnet die aktuelle globale Position des Indikators.
##
## @return: Die globale Position des Indikators
func get_indicator_global_position() -> Vector2:
	if not owner_block or not is_instance_valid(owner_block):
		return Vector2.ZERO
	
	if position_reference_node and is_instance_valid(position_reference_node):
		return position_reference_node.global_position + indicator_offset
	
	match zone_type:
		ZoneType.TOP:
			return owner_block.global_position + indicator_offset
		ZoneType.BOTTOM:
			var y = owner_block.global_position.y + owner_block.get_total_height()
			return Vector2(owner_block.global_position.x, y) + indicator_offset
		ZoneType.INSTRUCTION, ZoneType.CONDITION:
			return owner_block.global_position + indicator_offset
		_:
			return owner_block.global_position + indicator_offset

## Gibt das aktuelle Indikator-Rect in globalen Koordinaten zurück.
##
## @return: Das Rechteck des Indikators in globalen Koordinaten
func get_indicator_rect() -> Rect2:
	if indicator and is_instance_valid(indicator):
		return Rect2(indicator.global_position, Vector2(indicator.size.x, indicator.size.y))
	
	var pos = get_indicator_global_position()
	return Rect2(pos, Vector2(indicator_width, indicator_height))

## Prüft ob ein Block in diese Zone snappen kann.
##
## @param block: Der zu prüfende Block
## @return: true wenn der Block snappen kann, false sonst
func can_accept(block: DraggableBlock) -> bool:
	if not active:
		return false
	
	if zone_type == ZoneType.CONDITION:
		if child_block != null and is_instance_valid(child_block):
			return false
	
	return SnapCategory.can_snap(block.snap_category, accepted_categories)

## Prüft ob der Indikator mit einem Rect überlappt.
##
## @param rect: Das zu prüfende Rechteck
## @return: true wenn Überlappung vorhanden, false sonst
func overlaps_with(rect: Rect2) -> bool:
	var ind_rect = get_indicator_rect()
	return rect.intersects(ind_rect)

## Zeigt den Indikator an (über SnapIndicatorRenderer).
func show_indicator():
	indicator_visible = true
	_update_renderer()

## Versteckt den Indikator (über SnapIndicatorRenderer).
func hide_indicator():
	indicator_visible = false
	_hide_from_renderer()

## Aktualisiert die Position im Renderer.
func _update_renderer():
	if not indicator_visible:
		return
	
	var renderer = _get_renderer()
	if renderer:
		var rect = get_indicator_rect()
		renderer.show_indicator(rect, indicator_color, owner_block.z_index if owner_block else 0)

## Entfernt den Indikator vom Renderer.
func _hide_from_renderer():
	var renderer = _get_renderer()
	if renderer:
		var rect = get_indicator_rect()
		renderer.hide_indicator(rect)

## Holt den SnapIndicatorRenderer über die Gruppe.
##
## @return: Der SnapIndicatorRenderer oder null
func _get_renderer():
	if not owner_block or not is_instance_valid(owner_block):
		return null
	if not owner_block.is_inside_tree():
		return null
	
	var tree = owner_block.get_tree()
	if tree:
		var nodes = tree.get_nodes_in_group("snap_indicator_renderer")
		if nodes.size() > 0:
			return nodes[0]
	return null

## Aktiviert/Deaktiviert die Zone.
##
## @param enabled: true zum Aktivieren, false zum Deaktivieren
func set_enabled(enabled: bool):
	active = enabled
	if not enabled and indicator_visible:
		hide_indicator()

## Setzt die Breite des Indikators dynamisch.
##
## @param width: Die neue Breite
func set_indicator_width(width: float):
	indicator_width = width
	if indicator_visible:
		_update_renderer()

## Setzt den Offset des Indikators.
##
## @param offset: Der neue Offset
func set_indicator_offset(offset: Vector2):
	indicator_offset = offset
	if indicator_visible:
		_update_renderer()

## Setzt das Referenz-Node für die Position (für Container-interne Zonen).
##
## @param node: Das Referenz-Control-Node
func set_position_reference(node: Control):
	position_reference_node = node

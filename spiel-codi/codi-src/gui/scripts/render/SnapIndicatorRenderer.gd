## Zentrales Zeichnungssystem für alle Snap-Indikatoren.
##
## Verwendet _draw() statt ColorRects, um Draw Calls zu reduzieren.
## Dieses Node wird einmalig zur Szene hinzugefügt und zeichnet alle aktiven
## Indikatoren in einem einzigen Draw Call.
##
## VERWENDUNG:
## 1. Der Renderer wird automatisch erstellt wenn ein Block SnapIndicatorRenderer.get_instance() aufruft
## 2. Zeige Indikatoren mit show_indicator() an
## 3. Verstecke mit hide_indicator() oder clear_all_indicators()
class_name SnapIndicatorRenderer
extends Node2D

# Singleton-Instanz
static var _instance: SnapIndicatorRenderer = null

## Aktive Indikatoren: Array von Dictionaries mit {rect: Rect2, color: Color, z_order: int}
var active_indicators: Array[Dictionary] = []

## Standard-Farben für verschiedene Indikator-Typen
const COLORS = {
	"top_bottom": Color(0, 0.909804, 0.909804, 1),    # Cyan für Top/Bottom
	"instruction": Color(0.005836, 0.9642499, 0, 1),  # Grün für Instruction
	"condition": Color(1, 1, 0, 1)                     # Gelb für Condition
}

## Indikator-Höhe in Pixeln
const INDICATOR_HEIGHT = 2.0

## Gibt die Singleton-Instanz zurück, erstellt sie bei Bedarf.
##
## Der Renderer wird im BlockCanvas (innerhalb des SubViewports) erstellt,
## damit die Koordinaten mit den Blöcken übereinstimmen.
##
## @param tree: Der SceneTree
## @return: Die SnapIndicatorRenderer-Instanz
static func get_instance(tree: SceneTree) -> SnapIndicatorRenderer:
	if _instance and is_instance_valid(_instance):
		return _instance
	
	# Suche existierende Instanz
	var existing = tree.get_nodes_in_group("snap_indicator_renderer")
	if existing.size() > 0:
		_instance = existing[0] as SnapIndicatorRenderer
		return _instance
	
	# Erstelle neue Instanz
	var renderer = SnapIndicatorRenderer.new()
	renderer.name = "SnapIndicatorRenderer"
	
	# Versuche den BlockCanvas im SubViewport zu finden
	var blocks_containers = tree.get_nodes_in_group("blocks_container")
	if blocks_containers.size() > 0:
		# Füge zum Parent des Blocks-Containers hinzu (BlockCanvas)
		var blocks_container = blocks_containers[0]
		var block_canvas = blocks_container.get_parent()
		if block_canvas:
			block_canvas.call_deferred("add_child", renderer)
		else:
			tree.root.call_deferred("add_child", renderer)
	else:
		# Fallback: Zum Root hinzufügen
		tree.root.call_deferred("add_child", renderer)
	
	_instance = renderer
	return renderer

func _ready():
	# In Gruppe für einfachen Zugriff
	add_to_group("snap_indicator_renderer")
	
	z_index = 999

func _exit_tree():
	if _instance == self:
		_instance = null

## Registriert einen Indikator zur Anzeige.
##
## @param rect: Das Rechteck in globalen Koordinaten
## @param color: Die Farbe des Indikators
## @param z_order: Optionaler Z-Order für Sortierung (höher = vorne)
func show_indicator(rect: Rect2, color: Color, z_order: int = 0):
	var indicator_data = {
		"rect": rect,
		"color": color,
		"z_order": z_order
	}
	
	var found = false
	for i in range(active_indicators.size()):
		if active_indicators[i].rect.position == rect.position:
			active_indicators[i] = indicator_data
			found = true
			break
	
	if not found:
		active_indicators.append(indicator_data)
	
	queue_redraw()

## Entfernt einen Indikator.
##
## @param rect: Das Rechteck das entfernt werden soll (basierend auf Position)
func hide_indicator(rect: Rect2):
	for i in range(active_indicators.size() - 1, -1, -1):
		if active_indicators[i].rect.position == rect.position:
			active_indicators.remove_at(i)
			break
	queue_redraw()

## Entfernt alle Indikatoren.
func clear_all_indicators():
	active_indicators.clear()
	queue_redraw()

## Zeichnet alle aktiven Indikatoren.
func _draw():
	if active_indicators.is_empty():
		return
	
	active_indicators.sort_custom(_compare_z_order)
	
	for indicator in active_indicators:
		var rect = indicator.rect
		var color = indicator.color
		
		draw_rect(rect, color)

## Vergleichsfunktion für Z-Order Sortierung.
##
## @param a: Erstes Dictionary
## @param b: Zweites Dictionary
## @return: true wenn a vor b sortiert werden soll
func _compare_z_order(a: Dictionary, b: Dictionary) -> bool:
	return a.z_order < b.z_order

## Berechnet Indikator-Rect für Top-Position.
##
## @param block_pos: Position des Blocks
## @param block_width: Breite des Blocks
## @return: Das berechnete Rechteck
static func calc_top_rect(block_pos: Vector2, block_width: float) -> Rect2:
	return Rect2(block_pos, Vector2(block_width, INDICATOR_HEIGHT))

## Berechnet Indikator-Rect für Bottom-Position.
##
## @param block_pos: Position des Blocks
## @param block_width: Breite des Blocks
## @param block_total_height: Gesamthöhe des Blocks
## @return: Das berechnete Rechteck
static func calc_bottom_rect(block_pos: Vector2, block_width: float, block_total_height: float) -> Rect2:
	var y = block_pos.y + block_total_height
	return Rect2(Vector2(block_pos.x, y), Vector2(block_width, INDICATOR_HEIGHT))

## Berechnet Indikator-Rect für Instruction-Zone.
##
## @param zone_pos: Position der Zone
## @param zone_width: Breite der Zone
## @return: Das berechnete Rechteck
static func calc_instruction_rect(zone_pos: Vector2, zone_width: float) -> Rect2:
	return Rect2(zone_pos, Vector2(zone_width, INDICATOR_HEIGHT))

## Berechnet Indikator-Rect für Condition-Zone.
##
## @param zone_pos: Position der Zone
## @param zone_width: Breite der Zone
## @return: Das berechnete Rechteck
static func calc_condition_rect(zone_pos: Vector2, zone_width: float) -> Rect2:
	return Rect2(zone_pos, Vector2(zone_width, INDICATOR_HEIGHT))


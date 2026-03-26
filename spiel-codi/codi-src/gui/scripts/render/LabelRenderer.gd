## Zentraler Label-Renderer - zeichnet Labels in ZWEI Draw Calls.
##
## Pass 1 (dieser Node, z_index=999): Normale Labels
## Pass 2 (Child Node, z_index=1001): Gedraggte Labels
##
## VERWENDUNG:
## 1. Für Block-Labels: LabelRenderer.get_canvas_instance(tree) - wird im Block-Canvas platziert
## 2. Für UI-Labels: LabelRenderer.get_ui_instance(tree) - wird in der UI-Schicht platziert
## 3. Registriere Labels mit register_label() - gibt eine ID zurück
## 4. Aktualisiere Labels mit update_label_text(), update_label_offset(), etc.
## 5. Bei Block-Entfernung: unregister_label() aufrufen
@tool
class_name LabelRenderer
extends Node2D

## Singleton-Instanz für Block-Labels im Canvas
static var _canvas_instance: LabelRenderer = null

## Singleton-Instanz für UI-Labels außerhalb des Canvas
static var _ui_instance: LabelRenderer = null

## Kontext-Typen für den Renderer
enum RenderContext { 
	CANVAS,  ## Für Block-Labels im Canvas
	UI       ## Für UI-Labels außerhalb
}

## Kontext-Typ dieses Renderers
var _context: RenderContext = RenderContext.CANVAS

## Array aller registrierten Labels
var _labels: Array[Dictionary] = []

## Font für Label-Rendering
var _font: Font = null

## Font-Größe
var _font_size: int = 12

## Standard-Farbe für Labels
var _default_color: Color = Color.WHITE

## Set von Owner-Nodes die gerade gedraggert werden (Node -> bool)
var _dragged_owners: Dictionary = {}

## Child-Node für gedraggerte Labels (höherer z_index)
var _drag_layer: Node2D = null

## Z-Index für normale Labels
const DEFAULT_Z_INDEX: int = 999

## Z-Index für gedraggte Labels
const DRAG_Z_INDEX: int = 1001

## Gibt die Canvas-Instanz zurück (für Block-Labels im SubViewport).
##
## @param tree: Der SceneTree
## @return: Die Canvas LabelRenderer-Instanz
static func get_canvas_instance(tree: SceneTree) -> LabelRenderer:
	if _canvas_instance and is_instance_valid(_canvas_instance):
		return _canvas_instance
	
	# Suche existierende Canvas-Instanz in der Szene
	var existing = tree.get_nodes_in_group("label_renderer_canvas")
	if existing.size() > 0:
		_canvas_instance = existing[0] as LabelRenderer
		if _canvas_instance:
			_canvas_instance._context = RenderContext.CANVAS
		return _canvas_instance
	
	# Erstelle neue Canvas-Instanz - wird in den Canvas eingefügt
	var renderer = LabelRenderer.new()
	renderer.name = "LabelRendererCanvas"
	renderer._context = RenderContext.CANVAS
	_canvas_instance = renderer
	
	# Suche den Block-Canvas und füge den Renderer dort ein
	var canvas_containers = tree.get_nodes_in_group("blocks_container")
	if canvas_containers.size() > 0:
		var blocks_container = canvas_containers[0]
		blocks_container.get_parent().call_deferred("add_child", renderer)
	else:
		# Fallback: An Root anhängen (wird später verschoben)
		tree.root.call_deferred("add_child", renderer)
	
	return renderer

## Gibt die UI-Instanz zurück (für Labels außerhalb des Canvas).
##
## @param tree: Der SceneTree
## @return: Die UI LabelRenderer-Instanz
static func get_ui_instance(tree: SceneTree) -> LabelRenderer:
	if _ui_instance and is_instance_valid(_ui_instance):
		return _ui_instance
	
	# Suche existierende UI-Instanz
	var existing = tree.get_nodes_in_group("label_renderer_ui")
	if existing.size() > 0:
		_ui_instance = existing[0] as LabelRenderer
		return _ui_instance
	
	# Erstelle neue UI-Instanz
	var renderer = LabelRenderer.new()
	renderer.name = "LabelRendererUI"
	renderer._context = RenderContext.UI
	tree.root.call_deferred("add_child", renderer)
	_ui_instance = renderer
	return renderer

## Legacy-Methode für Abwärtskompatibilität - gibt Canvas-Instanz zurück.
##
## @param tree: Der SceneTree
## @return: Die Canvas LabelRenderer-Instanz
static func get_instance(tree: SceneTree) -> LabelRenderer:
	return get_canvas_instance(tree)

func _ready():
	# Füge zur entsprechenden Gruppe hinzu
	match _context:
		RenderContext.CANVAS:
			add_to_group("label_renderer_canvas")
			add_to_group("label_renderer")  # Legacy-Gruppe
		RenderContext.UI:
			add_to_group("label_renderer_ui")
	
	# Lade die Block-Font
	if ResourceLoader.exists("res://blocks/resources/blocks_font.tres"):
		var label_settings = load("res://blocks/resources/blocks_font.tres") as LabelSettings
		if label_settings:
			_font = label_settings.font
			_font_size = label_settings.font_size if label_settings.font_size > 0 else 12
			_default_color = label_settings.font_color if label_settings.font_color else Color.WHITE
	
	if not _font:
		_font = ThemeDB.fallback_font
	
	z_index = DEFAULT_Z_INDEX
	
	# Erstelle Child-Node für gedraggte Labels (höherer z_index)
	_drag_layer = _LabelDragLayer.new()
	_drag_layer.name = "DragLayer"
	_drag_layer.z_index = DRAG_Z_INDEX
	_drag_layer._parent_renderer = self
	add_child(_drag_layer)

## Aktualisiert das Rendering jedes Frame.
##
## @param _delta: Delta-Zeit (nicht verwendet)
func _process(_delta):
	queue_redraw()
	if _drag_layer:
		_drag_layer.queue_redraw()

## Registriert ein Label zum Zeichnen.
##
## Gibt eine ID zurück, die zum Aktualisieren/Entfernen verwendet werden kann.
##
## @param label_owner: Der Owner-Node des Labels
## @param text: Der anzuzeigende Text
## @param local_offset: Offset relativ zum Owner
## @param color: Farbe des Labels (-1 für Standard-Farbe)
## @param h_align: Horizontale Ausrichtung
## @param v_align: Vertikale Ausrichtung
## @param width: Breite des Label-Bereichs
## @param height: Höhe des Label-Bereichs
## @return: Die Label-ID
func register_label(label_owner: Node, text: String, local_offset: Vector2 = Vector2.ZERO, 
					color: Color = Color(-1, -1, -1, -1), 
					h_align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER,
					v_align: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER,
					width: float = 150.0, height: float = 25.0) -> int:
	var id = _labels.size()
	
	var use_color = color if color.r >= 0 else _default_color
	
	_labels.append({
		"id": id,
		"owner": label_owner,
		"text": text,
		"local_offset": local_offset,
		"color": use_color,
		"h_align": h_align,
		"v_align": v_align,
		"width": width,
		"height": height,
		"visible": true
	})
	
	return id

## Aktualisiert den Text eines Labels.
##
## @param id: Die Label-ID
## @param text: Der neue Text
func update_label_text(id: int, text: String):
	if id >= 0 and id < _labels.size():
		_labels[id].text = text
		queue_redraw()

## Aktualisiert die Position eines Labels.
##
## @param id: Die Label-ID
## @param local_offset: Der neue Offset
func update_label_offset(id: int, local_offset: Vector2):
	if id >= 0 and id < _labels.size():
		_labels[id].local_offset = local_offset
		queue_redraw()

## Aktualisiert die Sichtbarkeit eines Labels.
##
## @param id: Die Label-ID
## @param label_visible: true für sichtbar, false für unsichtbar
func update_label_visibility(id: int, label_visible: bool):
	if id >= 0 and id < _labels.size():
		_labels[id].visible = label_visible
		queue_redraw()

## Aktualisiert die Farbe eines Labels.
##
## @param id: Die Label-ID
## @param color: Die neue Farbe
func update_label_color(id: int, color: Color):
	if id >= 0 and id < _labels.size():
		_labels[id].color = color
		queue_redraw()

## Entfernt ein Label (markiert es als ungültig).
##
## @param id: Die Label-ID
func unregister_label(id: int):
	if id >= 0 and id < _labels.size():
		_labels[id].owner = null
		_labels[id].visible = false
		queue_redraw()

## Bereinigt alle ungültigen Labels.
func cleanup_invalid_labels():
	_labels = _labels.filter(func(label): 
		return label.owner != null and is_instance_valid(label.owner)
	)
	for i in range(_labels.size()):
		_labels[i].id = i
	queue_redraw()

## Zeichnet die normalen (nicht gedraggerten) Labels.
func _draw():
	if not _font:
		return
	
	# Zeichne nur normale Labels (nicht gedraggte)
	# Gedraggte Labels werden vom _drag_layer gezeichnet
	_draw_labels_on(self, false)

## Interne Methode zum Zeichnen von Labels.
##
## @param target: Der CanvasItem auf dem gezeichnet wird (muss in seiner _draw() sein)
## @param draw_dragged: true = nur gedraggte, false = nur normale
func _draw_labels_on(target: CanvasItem, draw_dragged: bool):
	for label_data in _labels:
		if not label_data.visible:
			continue
		
		var label_owner = label_data.owner
		if not label_owner or not is_instance_valid(label_owner):
			continue
		
		var is_dragged = _is_owner_dragged(label_owner)
		
		if is_dragged != draw_dragged:
			continue
		
		if label_owner is CanvasItem and not label_owner.is_visible_in_tree():
			continue
		
		var text: String = label_data.text
		if text.is_empty():
			continue
		
		var world_pos: Vector2
		if label_owner is Control:
			world_pos = label_owner.global_position + label_data.local_offset
		elif label_owner is Node2D:
			world_pos = label_owner.global_position + label_data.local_offset
		else:
			continue
		
		var text_size = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
		
		var draw_pos = world_pos
		
		match label_data.h_align:
			HORIZONTAL_ALIGNMENT_LEFT:
				pass
			HORIZONTAL_ALIGNMENT_CENTER:
				draw_pos.x += (label_data.width - text_size.x) / 2.0
			HORIZONTAL_ALIGNMENT_RIGHT:
				draw_pos.x += label_data.width - text_size.x
		
		var ascent = _font.get_ascent(_font_size)
		match label_data.v_align:
			VERTICAL_ALIGNMENT_TOP:
				draw_pos.y += ascent
			VERTICAL_ALIGNMENT_CENTER:
				draw_pos.y += (label_data.height + ascent - _font.get_descent(_font_size)) / 2.0
			VERTICAL_ALIGNMENT_BOTTOM:
				draw_pos.y += label_data.height - _font.get_descent(_font_size)
		
		target.draw_string(_font, draw_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size, label_data.color)

## Gibt die Anzahl der aktiven Labels zurück.
##
## @return: Anzahl der sichtbaren Labels mit gültigem Owner
func get_active_label_count() -> int:
	var count = 0
	for label in _labels:
		if label.visible and label.owner and is_instance_valid(label.owner):
			count += 1
	return count

## Aktualisiert alle Label-Eigenschaften auf einmal.
##
## @param id: Die Label-ID
## @param text: Der neue Text (leer = keine Änderung)
## @param local_offset: Der neue Offset (-99999 = keine Änderung)
## @param width: Die neue Breite (-1 = keine Änderung)
## @param height: Die neue Höhe (-1 = keine Änderung)
func update_label(id: int, text: String = "", local_offset: Vector2 = Vector2(-99999, -99999), width: float = -1.0, height: float = -1.0):
	if id >= 0 and id < _labels.size():
		if not text.is_empty():
			_labels[id].text = text
		if local_offset.x != -99999:
			_labels[id].local_offset = local_offset
		if width >= 0:
			_labels[id].width = width
		if height >= 0:
			_labels[id].height = height

## Markiert einen Block (Owner) als "wird gedraggert".
##
## Seine Labels werden über anderen gezeichnet.
## Rufe dies mit allen Blöcken der Drag-Kette auf.
##
## @param owner_node: Der Owner-Node
## @param is_owner_dragging: true zum Markieren, false zum Entfernen
func set_owner_dragging(owner_node: Node, is_owner_dragging: bool):
	if is_owner_dragging:
		_dragged_owners[owner_node] = true
	else:
		_dragged_owners.erase(owner_node)
	queue_redraw()

## Markiert mehrere Owner als dragging (für rekursive Ketten).
##
## @param owners: Array der Owner-Nodes
## @param is_owners_dragging: true zum Markieren, false zum Entfernen
func set_owners_dragging(owners: Array, is_owners_dragging: bool):
	for owner_node in owners:
		if owner_node and is_instance_valid(owner_node):
			if is_owners_dragging:
				_dragged_owners[owner_node] = true
			else:
				_dragged_owners.erase(owner_node)
	queue_redraw()

## Setzt alle Owner auf "nicht dragging" zurück.
func clear_all_dragging():
	_dragged_owners.clear()
	queue_redraw()

## Prüft ob der Owner eines Labels gerade gedraggert wird.
##
## @param owner_node: Der zu prüfende Owner-Node
## @return: true wenn gedraggert
func _is_owner_dragged(owner_node: Node) -> bool:
	if not owner_node or not is_instance_valid(owner_node):
		return false
	
	if _dragged_owners.has(owner_node):
		return true
	
	# Check ob das Parent (Block) gedraggert wird
	var parent = owner_node.get_parent()
	while parent:
		if _dragged_owners.has(parent):
			return true
		parent = parent.get_parent()
	
	return false

## Aufräumen beim Entfernen aus der Szene.
func _exit_tree():
	match _context:
		RenderContext.CANVAS:
			if _canvas_instance == self:
				_canvas_instance = null
		RenderContext.UI:
			if _ui_instance == self:
				_ui_instance = null

## Innere Klasse für den Drag-Layer.
##
## Zeichnet gedraggerte Labels mit höherem z_index.
class _LabelDragLayer extends Node2D:
	## Referenz zum Parent-Renderer
	var _parent_renderer: LabelRenderer = null
	
	## Zeichnet die gedraggerten Labels.
	func _draw():
		if not _parent_renderer or not _parent_renderer._font:
			return
		
		_parent_renderer._draw_labels_on(self, true)

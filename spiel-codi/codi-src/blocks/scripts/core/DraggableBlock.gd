## Basis-Klasse für alle Drag-and-Drop Blöcke.
##
## SNAP-SYSTEM (Hierarchisches Drill-Down + Echte Berührung):
## - Der gedraggte Block muss den Indikator PHYSISCH BERÜHREN (Rect-Überlappung)
## - KONZEPT: HIERARCHISCHES DRILL-DOWN
##   * Traversiere von außen nach innen (Root-Level â†’ Container â†’ Kinder)
##   * Tieferer Container gewinnt IMMER
##   * Sammle Kandidaten auf der tiefsten erreichbaren Ebene
## - ALGORITHMUS:
##   1. Starte mit Root-Level-Blöcken (ohne instruction_parent)
##   2. Prüfe ob der gedraggte Block die Bounding-Box des Blocks berührt
##   3. Wenn Container und Bounding-Box berührt wird: Rekursiv in Kinder gehen
##   4. Sammle Indikatoren die BERÜHRT werden auf jeder Ebene
##   5. Tiefere Ebene gewinnt, bei gleicher Tiefe: Größere Überlappung
##
## DRAG-MODI:
## - Linksklick: Single-Drag (nur der geklickte Block wird bewegt)
## - Rechtsklick: Group-Drag (Block + alle block_below werden mitbewegt)
class_name DraggableBlock
extends Control

## Signal wird gesendet, wenn der Drag-Vorgang startet.
signal drag_started(block: DraggableBlock)

## Signal wird gesendet, wenn der Drag-Vorgang endet.
signal drag_ended(block: DraggableBlock)

## Signal wird gesendet, wenn der Block an einem Ziel einrastet.
signal snapped_to(target: DraggableBlock, mode: String)

## Signal wird gesendet, wenn der Block von einem Ziel gelöst wird.
signal detached_from(target: DraggableBlock)

## Name des Blocks (wird im UI angezeigt)
@export var block_name: String = "Block"

## Snap-Kategorie dieses Blocks (siehe SnapCategory)
@export var snap_category: int = SnapCategory.FLOW

## Akzeptierte Kategorien für den oberen Snap-Indikator
@export var indicator_top_accepts: Array[int] = [SnapCategory.FLOW]

## Akzeptierte Kategorien für den unteren Snap-Indikator
@export var indicator_bottom_accepts: Array[int] = [SnapCategory.FLOW]

## Schützt den Block vor Löschen
@export var delete_protection: bool = false

## Referenz zum oberen Snap-Indikator ColorRect
@export var snap_top_color_rect: ColorRect

## Referenz zum unteren Snap-Indikator ColorRect
@export var snap_bot_color_rect: ColorRect

## Referenz zum Block-Label
@export var block_label: Label

# Referenzen zu Indikatoren
@onready var snap_indicator_top: ColorRect = snap_top_color_rect
@onready var snap_indicator_bottom: ColorRect = snap_bot_color_rect
@onready var block_name_label: Label = block_label

## Hintergrundfarbe des Blocks
@export var color: Color = Color(0.10, 0.10, 0.10, 0.60)

# Drag-State
var drag_state: DragState = DragState.new()
var is_dragging: bool = false

# Selection-System
var is_selected: bool = false
static var selected_block: DraggableBlock = null

# Drag-Delay (verhindert sofortiges Dragging bei Klick)
var _mouse_pressed: bool = false
var _mouse_press_position: Vector2 = Vector2.ZERO
var _is_group_drag_pending: bool = false

## Pixel-Bewegung bevor Drag startet
const DRAG_THRESHOLD: float = 5.0

# Snap-System
var snap_zones: Array[SnapZone] = []
var current_snap_target: SnapTarget = null

## Block direkt über diesem
var block_above: DraggableBlock = null

## Block direkt unter diesem
var block_below: DraggableBlock = null

## Parent bei INSTRUCTION-Snap (z.B. LoopBlock)
var instruction_parent = null

## Daten-Management (Trennung von Logik und Daten)
var data: BlockData = null

# LabelRenderer-Integration
var _label_renderer: LabelRenderer = null
var _block_name_label_id: int = -1

## Umschalten zwischen Label-Nodes und zentralem Renderer
const USE_LABEL_RENDERER: bool = true

# Z-Index für Drag
const DRAG_Z_INDEX = 1000
const NORMAL_Z_INDEX = 0

## Debug-Flag: Zeigt Snap-Indikatoren permanent an
const DEBUG_SHOW_INDICATORS = false

func _ready():
	add_to_group("move_blocks")
	_setup_default_color()
	
	# Initialisiere BlockData wenn nicht vorhanden
	if not data:
		_init_default_data()
	
	_ensure_snap_indicator_renderer()
	
	# LabelRenderer Integration
	if USE_LABEL_RENDERER:
		_setup_label_renderer()
	elif block_name_label:
		block_name_label.text = block_name
	
	_setup_default_snap_zones()
	
	if DEBUG_SHOW_INDICATORS:
		for zone in snap_zones:
			zone.show_indicator()
	else:
		_hide_snap_indicators()
	
	await get_tree().process_frame
	_update_indicator_positions()

	_update_selection_visual()
	
	# Synchronisiere von BlockData nach UI
	if data:
		_sync_from_data()

# Richtet den LabelRenderer ein und registriert das Block-Label
func _setup_label_renderer():
	_label_renderer = LabelRenderer.get_instance(get_tree())
	
	if not _should_show_block_name_label():
		if block_name_label:
			block_name_label.modulate.a = 0.0
		return
	
	if block_name_label:
		block_name_label.modulate.a = 0.0
		
		_block_name_label_id = _label_renderer.register_label(
			block_name_label,  # Label selbst als Owner
			block_name,
			Vector2.ZERO,
			Color(-1, -1, -1, -1),  # Nutze Default-Farbe
			block_name_label.horizontal_alignment,
			block_name_label.vertical_alignment,
			block_name_label.size.x,
			block_name_label.size.y
		)
	else:
		# Fallback: Registriere ein zentriertes Label über den gesamten Block
		_block_name_label_id = _label_renderer.register_label(
			self,
			block_name,
			Vector2.ZERO,
			Color(-1, -1, -1, -1),
			HORIZONTAL_ALIGNMENT_CENTER,
			VERTICAL_ALIGNMENT_CENTER,
			size.x,
			size.y
		)

# Aktualisiert das Block-Label (für dynamische Namen)
func set_block_name(new_name: String):
	block_name = new_name
	if USE_LABEL_RENDERER and _label_renderer and _block_name_label_id >= 0:
		_label_renderer.update_label_text(_block_name_label_id, new_name)
	elif block_name_label:
		block_name_label.text = new_name

## Gibt zurück ob das Block-Name-Label angezeigt werden soll.
##
## Kann von Subklassen überschrieben werden (z.B. ConditionBlock, ContainerBlock).
##
## @return: true wenn Label angezeigt werden soll, false sonst
func _should_show_block_name_label() -> bool:
	return true

## Wird aufgerufen wenn der Block seine Größe ändert.
func _on_size_changed():
	if USE_LABEL_RENDERER and _label_renderer and _block_name_label_id >= 0:
		_label_renderer.update_label(_block_name_label_id, "", Vector2(-99999, -99999), size.x, size.y)

## Aufräumen beim Entfernen des Blocks.
##
## Entfernt Labels vom Renderer und deselektiert den Block.
func _exit_tree():
	if USE_LABEL_RENDERER and _label_renderer and _block_name_label_id >= 0:
		_label_renderer.unregister_label(_block_name_label_id)
		_block_name_label_id = -1
	
	if is_selected:
		_deselect_block()

## Selektiert diesen Block.
##
## Deselektiert automatisch den zuvor selektierten Block.
func _select_block():
	if selected_block != null and selected_block != self and is_instance_valid(selected_block):
		selected_block._deselect_block()
	
	is_selected = true
	selected_block = self
	_update_selection_visual()
	
	print("[DraggableBlock] Block '%s' selektiert" % block_name)

## Deselektiert diesen Block.
func _deselect_block():
	is_selected = false
	if selected_block == self:
		selected_block = null
	_update_selection_visual()

## Setzt den Delete-Schutz und aktualisiert die visuelle Darstellung.
##
## @param protected: true zum Aktivieren des Schutzes, false zum Deaktivieren
func set_delete_protection(protected: bool):
	delete_protection = protected
	_update_selection_visual()
	print("[DraggableBlock] Block '%s' - Delete-Schutz: %s" % [block_name, "AN" if protected else "AUS"])

## Aktualisiert die visuelle Darstellung der Selektion.
##
## Zeigt einen Border bei Selektion (weiß) oder Delete-Protection (rot).
func _update_selection_visual():
	var stylebox = get_theme_stylebox("panel")
	if stylebox is StyleBoxFlat:
		var new_stylebox = stylebox.duplicate() as StyleBoxFlat
		new_stylebox.bg_color = color
		
		if is_selected:
			if delete_protection:
				new_stylebox.border_width_left = 1
				new_stylebox.border_width_right = 1
				new_stylebox.border_width_top = 1
				new_stylebox.border_width_bottom = 1
				new_stylebox.border_color = Color(1.0, 0.5, 0.5, 1.0)
			else:
				new_stylebox.border_width_left = 1
				new_stylebox.border_width_right = 1
				new_stylebox.border_width_top = 1
				new_stylebox.border_width_bottom = 1
				new_stylebox.border_color = Color(1.0, 1.0, 1.0, 1.0)
		else:
			new_stylebox.border_width_left = 0
			new_stylebox.border_width_right = 0
			new_stylebox.border_width_top = 0
			new_stylebox.border_width_bottom = 0
		
		add_theme_stylebox_override("panel", new_stylebox)
	
	modulate = Color(1.0, 1.0, 1.0, 1.0)

# Stellt sicher, dass der SnapIndicatorRenderer in der Szene existiert.
func _ensure_snap_indicator_renderer():
	SnapIndicatorRenderer.get_instance(get_tree())

func _process(_delta):
	_update_indicator_positions()

## Richtet die Standard-Snap-Zonen ein (Top und Bottom).
func _setup_default_snap_zones():
	# TOP Zone
	if snap_indicator_top:
		var top_zone = SnapZone.new(
			self, 
			snap_indicator_top, 
			SnapZone.ZoneType.TOP, 
			indicator_top_accepts, 
			"snap_above"
		)
		register_snap_zone(top_zone)
	
	# BOTTOM Zone
	if snap_indicator_bottom:
		var bottom_zone = SnapZone.new(
			self, 
			snap_indicator_bottom, 
			SnapZone.ZoneType.BOTTOM, 
			indicator_bottom_accepts, 
			"snap_below"
		)
		register_snap_zone(bottom_zone)

## Richtet die Standard-Hintergrundfarbe ein.
func _setup_default_color():
	var stylebox = get_theme_stylebox("panel")
	
	if stylebox is StyleBoxFlat:
		var new_stylebox = stylebox.duplicate() as StyleBoxFlat
		new_stylebox.bg_color = color
		add_theme_stylebox_override("panel", new_stylebox)

## GUI Input für Drag-and-Drop mit Selection-System.
##
## Verarbeitet Maus-Events für Drag-and-Drop:
## - Linksklick: Single-Drag (nur dieser Block)
## - Rechtsklick: Group-Drag (dieser Block + alle block_below)
##
## @param event: Das Input-Event
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Maus gedrückt - noch kein Drag, nur vorbereiten
				_mouse_pressed = true
				_mouse_press_position = get_global_mouse_position()
				_is_group_drag_pending = false
				_select_block()
			else:
				# Maus losgelassen
				if is_dragging:
					_on_drag_end()
				_mouse_pressed = false
				
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				# Rechtsklick für Group-Drag
				_mouse_pressed = true
				_mouse_press_position = get_global_mouse_position()
				_is_group_drag_pending = true
				_select_block()
			else:
				if is_dragging:
					_on_drag_end()
				_mouse_pressed = false
	
	elif event is InputEventMouseMotion:
		if _mouse_pressed and not is_dragging:
			var current_pos = get_global_mouse_position()
			var distance = _mouse_press_position.distance_to(current_pos)
			
			if distance > DRAG_THRESHOLD:
				var local_offset = _mouse_press_position - global_position
				_on_drag_start(local_offset, _is_group_drag_pending)
		
		if is_dragging:
			_on_drag_motion(get_global_mouse_position())

## Start des Drag-Vorgangs.
##
## Linksklick = Single-Drag (nur dieser Block)
## Rechtsklick = Group-Drag (dieser Block + alle block_below)
##
## @param local_click_pos: Lokale Click-Position relativ zum Block
## @param is_group_drag: true bei Group-Drag (Rechtsklick)
func _on_drag_start(local_click_pos: Vector2, is_group_drag: bool = false):
	var has_chain = block_below != null and is_instance_valid(block_below)

	var offset = local_click_pos
	
	if is_group_drag and has_chain:
		drag_state.start_group_drag(offset)
	else:
		drag_state.start_single_drag(offset)
	
	is_dragging = true

	_hide_snap_indicators()

	_disable_own_chain_zones()

	_detach_from_neighbors()
	
	z_index = DRAG_Z_INDEX
	if drag_state.is_group_drag():
		_set_chain_z_index(DRAG_Z_INDEX + 1)
	
	_set_drag_labels_z_index(true)
	drag_started.emit(self)

## Löst den Block von seinen Nachbarn (block_above/block_below).
##
## Behandelt verschiedene Fälle:
## - Single-Drag: Verbindet block_above mit block_below
## - Group-Drag: Trennt nur oben, untere Chain bleibt zusammen
## - Container-Kinder: Aktualisiert instruction_parent
func _detach_from_neighbors():
	var old_target = null
	
	if block_above:
		old_target = block_above
	
	var top = block_above
	var bottom = block_below
	
	if top and is_instance_valid(top) and bottom and is_instance_valid(bottom) and not drag_state.is_group_drag():
		top.block_below = bottom
		bottom.block_above = top
		
		block_above = null
		block_below = null
		
		if instruction_parent and is_instance_valid(instruction_parent):
			if instruction_parent.has_method("_update_block_size"):
				instruction_parent.call_deferred("_update_block_size")
			instruction_parent = null
		
		var head = top.get_chain_head()
		if head and is_instance_valid(head):
			head.reflow_chain_with_anchor(head.global_position)
		
		if old_target:
			detached_from.emit(old_target)
		return
	
	if top and is_instance_valid(top):
		if not (bottom and is_instance_valid(bottom) and not drag_state.is_group_drag()):
			top.block_below = null
		
		block_above = null
	
	if not drag_state.is_group_drag():
		if bottom and is_instance_valid(bottom):
			if not (top and is_instance_valid(top) and bottom and is_instance_valid(bottom)):
				bottom.block_above = null
			block_below = null
	
	if instruction_parent and is_instance_valid(instruction_parent):
		var is_head = false
		
		if instruction_parent is ContainerBlock:
			for zone_data in instruction_parent.instruction_zones:
				var zone_child = zone_data.get_first_child()
				if zone_child == self:
					is_head = true
					break
				
		if is_head:
			if drag_state.is_group_drag():
				if instruction_parent is ContainerBlock:
					for zone_data in instruction_parent.instruction_zones:
						if zone_data.get_first_child() == self:
							instruction_parent.set_instruction_zone_child(zone_data.zone_name, null)
							break
			else:
				if bottom and is_instance_valid(bottom):
					bottom.block_above = null
					
					if instruction_parent is ContainerBlock:
						for zone_data in instruction_parent.instruction_zones:
							if zone_data.get_first_child() == self:
								instruction_parent.set_instruction_zone_child(zone_data.zone_name, bottom)
								break
					
					if instruction_parent.has_method("_update_block_size"):
						instruction_parent.call_deferred("_update_block_size")
				else:
					if instruction_parent is ContainerBlock:
						for zone_data in instruction_parent.instruction_zones:
							if zone_data.get_first_child() == self:
								instruction_parent.set_instruction_zone_child(zone_data.zone_name, null)
								break
		else:
			if instruction_parent.has_method("_update_block_size"):
				instruction_parent.call_deferred("_update_block_size")
		
		if drag_state.is_group_drag():
			var current = self
			while current and is_instance_valid(current):
				current.instruction_parent = null
				current = current.block_below
		else:
			instruction_parent = null
	
	if "condition_parent" in self:
		var cond_parent = get("condition_parent")
		if cond_parent and is_instance_valid(cond_parent):
			if cond_parent.has_method("clear_condition_zone_child"):
				if "condition_zones" in cond_parent:
					for zone_data in cond_parent.condition_zones:
						if zone_data.get_child() == self:
							cond_parent.clear_condition_zone_child(zone_data.zone_name, self)
							break
			set("condition_parent", null)
	
	if old_target:
		detached_from.emit(old_target)

## Verarbeitet Drag-Bewegung.
##
## Aktualisiert Position, sucht Snap-Target und zeigt Indikatoren an.
##
## @param mouse_pos: Aktuelle Maus-Position
func _on_drag_motion(mouse_pos: Vector2):
	if not is_dragging:
		return
	
	var new_position = mouse_pos - drag_state.mouse_offset
	
	if current_snap_target and current_snap_target.is_valid():
		_hide_snap_indicator()
	
	current_snap_target = _find_snap_target(new_position)
	
	if current_snap_target and current_snap_target.is_valid():
		_show_snap_indicator()
	
	global_position = new_position
	_update_indicator_positions()
	
	if drag_state.is_group_drag():
		_update_chain_positions()

## Beendet den Drag-Vorgang.
##
## Wendet Snap an falls vorhanden, reaktiviert Zonen und setzt Z-Index zurück.
func _on_drag_end():
	if not is_dragging:
		return
	
	is_dragging = false
	
	if current_snap_target and current_snap_target.is_valid():
		_hide_snap_indicator()
	
	if current_snap_target and current_snap_target.is_valid():
		current_snap_target.apply_snap(self, drag_state.is_group_drag())
		snapped_to.emit(current_snap_target.target_block, current_snap_target.get_mode_string())
	
	_hide_all_indicators_in_scene()
	_enable_own_chain_zones()
	
	if not current_snap_target or not current_snap_target.is_valid():
		z_index = NORMAL_Z_INDEX
		if drag_state.is_group_drag():
			_set_chain_z_index(NORMAL_Z_INDEX)
	
	_set_drag_labels_z_index(false)
	
	drag_state.stop_drag()
	current_snap_target = null
	
	_deselect_block()
	
	drag_ended.emit(self)

## Findet das beste Snap-Target.
##
## KONZEPT: HIERARCHISCHES DRILL-DOWN MIT INSERTION-LINE
## Anstatt alle Blöcke gleichzeitig zu prüfen, traversieren wir von außen nach innen.
## WICHTIG: Die "Insertion Line" (Oberkante + 10px des gedraggerten Blocks) bestimmt,
## ob wir tiefer in einen Container gehen. Der gesamte Block-Rect wird nur für die
## Indikator-Kollision verwendet.
##
## ALGORITHMUS (Rekursiver Drill-Down):
## 1. Starte mit Root-Level-Blöcken (die keinen instruction_parent haben)
## 2. Prüfe für jeden Block, ob der gedraggte Block dessen Bounding-Box berührt
## 3. Wenn der Block ein Container ist:
##    - Prüfe ob die INSERTION-LINE den Container-Innenraum berührt
##    - Nur wenn JA: Gehe rekursiv in die Kinder
##    - Tieferer Container gewinnt nur wenn die Insertion-Line wirklich drin ist
## 4. Sammle Kandidaten auf jeder Ebene die vom Block-Rect berührt werden
## 5. Bei gleicher Ebene: Größere Überlappung mit Insertion-Line gewinnt
##
## @param my_position: Die Position des gedraggerten Blocks
## @return: Das beste SnapTarget oder null
func _find_snap_target(my_position: Vector2) -> SnapTarget:
	var block_rect = Rect2(my_position, size)
	
	var insertion_line_height = 10.0
	var insertion_line_rect = Rect2(my_position, Vector2(size.x, insertion_line_height))
	
	var root_blocks: Array[DraggableBlock] = _get_root_level_blocks()
	
	var candidates: Array[Dictionary] = []
	_drill_down_find_candidates(root_blocks, block_rect, insertion_line_rect, candidates, 0)
	
	if candidates.is_empty():
		return null
	
	var best_candidate = candidates[0]
	for i in range(1, candidates.size()):
		if _is_better_candidate(candidates[i], best_candidate):
			best_candidate = candidates[i]
	
	var mode = _zone_type_to_snap_mode(best_candidate.zone.zone_type)
	return SnapTarget.new(best_candidate.block, mode, best_candidate.zone)

## Gibt alle Root-Level-Blöcke zurück (ohne instruction_parent).
##
## @return: Array aller Root-Level-Blöcke
func _get_root_level_blocks() -> Array[DraggableBlock]:
	var root_blocks: Array[DraggableBlock] = []
	var all_nodes = get_tree().get_nodes_in_group("move_blocks")
	
	for node in all_nodes:
		if node is DraggableBlock:
			if node.instruction_parent == null or not is_instance_valid(node.instruction_parent):
				if node.block_above == null or not is_instance_valid(node.block_above):
					root_blocks.append(node)
	
	return root_blocks

## Rekursiver Drill-Down-Algorithmus.
##
## Traversiert von außen nach innen und sammelt Kandidaten.
## WICHTIG: Container-Kinder werden IMMER rekursiv durchsucht, auch wenn wir den
## Parent-Container nicht direkt berühren. Dies erlaubt das Snappen in tief
## verschachtelte Container, die horizontal versetzt sind.
##
## @param blocks: Array der zu prüfenden Blöcke
## @param block_rect: Gesamter Block für Indikator-Kollision
## @param insertion_line_rect: Schmaler Streifen an Oberkante für "Gehe tiefer in Container" Entscheidung
## @param candidates: Array zum Sammeln der Kandidaten (wird modifiziert)
## @param depth: Aktuelle Tiefe in der Container-Hierarchie
func _drill_down_find_candidates(blocks: Array[DraggableBlock], block_rect: Rect2, insertion_line_rect: Rect2, candidates: Array[Dictionary], depth: int):
	for block in blocks:
		if not is_instance_valid(block) or block == self:
			continue
		if _is_in_chain(block):
			continue
		if _would_create_cycle(block):
			continue
		
		var chain = _get_block_chain(block)
		
		var chain_bounds = _get_chain_bounding_box(chain)
		
		var touches_chain = block_rect.intersects(chain_bounds)
		
		for chain_block in chain:
			if chain_block is ContainerBlock:
				var container_children = _get_container_children(chain_block)
				if container_children.size() > 0:
					_drill_down_find_candidates(container_children, block_rect, insertion_line_rect, candidates, depth + 1)
				
				if block_rect.intersects(_get_container_inner_bounds(chain_block)):
					_collect_indicator_candidates(chain_block, block_rect, insertion_line_rect, candidates, depth)
		
		if touches_chain:
			for chain_block in chain:
				_collect_indicator_candidates(chain_block, block_rect, insertion_line_rect, candidates, depth)

## Sammelt Indikator-Kandidaten für einen Block.
##
## @param block: Der zu prüfende Block
## @param block_rect: Gesamter Block für Kollisionsprüfung
## @param insertion_line_rect: Schmaler Streifen für Überlappungsberechnung (Priorisierung)
## @param candidates: Array zum Sammeln der Kandidaten (wird modifiziert)
## @param depth: Aktuelle Tiefe in der Container-Hierarchie
func _collect_indicator_candidates(block: DraggableBlock, block_rect: Rect2, insertion_line_rect: Rect2, candidates: Array[Dictionary], depth: int):
	for zone in block.get_snap_zones():
		if not zone.can_accept(self):
			continue
		
		# Nutze get_indicator_rect() für das neue System (oder Fallback auf ColorRect)
		var indicator_rect = zone.get_indicator_rect()
		
		# Fallback: Falls das alte System verwendet wird (ColorRect vorhanden)
		if zone.indicator and is_instance_valid(zone.indicator):
			indicator_rect = Rect2(zone.indicator.global_position, zone.indicator.size)
		
		if not block_rect.intersects(indicator_rect):
			continue
		
		var overlap_with_insertion_line = _calculate_rect_overlap(insertion_line_rect, indicator_rect)
		
		var overlap_with_block = _calculate_rect_overlap(block_rect, indicator_rect)
		
		var indicator_y = indicator_rect.position.y
		
		var candidate = {
			"block": block,
			"zone": zone,
			"zone_type": zone.zone_type,
			"depth": depth,
			"overlap": overlap_with_insertion_line,
			"overlap_block": overlap_with_block,
			"insertion_line_touches": overlap_with_insertion_line > 0,
			"indicator_y": indicator_y  # Y-Position für symmetrische Priorisierung
		}
		candidates.append(candidate)

## Gibt die gesamte Block-Chain zurück (dieser Block + alle block_below).
##
## @param start_block: Der Start-Block der Chain
## @return: Array aller Blöcke in der Chain
func _get_block_chain(start_block: DraggableBlock) -> Array[DraggableBlock]:
	var chain: Array[DraggableBlock] = []
	var current = start_block
	var safety = 0
	
	while current and is_instance_valid(current) and safety < 1000:
		chain.append(current)
		current = current.block_below
		safety += 1
	
	return chain

## Berechnet die Bounding-Box einer Block-Chain.
##
## @param chain: Array der Blöcke in der Chain
## @return: Das Bounding-Rechteck der gesamten Chain
func _get_chain_bounding_box(chain: Array[DraggableBlock]) -> Rect2:
	if chain.is_empty():
		return Rect2()
	
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for block in chain:
		var block_pos = block.global_position
		var block_size = block.size
		var block_height = block.get_total_height()
		
		min_x = min(min_x, block_pos.x)
		min_y = min(min_y, block_pos.y)
		max_x = max(max_x, block_pos.x + block_size.x)
		max_y = max(max_y, block_pos.y + block_height)
	
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

## Gibt alle direkten Kinder eines Containers zurück (aus allen Instruction-Zonen).
##
## @param container: Der Container-Block
## @return: Array aller direkten Kinder
func _get_container_children(container: ContainerBlock) -> Array[DraggableBlock]:
	var children: Array[DraggableBlock] = []
	
	for zone_data in container.instruction_zones:
		var zone_child = zone_data.get_first_child()
		if zone_child and is_instance_valid(zone_child):
			children.append(zone_child)
	
	return children

## Berechnet die innere Bounding-Box eines Containers (wo Kinder sein können).
##
## @param container: Der Container-Block
## @return: Das innere Bounding-Rechteck
func _get_container_inner_bounds(container: ContainerBlock) -> Rect2:
	var min_y = INF
	var max_y = -INF
	var min_x = container.global_position.x
	var max_x = container.global_position.x + container.size.x
	
	for zone_data in container.instruction_zones:
		if zone_data.indicator and is_instance_valid(zone_data.indicator):
			var ind_pos = zone_data.indicator.global_position
			min_y = min(min_y, ind_pos.y)
			max_y = max(max_y, container.global_position.y + container.get_total_height())
	
	if min_y == INF:
		min_y = container.global_position.y + 30  # Approximation für Header
		max_y = container.global_position.y + container.get_total_height() - 20
	
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

## Berechnet die Überlappungsfläche zweier Rects.
##
## @param rect_a: Erstes Rechteck
## @param rect_b: Zweites Rechteck
## @return: Die Überlappungsfläche in Quadratpixeln
func _calculate_rect_overlap(rect_a: Rect2, rect_b: Rect2) -> float:
	var overlap_x = max(0.0, min(rect_a.end.x, rect_b.end.x) - max(rect_a.position.x, rect_b.position.x))
	var overlap_y = max(0.0, min(rect_a.end.y, rect_b.end.y) - max(rect_a.position.y, rect_b.position.y))
	return overlap_x * overlap_y

## Vergleicht zwei Kandidaten und gibt true zurück wenn 'a' besser ist als 'b'.
##
## Priorisierung:
## 1. Insertion-Line Berührung bevorzugt (BEIDE müssen verglichen werden)
## 2. NUR wenn Insertion-Line berührt wird: Tiefere Container & Hierarchie-Regeln
## 3. Wenn KEINER von Insertion-Line berührt: Nur Y-Position entscheidet
## 4. Bei gleicher Y-Position: Größere Überlappung gewinnt
##
## @param a: Erster Kandidat (Dictionary)
## @param b: Zweiter Kandidat (Dictionary)
## @return: true wenn a besser ist als b
func _is_better_candidate(a: Dictionary, b: Dictionary) -> bool:
	var a_insertion_touches = a.get("insertion_line_touches", false)
	var b_insertion_touches = b.get("insertion_line_touches", false)
	
	var a_zone_type = a.get("zone_type", -1)
	var b_zone_type = b.get("zone_type", -1)
	
	if a_insertion_touches != b_insertion_touches:
		return a_insertion_touches
	
	if not a_insertion_touches and not b_insertion_touches:
		# Nur Y-Position für symmetrisches Verhalten
		var a_y_fallback = a.get("indicator_y", 0.0)
		var b_y_fallback = b.get("indicator_y", 0.0)
		
		var y_tol_fallback = 5.0
		if abs(a_y_fallback - b_y_fallback) > y_tol_fallback:
			return a_y_fallback < b_y_fallback
		
		var a_overlap_fallback = a.get("overlap_block", 0.0)
		var b_overlap_fallback = b.get("overlap_block", 0.0)
		return a_overlap_fallback > b_overlap_fallback
	
	if a.depth != b.depth:
		return a.depth > b.depth
	
	if _is_ancestor_container(a.block, b.block):
		if a_zone_type == SnapZone.ZoneType.BOTTOM:
			return false  # b ist besser (ist tiefer drin)
		if a_zone_type == SnapZone.ZoneType.INSTRUCTION:
			return true  # INSTRUCTION vom äußeren Container ist OK
	
	if _is_ancestor_container(b.block, a.block):
		if b_zone_type == SnapZone.ZoneType.BOTTOM:
			return true  # a ist besser (ist tiefer drin)
		if b_zone_type == SnapZone.ZoneType.INSTRUCTION:
			return false  # INSTRUCTION vom äußeren Container ist OK
	
	if a.block == b.block:
		if a_zone_type == SnapZone.ZoneType.INSTRUCTION and b_zone_type == SnapZone.ZoneType.BOTTOM:
			return true
		if b_zone_type == SnapZone.ZoneType.INSTRUCTION and a_zone_type == SnapZone.ZoneType.BOTTOM:
			return false
	
	var a_indicator_y = a.get("indicator_y", 0.0)
	var b_indicator_y = b.get("indicator_y", 0.0)
	
	var y_tolerance = 5.0
	
	if abs(a_indicator_y - b_indicator_y) > y_tolerance:
		return a_indicator_y < b_indicator_y
	
	var a_overlap = a.get("overlap", 0.0)
	var b_overlap = b.get("overlap", 0.0)
	
	if a_overlap != b_overlap:
		return a_overlap > b_overlap
	
	var a_overlap_block = a.get("overlap_block", 0.0)
	var b_overlap_block = b.get("overlap_block", 0.0)
	return a_overlap_block > b_overlap_block

## Prüft rekursiv, ob ancestor_block ein Vorfahre von child_block ist.
##
## D.h. child_block ist in der Container-Hierarchie von ancestor_block.
##
## @param ancestor_block: Der potenzielle Vorfahren-Block
## @param child_block: Der potenzielle Kind-Block
## @return: true wenn ancestor_block ein Vorfahre von child_block ist
func _is_ancestor_container(ancestor_block: DraggableBlock, child_block: DraggableBlock) -> bool:
	if not ancestor_block or not child_block:
		return false
	if not is_instance_valid(ancestor_block) or not is_instance_valid(child_block):
		return false
	if ancestor_block == child_block:
		return false
	
	var current = child_block.instruction_parent
	var safety = 0
	
	while current and is_instance_valid(current) and safety < 100:
		if current == ancestor_block:
			return true
		if "instruction_parent" in current:
			current = current.instruction_parent
		else:
			break
		safety += 1
	
	return false


## Konvertiert ZoneType zu SnapMode.
##
## @param zone_type: Der SnapZone.ZoneType
## @return: Der entsprechende SnapTarget.SnapMode
func _zone_type_to_snap_mode(zone_type: SnapZone.ZoneType) -> SnapTarget.SnapMode:
	match zone_type:
		SnapZone.ZoneType.TOP:
			return SnapTarget.SnapMode.ABOVE
		SnapZone.ZoneType.BOTTOM:
			return SnapTarget.SnapMode.BELOW
		SnapZone.ZoneType.CONDITION:
			return SnapTarget.SnapMode.CONDITION
		SnapZone.ZoneType.INSTRUCTION:
			return SnapTarget.SnapMode.INSTRUCTION
		_:
			return SnapTarget.SnapMode.BELOW

## Prüft ob ein Block in dieser Kette ist.
##
## @param block: Der zu prüfende Block
## @return: true wenn der Block in der Kette ist
func _is_in_chain(block: DraggableBlock) -> bool:
	if block == null or not is_instance_valid(block):
		return false
	var stack = [self]
	var visited = []
	var steps = 0
	while stack.size() > 0 and steps < 5000:
		var current = stack.pop_back()
		if visited.has(current):
			steps += 1
			continue
		visited.append(current)
		if current == block:
			return true
		if current.block_below and is_instance_valid(current.block_below) and not visited.has(current.block_below):
			stack.append(current.block_below)
		if current.block_above and is_instance_valid(current.block_above) and not visited.has(current.block_above):
			stack.append(current.block_above)
		for zone in current.get_snap_zones():
			if zone.child_block and is_instance_valid(zone.child_block) and not visited.has(zone.child_block):
				stack.append(zone.child_block)
		steps += 1
	return false

## Prüft ob target_block ein Kind dieses Blocks ist (verhindert zirkuläre Verschachtelung).
##
## Wenn wir z.B. Container A sind und A in einen Container B schieben wollen,
## prüft dies ob B bereits ein Kind von A ist (was einen Zyklus erzeugen würde).
##
## @param target_block: Der Ziel-Block
## @return: true wenn ein Zyklus entstehen würde
func _would_create_cycle(target_block: DraggableBlock) -> bool:
	if target_block == self:
		return true
	
	var stack = [self]
	var visited: Dictionary = {}
	var steps = 0
	
	while stack.size() > 0 and steps < 5000:
		var current = stack.pop_back()
		if visited.has(current):
			steps += 1
			continue
		visited[current] = true
		
		if current is ContainerBlock:
			for zone_data in current.instruction_zones:
				var zone_child = zone_data.get_first_child()
				if zone_child and is_instance_valid(zone_child):
					if zone_child == target_block:
						return true
					if not visited.has(zone_child):
						stack.append(zone_child)
			
			for cond_zone_data in current.condition_zones:
				var cond_child = cond_zone_data.get_child()
				if cond_child and is_instance_valid(cond_child):
					if cond_child == target_block:
						return true
					if not visited.has(cond_child):
						stack.append(cond_child)
		
		var below = current.block_below
		if below and is_instance_valid(below):
			if below == target_block:
				return true
			if not visited.has(below):
				stack.append(below)
		
		steps += 1
	
	return false

## Zeigt den passenden Indikator an.
func _show_snap_indicator():
	if not current_snap_target or not current_snap_target.is_valid():
		return
	
	var zone = current_snap_target.target_zone
	
	if not zone or not is_instance_valid(zone):
		var target = current_snap_target.target_block
		var mode_string = current_snap_target.get_mode_string()
		zone = target.find_zone_by_mode(mode_string)
	
	if zone:
		zone.show_indicator()

## Versteckt den aktuellen Snap-Indikator.
func _hide_snap_indicator():
	if current_snap_target and current_snap_target.is_valid():
		var zone = current_snap_target.target_zone
		
		if not zone or not is_instance_valid(zone):
			var target = current_snap_target.target_block
			var mode_string = current_snap_target.get_mode_string()
			zone = target.find_zone_by_mode(mode_string)
		
		if zone:
			zone.hide_indicator()

## Versteckt alle Indikatoren dieses Blocks.
func _hide_snap_indicators():
	if DEBUG_SHOW_INDICATORS:
		return  # Im Debug-Modus Indikatoren immer sichtbar lassen
	for zone in snap_zones:
		zone.hide_indicator()

## Versteckt alle Indikatoren in der gesamten Szene.
func _hide_all_indicators_in_scene():
	if DEBUG_SHOW_INDICATORS:
		return  # Im Debug-Modus Indikatoren immer sichtbar lassen
	
	# Lösche alle Indikatoren vom zentralen Renderer
	var renderers = get_tree().get_nodes_in_group("snap_indicator_renderer")
	if renderers.size() > 0:
		renderers[0].clear_all_indicators()
	
	var all_blocks = get_tree().get_nodes_in_group("move_blocks")
	for block in all_blocks:
		if block is DraggableBlock:
			block._hide_snap_indicators()

## Deaktiviert eigene Top/Bottom Zonen (verhindert Selbst-Snap).
func _disable_own_chain_zones():
	for zone in snap_zones:
		if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
			zone.set_enabled(false)
	
	if drag_state.is_group_drag():
		var current = block_below
		var safety = 0
		while current and is_instance_valid(current) and safety < 100:
			safety += 1
			for zone in current.snap_zones:
				if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
					zone.set_enabled(false)
			current = current.block_below

## Aktiviert eigene Top/Bottom Zonen wieder.
func _enable_own_chain_zones():
	for zone in snap_zones:
		if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
			zone.set_enabled(true)
	
	if drag_state.is_group_drag():
		var current = block_below
		var safety = 0
		while current and is_instance_valid(current) and safety < 100:
			safety += 1
			for zone in current.snap_zones:
				if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
					zone.set_enabled(true)
			current = current.block_below


## Aktualisiert die Positionen der Snap-Indikatoren.
func _update_indicator_positions():
	if not is_inside_tree():
		return
	
	# Update alle SnapZone-Breiten basierend auf der aktuellen Block-Größe
	for zone in snap_zones:
		if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
			zone.set_indicator_width(size.x)
	
	# Legacy: Falls ColorRects noch vorhanden sind, aktualisiere deren Positionen
	# Dies kann entfernt werden, sobald alle Szenen auf das neue System umgestellt sind
	if snap_indicator_top and is_instance_valid(snap_indicator_top):
		snap_indicator_top.size.x = size.x
		snap_indicator_top.global_position = global_position
	
	if snap_indicator_bottom and is_instance_valid(snap_indicator_bottom):
		snap_indicator_bottom.size.x = size.x
		var bottom_y = global_position.y + get_total_height()
		snap_indicator_bottom.global_position = Vector2(global_position.x, bottom_y)

## Update Chain-Positionen bei Group-Drag.
func _update_chain_positions():
	var current = block_below
	var offset_y = get_total_height()
	
	while current and is_instance_valid(current):
		current.global_position = Vector2(global_position.x, global_position.y + offset_y)
		current._update_indicator_positions()
		if current is LoopBlock and current.has_method("_update_children_positions_direct"):
			current.call("_update_children_positions_direct")
		offset_y += current.get_total_height()
		current = current.block_below

## Setzt Z-Index für die gesamte Kette.
##
## @param index: Der neue Z-Index
func _set_chain_z_index(index: int):
	var current = block_below
	while current and is_instance_valid(current):
		current.z_index = index
		current = current.block_below

## Setzt den LabelRenderer z_index für alle Labels der Drag-Gruppe.
##
## @param is_starting_drag: true beim Drag-Start, false beim Drag-Ende
func _set_drag_labels_z_index(is_starting_drag: bool):
	if not _label_renderer:
		return
	
	# Sammle alle Blöcke der Drag-Gruppe (rekursiv)
	var drag_blocks: Array = []
	_collect_drag_blocks_recursive(self, drag_blocks)
	
	# Informiere den LabelRenderer
	_label_renderer.set_owners_dragging(drag_blocks, is_starting_drag)

## Sammelt alle Blöcke die zur Drag-Gruppe gehören (rekursiv für Container).
##
## @param block: Der zu verarbeitende Block
## @param result: Array zum Sammeln der Blöcke (wird modifiziert)
func _collect_drag_blocks_recursive(block: DraggableBlock, result: Array):
	if not block or not is_instance_valid(block):
		return
	
	result.append(block)
	
	# Bei Group-Drag auch alle block_below sammeln
	if drag_state.is_group_drag():
		var current = block.block_below
		while current and is_instance_valid(current):
			_collect_drag_blocks_recursive(current, result)
			current = current.block_below
	
	# Container-Kinder sammeln
	if block is ContainerBlock:
		for zone_data in block.instruction_zones:
			var child = zone_data.get_first_child()
			while child and is_instance_valid(child):
				_collect_drag_blocks_recursive(child, result)
				child = child.block_below


## Registriert eine SnapZone bei diesem Block.
##
## @param zone: Die zu registrierende SnapZone
func register_snap_zone(zone: SnapZone):
	if not snap_zones.has(zone):
		snap_zones.append(zone)

## Gibt alle SnapZones dieses Blocks zurück.
##
## @return: Array aller SnapZones
func get_snap_zones() -> Array[SnapZone]:
	return snap_zones

## Findet eine SnapZone anhand des Snap-Modus.
##
## @param mode: Der Snap-Modus String (z.B. "snap_above")
## @return: Die gefundene SnapZone oder null
func find_zone_by_mode(mode: String) -> SnapZone:
	for zone in snap_zones:
		if zone.snap_mode_string == mode:
			return zone
	return null


## Gibt die Gesamthöhe des Blocks zurück (ohne Kinder).
##
## @param visited: Dictionary zur Zyklus-Erkennung (optional)
## @return: Die Höhe des Blocks
func get_total_height(visited: Dictionary = {}) -> float:
	if visited.has(self):
		push_warning("[DraggableBlock] Zyklus in get_total_height erkannt bei: %s" % block_name)
		return 0.0
	visited[self] = true
	
	return size.y


## Gibt den obersten Block in der Kette zurück.
##
## @return: Der Kopf der Chain
func get_chain_head() -> DraggableBlock:
	var head = self
	var safety = 0
	while head.block_above and is_instance_valid(head.block_above) and safety < 1000:
		head = head.block_above
		safety += 1
	return head

## Gibt den untersten Block in der Kette zurück.
##
## @return: Das Ende der Chain
func get_chain_tail() -> DraggableBlock:
	var tail = self
	while tail.block_below and is_instance_valid(tail.block_below):
		tail = tail.block_below
	return tail

## Entfernt äußere Verbindungen der gesamten Kette (head.block_above und tail.block_below).
func detach_chain_links() -> void:
	# Kopf oben trennen
	var head = get_chain_head()
	if head and is_instance_valid(head):
		if head.block_above and is_instance_valid(head.block_above):
			head.block_above.block_below = null
			head.block_above = null
	# Schwanz unten trennen
	var tail = get_chain_tail()
	if tail and is_instance_valid(tail):
		if tail.block_below and is_instance_valid(tail.block_below):
			tail.block_below.block_above = null
			tail.block_below = null

## Reflow: Ordnet die Kette neu, so dass THIS Block an anchor_pos bleibt.
##
## Alle Blöcke darüber/darunter werden korrekt positioniert.
##
## @param anchor_pos: Die Anker-Position für diesen Block
func reflow_chain_with_anchor(anchor_pos: Vector2) -> void:
	global_position = anchor_pos
	if has_method("_update_indicator_positions"):
		_update_indicator_positions()
	if self is LoopBlock and has_method("_update_children_positions_direct"):
		call("_update_children_positions_direct")
	
	var cur = block_below
	var offset_y = get_total_height()
	var steps = 0
	while cur and is_instance_valid(cur) and steps < 2000:
		cur.global_position = Vector2(global_position.x, global_position.y + offset_y)
		if cur.has_method("_update_indicator_positions"):
			cur._update_indicator_positions()
		if cur is LoopBlock and cur.has_method("_update_children_positions_direct"):
			cur.call("_update_children_positions_direct")
		offset_y += cur.get_total_height()
		cur = cur.block_below
		steps += 1
	if steps >= 2000:
		push_error("[DraggableBlock] reflow_chain_with_anchor: Abgebrochen wegen zu vielen Schritten (unten) - mögliche Zyklus")
	
	var cum = 0.0
	var cur_up = block_above
	steps = 0
	while cur_up and is_instance_valid(cur_up) and steps < 2000:
		cum += cur_up.get_total_height()
		cur_up.global_position = Vector2(global_position.x, global_position.y - cum)
		if cur_up.has_method("_update_indicator_positions"):
			cur_up._update_indicator_positions()
		# Wenn dieser Block ein Loop ist, aktualisiere dessen innere Children
		if cur_up is LoopBlock and cur_up.has_method("_update_children_positions_direct"):
			cur_up.call("_update_children_positions_direct")
		cur_up = cur_up.block_above
		steps += 1
	if steps >= 2000:
		push_error("[DraggableBlock] reflow_chain_with_anchor: Abgebrochen wegen zu vielen Schritten (oben) - mögliche Zyklus")

## Initialisiert Standard-BlockData wenn keine vorhanden ist.
##
## Wird von Subklassen überschrieben um spezifische Daten zu erstellen.
func _init_default_data():
	data = BlockData.new()
	data.block_type = BlockData.BlockType.BASE
	data.block_id = _generate_block_id()
	data.position = global_position

## Generiert eine eindeutige Block-ID.
##
## @return: Die generierte ID
func _generate_block_id() -> String:
	return "%s_%d" % [block_name.to_lower().replace(" ", "_"), Time.get_ticks_msec()]

## Synchronisiert UI von BlockData.
##
## Wird von Subklassen überschrieben um spezifische Daten zu laden.
func _sync_from_data():
	if not data:
		return
	
	# Basis-Synchronisation
	if data.position != Vector2.ZERO:
		global_position = data.position
	# Subklassen überschreiben diese Methode für ihre spezifischen Daten

## Synchronisiert BlockData von UI.
##
## Wird von Subklassen überschrieben um spezifische Daten zu speichern.
func _sync_to_data():
	if not data:
		return
	# Basis-Synchronisation
	data.position = global_position
	# Subklassen überschreiben diese Methode für ihre spezifischen Daten

## Extrahiert BlockData aus diesem Block (inkl. verschachtelter Blöcke).
##
## Wird von Subklassen überschrieben für Container/Condition-Blöcke.
##
## @return: Die BlockData dieses Blocks
func to_block_data() -> BlockData:
	_sync_to_data()
	
	if data:
		return data.duplicate_data()
	
	# Fallback: Erstelle neue BlockData
	var block_data = BlockData.new()
	block_data.block_type = BlockData.BlockType.BASE
	block_data.block_id = _generate_block_id()
	block_data.position = global_position
	return block_data

## Erstellt einen Block aus BlockData (Factory-Methode).
##
## Muss von Subklassen implementiert werden.
##
## @param block_data: Die BlockData mit der Konfiguration
## @param block_scene: Die PackedScene für den Block
## @return: Der erstellte Block oder null bei Fehler
static func from_block_data(block_data: BlockData, block_scene: PackedScene) -> DraggableBlock:
	if not block_scene:
		push_error("[DraggableBlock] from_block_data: Kein block_scene übergeben")
		return null
	
	var block = block_scene.instantiate() as DraggableBlock
	if not block:
		push_error("[DraggableBlock] from_block_data: Konnte Block nicht instanziieren")
		return null
	
	block.data = block_data
	return block

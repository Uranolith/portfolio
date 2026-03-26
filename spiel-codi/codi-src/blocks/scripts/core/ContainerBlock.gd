## Generischer Basis-Block für Container mit N Instruction-Zonen und N Condition-Zonen.
##
## Diese Klasse bietet die Grundfunktionalität für alle Container-Blöcke wie Loop und
## Case-Distinction. Sie unterstützt beliebig viele Instruction-Zonen (z.B. Loop: 1 Zone,
## Case: 2 Zonen) und Condition-Zonen (z.B. While: 1 Zone, Switch-Case: N Zonen).
##
## Subklassen müssen _setup_custom_snap_zones() überschreiben, um ihre spezifischen
## Zonen zu konfigurieren.
class_name ContainerBlock
extends DraggableBlock

## Akzeptierte Kategorien für Condition-Zonen-Indikatoren
@export var indicator_condition_accepts: Array[int] = [SnapCategory.CONDITION]

## Akzeptierte Kategorien für Instruction-Zonen-Indikatoren
@export var indicator_instruction_accepts: Array[int] = [SnapCategory.FLOW]

## Referenz zum Haupt-Container Control
@export var main_container_control: Control

@onready var main_container: Control = main_container_control

## Array aller Instruction-Zonen
var instruction_zones: Array[InstructionZoneData] = []

## Array aller Condition-Zonen
var condition_zones: Array = []  # Array von ConditionZoneDataClass

## Minimale innere Höhe des Containers
@export var min_inner_height: float = 40.0

## Padding am unteren Rand
@export var padding_bottom: float = 0.0

## Initiale Block-Höhe
var _initial_block_height: float = 0.0

## Aktuelle gültige Höhe
var _current_valid_height: float = 0.0

## Dictionary zum Tracking von Zonen-Label-IDs beim LabelRenderer
## Format: zone_name -> label_id
var _zone_label_ids: Dictionary = {}


func _ready():
	super._ready()
	
	_setup_custom_snap_zones()
	
	_initialize_sizes()
	
	# HINWEIS: _setup_zone_labels_for_renderer() wird von Subklassen aufgerufen
	# NACHDEM sie _link_instruction_zones() und _link_condition_zones() aufgerufen haben
	
	await get_tree().process_frame

	_update_indicator_positions()

## Container-Blöcke zeigen kein Block-Name-Label.
##
## @return: Immer false
func _should_show_block_name_label() -> bool:
	return false

## Registriert alle Zonen-Labels beim LabelRenderer.
##
## Diese Methode sollte von Subklassen aufgerufen werden, NACHDEM
## _link_instruction_zones() und _link_condition_zones() ausgeführt wurden.
func _setup_zone_labels_for_renderer():
	if not _label_renderer:
		_label_renderer = LabelRenderer.get_instance(get_tree())
	
	# Instruction-Zonen Labels
	for zone_data in instruction_zones:
		if zone_data.label and is_instance_valid(zone_data.label):
			zone_data.label.modulate.a = 0.0
			
			var label_id = _label_renderer.register_label(
				zone_data.label,
				zone_data.label.text,
				Vector2.ZERO,
				Color(-1, -1, -1, -1),
				zone_data.label.horizontal_alignment,
				zone_data.label.vertical_alignment,
				zone_data.label.size.x,
				zone_data.label.size.y
			)
			_zone_label_ids["instr_" + zone_data.zone_name] = label_id
	
	# Condition-Zonen Labels
	for cond_zone in condition_zones:
		if cond_zone.label and is_instance_valid(cond_zone.label):
			cond_zone.label.modulate.a = 0.0
			
			var label_id = _label_renderer.register_label(
				cond_zone.label,
				cond_zone.label.text,
				Vector2.ZERO,
				Color(-1, -1, -1, -1),
				cond_zone.label.horizontal_alignment,
				cond_zone.label.vertical_alignment,
				cond_zone.label.size.x,
				cond_zone.label.size.y
			)
			_zone_label_ids["cond_" + cond_zone.zone_name] = label_id

## Aktualisiert die Sichtbarkeit eines Zonen-Labels beim Renderer.
##
## @param zone_key: Der Zonen-Schlüssel (z.B. "instr_instruction" oder "cond_case")
## @param label_visible: Sichtbarkeit des Labels
func _update_renderer_zone_label_visibility(zone_key: String, label_visible: bool):
	if USE_LABEL_RENDERER and _label_renderer and _zone_label_ids.has(zone_key):
		_label_renderer.update_label_visibility(_zone_label_ids[zone_key], label_visible)

## Aufräumen beim Entfernen des Blocks - überschreibt DraggableBlock.
func _exit_tree():
	if USE_LABEL_RENDERER and _label_renderer and _block_name_label_id >= 0:
		_label_renderer.unregister_label(_block_name_label_id)
		_block_name_label_id = -1
	
	if USE_LABEL_RENDERER and _label_renderer:
		for label_id in _zone_label_ids.values():
			_label_renderer.unregister_label(label_id)
		_zone_label_ids.clear()

## Überschreibt _process um Block-Größe kontinuierlich zu aktualisieren.
func _process(_delta):
	# Rufe Parent _process auf (aktualisiert Indikatoren)
	super._process(_delta)

## Virtuelle Methode: Wird von Subklassen überschrieben um Condition/Instruction-Zonen zu konfigurieren.
##
## Subklassen sollten hier setup_condition_zones() und setup_instruction_zones()
## aufrufen, um ihre spezifischen Zonen zu definieren.
func _setup_custom_snap_zones():
	pass

## Setup für generische Condition-Zonen.
##
## Kann von Subklassen aufgerufen werden um N Condition-Zonen zu erstellen.
##
## @param configs: Array von Dictionaries mit {zone_name: String, indicator: ColorRect, ...}
func setup_condition_zones(configs: Array[Dictionary]):
	condition_zones.clear()
	
	for config in configs:
		var zone_data = ConditionZoneData.new(config)
		condition_zones.append(zone_data)

## Verlinkt Condition-Zonen mit SnapZones (NACH _ready).
##
## Erstellt für jede Condition-Zone eine SnapZone und registriert sie.
## Diese Methode sollte von Subklassen nach setup_condition_zones() aufgerufen werden.
func _link_condition_zones():
	for zone_data in condition_zones:
		if zone_data.indicator and is_instance_valid(zone_data.indicator):
			var snap_zone := SnapZone.new(
				self,
				zone_data.indicator,
				SnapZone.ZoneType.CONDITION,
				zone_data.accepts,
				"snap_" + zone_data.zone_name
			)
			zone_data.zone = snap_zone
			register_snap_zone(snap_zone)

## Initialisiert Größen-Werte.
func _initialize_sizes():
	_initial_block_height = custom_minimum_size.y
	if _initial_block_height == 0.0:
		_initial_block_height = 80.0
	
	_current_valid_height = _initial_block_height

## Setup für generische Instruction-Zonen.
##
## Kann von Subklassen aufgerufen werden um N Zonen zu erstellen.
##
## @param configs: Array von Dictionaries mit {zone_name: String, inner_container: Control, ...}
func setup_instruction_zones(configs: Array[Dictionary]):
	instruction_zones.clear()
	
	for config in configs:
		var zone_data := InstructionZoneData.new(config)
		instruction_zones.append(zone_data)

## Überschreibt die Indikator-Versteck-Logik um auch Condition/Instruction-Zonen zu verstecken.
func _hide_snap_indicators():
	super._hide_snap_indicators()
	
	for cond_zone_data in condition_zones:
		if cond_zone_data.zone:
			cond_zone_data.zone.hide_indicator()
		elif cond_zone_data.indicator and is_instance_valid(cond_zone_data.indicator):
			cond_zone_data.indicator.visible = false
	
	for zone_data in instruction_zones:
		if zone_data.zone:
			zone_data.zone.hide_indicator()
		elif zone_data.indicator and is_instance_valid(zone_data.indicator):
			zone_data.indicator.visible = false

## Gibt das Child einer Condition-Zone zurück.
##
## @param zone_name: Der Name der Zone
## @return: Der Block in dieser Zone oder null
func get_condition_zone_child(zone_name: String) -> DraggableBlock:
	for zone_data in condition_zones:
		if zone_data.zone_name == zone_name:
			return zone_data.get_child()
	return null

## Setzt das Child einer Condition-Zone.
##
## @param zone_name: Der Name der Zone
## @param child: Der Block, der in die Zone gesetzt werden soll
func set_condition_zone_child(zone_name: String, child: DraggableBlock):
	for zone_data in condition_zones:
		if zone_data.zone_name == zone_name:
			zone_data.set_child(child)
			zone_data.update_label_visibility()
			# Setze z_index für Kind höher als Container
			if child and is_instance_valid(child):
				_update_child_z_index(child)
			_update_condition_zone_position(zone_data)
			return
	
	push_warning("[ContainerBlock.set_condition_zone_child] Unknown zone '%s'" % zone_name)

## Löscht das Child einer Condition-Zone.
##
## @param zone_name: Der Name der Zone
## @param child: Der zu löschende Block (optional)
## @return: true wenn erfolgreich, false sonst
func clear_condition_zone_child(zone_name: String, child: DraggableBlock = null) -> bool:
	for zone_data in condition_zones:
		if zone_data.zone_name == zone_name:
			var result = zone_data.clear_child(child)
			zone_data.update_label_visibility()
			if has_method("_update_block_size"):
				call_deferred("_update_block_size")
			return result
	return false

## Gibt die ConditionZoneData per Name zurück.
##
## @param zone_name: Der Name der Zone
## @return: Die ConditionZoneData oder null
func get_condition_zone(zone_name: String):  # -> ConditionZoneDataClass
	for zone_data in condition_zones:
		if zone_data.zone_name == zone_name:
			return zone_data
	return null

## Gibt das erste Child einer Instruction-Zone zurück.
##
## @param zone_name: Der Name der Zone
## @return: Der erste Block in dieser Zone oder null
func get_instruction_zone_child(zone_name: String) -> DraggableBlock:
	for zone_data in instruction_zones:
		if zone_data.zone_name == zone_name:
			return zone_data.get_first_child()
	return null

## Setzt das erste Child einer Instruction-Zone.
##
## @param zone_name: Der Name der Zone
## @param child: Der Block, der in die Zone gesetzt werden soll
func set_instruction_zone_child(zone_name: String, child: DraggableBlock):
	for zone_data in instruction_zones:
		if zone_data.zone_name == zone_name:
			zone_data.set_first_child(child)
			_update_zone_label_visibility(zone_data)
			
			if child and is_instance_valid(child):
				_update_child_z_index(child)
				# Alle Blöcke in der Chain im Szenenbaum nach vorne verschieben
				var current = child
				while current and is_instance_valid(current):
					_ensure_child_above_in_tree(current)
					current = current.block_below
			call_deferred("_update_block_size")
			return
	
	push_warning("[ContainerBlock.set_instruction_zone_child] Unknown zone '%s'" % zone_name)

## Gibt die InstructionZoneData per Name zurück.
##
## @param zone_name: Der Name der Zone
## @return: Die InstructionZoneData oder null
func get_instruction_zone(zone_name: String) -> InstructionZoneData:
	for zone_data in instruction_zones:
		if zone_data.zone_name == zone_name:
			return zone_data
	return null

## Aktualisiert die Label-Sichtbarkeit einer Instruction-Zone.
##
## Das Label ist nur sichtbar wenn die Zone leer ist.
##
## @param zone_data: Die InstructionZoneData
func _update_zone_label_visibility(zone_data: InstructionZoneData):
	var zone_child = zone_data.get_first_child()
	var is_empty = (zone_child == null or not is_instance_valid(zone_child))
	
	if USE_LABEL_RENDERER:
		_update_renderer_zone_label_visibility("instr_" + zone_data.zone_name, is_empty)
	elif zone_data.label and is_instance_valid(zone_data.label):
		zone_data.label.visible = is_empty

## Aktualisiert alle Zone-Labels (Instruction + Condition).
func _update_all_zone_labels():
	# Instruction-Zonen
	for zone_data in instruction_zones:
		_update_zone_label_visibility(zone_data)
	
	# Condition-Zonen
	for cond_zone_data in condition_zones:
		if USE_LABEL_RENDERER:
			var is_empty = (cond_zone_data.get_child() == null)
			_update_renderer_zone_label_visibility("cond_" + cond_zone_data.zone_name, is_empty)
		else:
			cond_zone_data.update_label_visibility()

## Aktualisiert alle Indikator-Positionen und (bei Drag) auch die Children-Positionen.
func _update_indicator_positions():
	if not is_inside_tree():
		return
	
	_update_indicator_positions_internal()
	
	if is_dragging:
		_update_children_positions_direct()

## Interne Methode: Aktualisiert nur die Indikatoren ohne Children-Update.
##
## Wird von _update_indicator_positions UND _update_children_positions_direct verwendet.
func _update_indicator_positions_internal():
	for zone in snap_zones:
		if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
			zone.set_indicator_width(size.x)
	
	# Legacy ColorRects (für Positionsreferenz bei Children)
	if is_instance_valid(snap_indicator_top):
		snap_indicator_top.size.x = size.x
		snap_indicator_top.global_position = global_position
	
	if is_instance_valid(snap_indicator_bottom):
		snap_indicator_bottom.size.x = size.x
		var bottom_y = global_position.y + get_total_height()
		snap_indicator_bottom.global_position = Vector2(global_position.x, bottom_y)
	
	# Alle Condition-Zonen-Indikatoren positionieren
	for cond_zone_data in condition_zones:
		var offset = cond_zone_data.get_offset()
		var ind_width = size.x - 20.0
		var ind_pos = Vector2(global_position.x + offset.x, global_position.y + offset.y)
		
		if cond_zone_data.zone:
			cond_zone_data.zone.indicator_width = ind_width
			cond_zone_data.zone.indicator_offset = offset
		
		# Legacy ColorRect (für Positionsreferenz)
		if cond_zone_data.indicator and is_instance_valid(cond_zone_data.indicator):
			cond_zone_data.indicator.size.x = ind_width
			cond_zone_data.indicator.global_position = ind_pos
	
	# Alle Instruction-Zonen-Indikatoren positionieren
	for zone_data in instruction_zones:
		var offset_y = zone_data.get_offset_y()
		var ind_width = size.x - 20.0
		var ind_pos = Vector2(global_position.x + 10.0, global_position.y + offset_y)
		
		if zone_data.zone:
			zone_data.zone.indicator_width = ind_width
			zone_data.zone.indicator_offset = Vector2(10.0, offset_y)
		
		# Legacy ColorRect (für Positionsreferenz)
		if zone_data.indicator and is_instance_valid(zone_data.indicator):
			zone_data.indicator.size.x = ind_width
			zone_data.indicator.global_position = ind_pos

## Aktualisiert Children-Positionen DIREKT (synchron, kein Frame-Lag).
##
## Wird aufgerufen wenn DIESER Container gedraggt wird ODER wenn ein Parent-Container gedraggt wird.
func _update_children_positions_direct():
	# Alle Condition-Zonen-Children positionieren
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child) and cond_zone_data.indicator and is_instance_valid(cond_zone_data.indicator):
			cond_child.global_position = cond_zone_data.indicator.global_position
			
			if cond_child is ContainerBlock:
				cond_child._update_indicator_positions_internal()
				cond_child._update_children_positions_direct()
	
	# Alle Instruction-Zonen-Children positionieren
	for zone_data in instruction_zones:
		var zone_child = zone_data.get_first_child()
		
		if zone_child and is_instance_valid(zone_child) and zone_data.indicator and is_instance_valid(zone_data.indicator):
			var base_pos = zone_data.indicator.global_position
			var current = zone_child
			var offset_y = 0.0
			
			while current and is_instance_valid(current):
				current.global_position = Vector2(base_pos.x, base_pos.y + offset_y)
				
				if current is ContainerBlock:
					current._update_indicator_positions_internal()
					current._update_children_positions_direct()
				
				offset_y += current.get_total_height()
				current = current.block_below

## Stellt sicher, dass ein Kind-Block im Szenenbaum nach diesem Container kommt.
##
## Dadurch bekommt das Kind Input vor dem Container (Godot verarbeitet von hinten nach vorne).
## Bei tiefer Verschachtelung wird die gesamte Hierarchie rekursiv geordnet.
##
## @param child: Der Kind-Block
## @param visited: Dictionary zur Zyklus-Erkennung
func _ensure_child_above_in_tree(child: DraggableBlock, visited: Dictionary = {}):
	if not child or not is_instance_valid(child):
		return
	
	# Zyklus-Erkennung
	var my_id = get_instance_id()
	if visited.has(my_id):
		return
	visited[my_id] = true
	
	if child.get_parent() != get_parent():
		return
	
	var my_index = get_index()
	var child_index = child.get_index()
	
	if child_index <= my_index:
		get_parent().move_child(child, my_index + 1)
	
	# Eigene Position im Szenenbaum aktualisieren (rekursiv nach oben bis zur Wurzel)
	if instruction_parent and is_instance_valid(instruction_parent) and instruction_parent is ContainerBlock:
		instruction_parent._ensure_child_above_in_tree(self, visited)

## Ordnet alle Children dieses Containers im Szenenbaum neu.
##
## Wird deferred aufgerufen damit alle Drag-Operationen abgeschlossen sind.
func _reorder_all_children_in_tree():
	# Condition-Zonen-Children
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child):
			_ensure_child_above_in_tree(cond_child)
	
	# Instruction-Zonen-Children (alle in der Chain)
	for zone_data in instruction_zones:
		var current = zone_data.get_first_child()
		while current and is_instance_valid(current):
			_ensure_child_above_in_tree(current)
			current = current.block_below

## Überschreibt _physics_process um Children-Positionen zu aktualisieren wenn Container bewegt wird.
func _physics_process(_delta):
	if not is_dragging and is_inside_tree():
		for zone_data in instruction_zones:
			var zone_child = zone_data.get_first_child()
			if zone_child and is_instance_valid(zone_child) and zone_data.indicator and is_instance_valid(zone_data.indicator):
				var expected_pos = zone_data.indicator.global_position
				var actual_pos = zone_child.global_position
				if abs(expected_pos.x - actual_pos.x) > 1.0 or abs(expected_pos.y - actual_pos.y) > 1.0:
					_update_children_positions_direct()
					return  # Nur einmal pro Frame aktualisieren

## Aktualisiert die Position des Kindes einer Condition-Zone.
##
## @param zone_data: Die ConditionZoneData
func _update_condition_zone_position(zone_data):  # ConditionZoneDataClass
	if not is_inside_tree():
		return
	if not zone_data.indicator or not is_instance_valid(zone_data.indicator):
		return
	
	var cond_child = zone_data.get_child()
	if cond_child and is_instance_valid(cond_child):
		var cond_target_pos = zone_data.indicator.global_position
		cond_child.global_position = cond_target_pos
		
		# Szenenbaum anpassung (rekursiv)
		_ensure_child_above_in_tree(cond_child)
		
		if cond_child is ContainerBlock:
			cond_child._update_children_positions_direct()

## Virtuelle Methode: MUSS von Subklassen überschrieben werden!
##
## Jede Subklasse (LoopBlock, CaseDistinctionBlock) implementiert ihre eigene Größenlogik.
func _update_block_size():
	pass

## Generische Block-Größen-Anpassung für N Zonen.
##
## Kann von Subklassen aufgerufen werden (optional mit Zone-Filter).
##
## @param filter_func: Optional: func(zone_data: InstructionZoneData) -> bool
##                     Ermöglicht Subklassen zu entscheiden, welche Zonen berücksichtigt werden.
##                     Z.B. CaseDistinctionBlock kann False-Zone bei IF (ohne ELSE) ausschließen.
## @return: true wenn Größe geändert wurde, false sonst
func _update_block_size_generic(filter_func: Callable = Callable()):
	if not is_inside_tree():
		return false
	
	var visited: Dictionary = {}
	visited[self] = true
	
	var total_height_diff = 0.0
	
	for zone_data in instruction_zones:
		if filter_func.is_valid() and not filter_func.call(zone_data):
			continue
		
		if zone_data.inner_container and is_instance_valid(zone_data.inner_container):
			var _new_zone_height = zone_data.call("update_container_height", visited)
			var zone_height_diff = zone_data.get_height_diff()
			total_height_diff += zone_height_diff
	
	var new_block_height = _initial_block_height + total_height_diff
	
	if abs(custom_minimum_size.y - new_block_height) < 0.1:
		return false
	
	custom_minimum_size.y = new_block_height
	_current_valid_height = new_block_height
	size.y = new_block_height
	
	if main_container is VBoxContainer and is_instance_valid(main_container):
		main_container.queue_sort()
	
	_update_indicator_positions()
	
	_update_all_zone_labels()
	
	_update_chain_below()
	
	_notify_parent_containers()
	
	return true

## Benachrichtigt Parent-Container über Größenänderungen.
##
## Berücksichtigt zwei Fälle:
## 1. Dieser Container ist direkt in einem anderen Container (instruction_parent)
## 2. Dieser Container ist in einer normalen Chain und der Chain-Head hat einen instruction_parent
func _notify_parent_containers():
	# Fall 1: Dieser Container ist direkt in einem anderen Container (instruction_parent)
	if instruction_parent and is_instance_valid(instruction_parent):
		if instruction_parent.has_method("_update_block_size"):
			instruction_parent.call_deferred("_update_block_size")
	
	# Fall 2: Dieser Container ist in einer normalen Chain und der Chain-Head hat einen instruction_parent
	var chain_head = get_chain_head()
	if chain_head and is_instance_valid(chain_head) and chain_head != self:
		if chain_head.instruction_parent and is_instance_valid(chain_head.instruction_parent):
			if chain_head.instruction_parent.has_method("_update_block_size"):
				chain_head.instruction_parent.call_deferred("_update_block_size")

## Überschreibt get_total_height mit Zyklus-Erkennung.
##
## @param visited: Dictionary zur Zyklus-Erkennung
## @return: Die Gesamthöhe des Blocks
func get_total_height(visited: Dictionary = {}) -> float:
	if visited.has(self):
		push_warning("[ContainerBlock] Zyklus in get_total_height erkannt bei: %s" % block_name)
		return 0.0
	visited[self] = true
	
	if _current_valid_height > 0:
		return _current_valid_height
	elif custom_minimum_size.y > 0:
		return custom_minimum_size.y
	return size.y

## Überschreibt Drag-Start um Children-Z-Index und Zonen zu deaktivieren.
##
## @param local_click_pos: Lokale Click-Position
## @param is_group_drag: true bei Group-Drag
func _on_drag_start(local_click_pos: Vector2, is_group_drag: bool = false):
	super._on_drag_start(local_click_pos, is_group_drag)
	
	_set_children_z_index(DRAG_Z_INDEX + 10)
	
	_disable_inner_instruction_zones_recursive()
	
	_disable_inner_chain_zones_recursive()
	
	if is_group_drag or is_dragging:
		_update_children_positions_direct()

## Setzt den Z-Index aller Kind-Blöcke (rekursiv).
##
## @param base_z: Der Basis-Z-Index
func _set_children_z_index(base_z: int):
	# Alle Condition-Zonen-Children
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child):
			cond_child.z_index = base_z
			if cond_child is ContainerBlock:
				cond_child._set_children_z_index(base_z + 1)
	
	# Alle Instruction-Zonen-Children
	for zone_data in instruction_zones:
		var zone_child = zone_data.get_first_child()
		if zone_child and is_instance_valid(zone_child):
			var current = zone_child
			while current and is_instance_valid(current):
				current.z_index = base_z
				if current is ContainerBlock:
					current._set_children_z_index(base_z + 1)
				current = current.block_below

## Überschreibt Drag-End um Zonen zu reaktivieren und Z-Index zurückzusetzen.
func _on_drag_end():
	_enable_inner_instruction_zones_recursive()
	
	_enable_inner_chain_zones_recursive()
	
	super._on_drag_end()
	
	call_deferred("_reset_children_z_index")
	
	if is_inside_tree():
		await get_tree().process_frame
		_update_children_positions_direct()

## Setzt den Z-Index aller Kind-Blöcke auf Normal zurück.
func _reset_children_z_index():
	var container_z_index = self.z_index
	var child_z_index = container_z_index + 1
	
	# Alle Condition-Zonen-Children
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child):
			cond_child.z_index = child_z_index
			if cond_child is ContainerBlock:
				cond_child._reset_children_z_index()
	
	# Alle Instruction-Zonen-Children
	for zone_data in instruction_zones:
		var zone_child = zone_data.get_first_child()
		if zone_child and is_instance_valid(zone_child):
			var current = zone_child
			while current and is_instance_valid(current):
				current.z_index = child_z_index
				if current is ContainerBlock:
					current._reset_children_z_index()
				current = current.block_below

## Aktualisiert die Position aller Blöcke unter diesem Block in der Chain.
func _update_chain_below():
	if not block_below or not is_instance_valid(block_below):
		return
	
	var new_y = global_position.y + get_total_height()
	var current = block_below
	var current_y = new_y
	
	while current and is_instance_valid(current):
		current.global_position = Vector2(global_position.x, current_y)
		
		if current.has_method("_update_indicator_positions"):
			current._update_indicator_positions()
		
		if current is ContainerBlock:
			current._update_indicator_positions()
			current._update_children_positions_direct()
			current._update_chain_below()
		
		current_y += current.get_total_height()
		current = current.block_below

## Aktualisiert den z_index eines Kind-Blocks und seiner Chain.
##
## Kind-Blöcke müssen höher sein als der Container damit Klicks korrekt funktionieren.
##
## @param child: Der Kind-Block
func _update_child_z_index(child: DraggableBlock):
	if not child or not is_instance_valid(child):
		return
	
	var child_z = z_index + 1
	
	# Setze z_index für das Kind und seine gesamte Chain
	var current = child
	while current and is_instance_valid(current):
		current.z_index = child_z
		# Rekursiv für verschachtelte Container
		if current is ContainerBlock:
			current._reset_children_z_index()
		current = current.block_below

## Deaktiviert alle Instruction/Condition-Zones rekursiv (für Drag-Prevention).
func _disable_inner_instruction_zones_recursive():
	var visited = {}
	_disable_zones_internal(visited)

## Interne Methode: Deaktiviert Zonen mit Zyklus-Erkennung.
##
## @param visited: Dictionary zur Zyklus-Erkennung
func _disable_zones_internal(visited: Dictionary):
	var my_id = get_instance_id()
	if visited.has(my_id):
		return
	visited[my_id] = true
	
	for zone_data in instruction_zones:
		if zone_data.zone and is_instance_valid(zone_data.zone):
			zone_data.zone.set_enabled(false)
	
	for cond_zone_data in condition_zones:
		if cond_zone_data.zone and is_instance_valid(cond_zone_data.zone):
			cond_zone_data.zone.set_enabled(false)
	
	# Rekursiv: Alle Condition-Zonen-Children
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child) and cond_child is ContainerBlock:
			cond_child._disable_zones_internal(visited)
	
	# Rekursiv: Alle Instruction-Zonen-Children
	for zone_data in instruction_zones:
		var zone_child = zone_data.get_first_child()
		if zone_child and is_instance_valid(zone_child):
			var current = zone_child
			var safety_counter = 0
			while current and is_instance_valid(current) and safety_counter < 100:
				safety_counter += 1
				if current is ContainerBlock:
					current._disable_zones_internal(visited)
				current = current.block_below

## Aktiviert alle Instruction/Condition-Zones rekursiv (nach Drag).
func _enable_inner_instruction_zones_recursive():
	var visited = {}
	_enable_zones_internal(visited)

## Interne Methode: Aktiviert Zonen mit Zyklus-Erkennung.
##
## @param visited: Dictionary zur Zyklus-Erkennung
func _enable_zones_internal(visited: Dictionary):
	var my_id = get_instance_id()
	if visited.has(my_id):
		return
	visited[my_id] = true
	
	for zone_data in instruction_zones:
		if zone_data.zone and is_instance_valid(zone_data.zone):
			zone_data.zone.set_enabled(true)
	
	for cond_zone_data in condition_zones:
		if cond_zone_data.zone and is_instance_valid(cond_zone_data.zone):
			cond_zone_data.zone.set_enabled(true)
	
	# Rekursiv: Alle Condition-Zonen-Children
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child) and cond_child is ContainerBlock:
			cond_child._enable_zones_internal(visited)
	
	# Rekursiv: Alle Instruction-Zonen-Children
	for zone_data in instruction_zones:
		var zone_child = zone_data.get_first_child()
		if zone_child and is_instance_valid(zone_child):
			var current = zone_child
			var safety_counter = 0
			while current and is_instance_valid(current) and safety_counter < 100:
				safety_counter += 1
				if current is ContainerBlock:
					current._enable_zones_internal(visited)
				current = current.block_below

## Deaktiviert alle Top/Bottom Zonen der inneren Chains rekursiv.
func _disable_inner_chain_zones_recursive():
	var visited = {}
	_disable_chain_zones_internal(visited)

## Interne Methode: Deaktiviert Chain-Zonen mit Zyklus-Erkennung.
##
## @param visited: Dictionary zur Zyklus-Erkennung
func _disable_chain_zones_internal(visited: Dictionary):
	var my_id = get_instance_id()
	if visited.has(my_id):
		return
	visited[my_id] = true
	
	# Rekursiv: Instruction-Zonen-Children
	for zone_data in instruction_zones:
		var zone_child = zone_data.get_first_child()
		if zone_child and is_instance_valid(zone_child):
			var current = zone_child
			var safety_counter = 0
			while current and is_instance_valid(current) and safety_counter < 100:
				safety_counter += 1
				for zone in current.snap_zones:
					if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
						zone.set_enabled(false)
				
				if current is ContainerBlock:
					current._disable_chain_zones_internal(visited)
				
				current = current.block_below
	
	# Rekursiv: Condition-Zonen-Children
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child) and cond_child is ContainerBlock:
			cond_child._disable_chain_zones_internal(visited)

## Aktiviert alle Top/Bottom Zonen der inneren Chains rekursiv.
func _enable_inner_chain_zones_recursive():
	var visited = {}
	_enable_chain_zones_internal(visited)

## Interne Methode: Aktiviert Chain-Zonen mit Zyklus-Erkennung.
##
## @param visited: Dictionary zur Zyklus-Erkennung
func _enable_chain_zones_internal(visited: Dictionary):
	var my_id = get_instance_id()
	if visited.has(my_id):
		return
	visited[my_id] = true
	
	# Rekursiv: Instruction-Zonen-Children
	for zone_data in instruction_zones:
		var zone_child = zone_data.get_first_child()
		if zone_child and is_instance_valid(zone_child):
			var current = zone_child
			var safety_counter = 0
			while current and is_instance_valid(current) and safety_counter < 100:
				safety_counter += 1
				for zone in current.snap_zones:
					if zone.zone_type == SnapZone.ZoneType.TOP or zone.zone_type == SnapZone.ZoneType.BOTTOM:
						zone.set_enabled(true)
				
				if current is ContainerBlock:
					current._enable_chain_zones_internal(visited)
				
				current = current.block_below
	
	# Rekursiv: Condition-Zonen-Children
	for cond_zone_data in condition_zones:
		var cond_child = cond_zone_data.get_child()
		if cond_child and is_instance_valid(cond_child) and cond_child is ContainerBlock:
			cond_child._enable_chain_zones_internal(visited)

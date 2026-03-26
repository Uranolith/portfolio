## Zentrale Snap-Logik für Block-Verbindungen.
##
## SnapTarget repräsentiert ein Ziel, an das ein Block gesnappt werden kann.
## Verwaltet die gesamte Logik für verschiedene Snap-Modi (Above, Below, Condition, Instruction).
class_name SnapTarget
extends RefCounted

## Snap-Modi für verschiedene Verbindungsarten
enum SnapMode {
	ABOVE,       ## Snap über dem Ziel-Block (block_above)
	BELOW,       ## Snap unter dem Ziel-Block (block_below)
	CONDITION,   ## Snap in Condition-Slot eines Containers
	INSTRUCTION  ## Snap in Instruction-Slot eines Containers
}

## Der Ziel-Block, an den gesnappt wird
var target_block: DraggableBlock = null

## Der Snap-Modus
var snap_mode: SnapMode = SnapMode.BELOW

## Die Ziel-Zone (bei Container-Snaps)
var target_zone: SnapZone = null 

## Konstruktor.
##
## @param block: Der Ziel-Block
## @param mode: Der Snap-Modus
## @param zone: Optional: Die Ziel-Zone
func _init(block: DraggableBlock = null, mode: SnapMode = SnapMode.BELOW, zone: SnapZone = null):
	target_block = block
	snap_mode = mode
	target_zone = zone

## Prüft ob dieses SnapTarget gültig ist.
##
## @return: true wenn gültig, false sonst
func is_valid() -> bool:
	if self == target_block:
		push_error("[SnapTarget] ERROR: SnapTarget target_block instance mismatch")
		return false
		
	return target_block != null and is_instance_valid(target_block)

## Gibt den Snap-Modus als String zurück.
##
## @return: Der Modus-String (z.B. "snap_above")
func get_mode_string() -> String:
	match snap_mode:
		SnapMode.ABOVE: return "snap_above"
		SnapMode.BELOW: return "snap_below"
		SnapMode.CONDITION: return "snap_condition"
		SnapMode.INSTRUCTION: return "snap_instruction"
		_: return "snap_below"

# HAUPTEINSTIEGSPUNKT

## Wendet den Snap auf einen gedraggerten Block an.
##
## Dies ist der Haupteinstiegspunkt für alle Snap-Operationen.
##
## @param dragged_block: Der Block, der gesnappt werden soll
## @param is_group: true wenn die gesamte Chain gesnappt wird (Group-Drag)
func apply_snap(dragged_block: DraggableBlock, is_group: bool = false) -> void:
	if not is_valid():
		return
	
	match snap_mode:
		SnapMode.INSTRUCTION:
			_handle_instruction_snap(dragged_block, is_group)
		SnapMode.ABOVE:
			_handle_above_snap(dragged_block, is_group)
		SnapMode.BELOW:
			_handle_below_snap(dragged_block, is_group)
		SnapMode.CONDITION:
			_handle_condition_snap(dragged_block)

## Behandelt INSTRUCTION-Snap (Einfügen in Container-Zone).
##
## @param block: Der einzufügende Block
## @param is_group: true bei Group-Drag
func _handle_instruction_snap(block: DraggableBlock, is_group: bool) -> void:
	var zone := _find_snap_zone()
	if not zone:
		return
	
	_prepare_block_for_snap(block)
	_set_instruction_parent(block, target_block, is_group)
	
	var old_first := _get_zone_child_from_owner(zone)
	
	if old_first == null or not is_instance_valid(old_first):
		# FALL A: Keine Chain vorhanden - erste Einfügung
		_handle_instruction_snap_first(block, is_group, zone)
	else:
		# FALL B: Chain vorhanden - einfügen oben
		_handle_instruction_snap_insert_top(block, is_group, zone, old_first)
	
	_set_z_index_for_instruction_snap(block, target_block, is_group)
	_notify_container_size_change(target_block)

## Fall A: Erste Einfügung in leere Instruction-Zone.
##
## @param block: Der einzufügende Block
## @param is_group: true bei Group-Drag
## @param zone: Die Ziel-Zone
func _handle_instruction_snap_first(block: DraggableBlock, is_group: bool, zone: SnapZone) -> void:
	_set_zone_child_on_owner(zone, block)
	_position_at_indicator(block, zone.indicator)
	
	if is_group:
		_position_group_chain(block)

## Fall B: Einfügung oben in vorhandene Chain.
##
## @param block: Der einzufügende Block
## @param is_group: true bei Group-Drag
## @param zone: Die Ziel-Zone
## @param old_first: Der bisherige erste Block in der Zone
func _handle_instruction_snap_insert_top(block: DraggableBlock, is_group: bool, zone: SnapZone, old_first: DraggableBlock) -> void:
	var inserted_height := _calculate_chain_height(block, is_group)
	
	_shift_chain_visual(old_first, inserted_height)
	
	var last_of_new := _find_chain_end(block, is_group)
	_link_chains(last_of_new, old_first)
	
	_set_zone_child_on_owner(zone, block)
	_position_entire_chain(block, zone.indicator)

## Behandelt ABOVE-Snap (Einfügen über einem Block).
##
## @param block: Der einzufügende Block
## @param is_group: true bei Group-Drag
func _handle_above_snap(block: DraggableBlock, is_group: bool) -> void:
	if _is_cyclic_insertion(block):
		return
	
	_prepare_block_for_snap(block)
	
	var head_before = target_block.get_chain_head()
	var head_anchor = head_before.global_position if head_before else null
	
	var target_old_top := target_block.block_above
	block.block_above = target_old_top
	if target_old_top:
		target_old_top.block_below = block
	
	var is_head_insert := _handle_instruction_parent_above(block, is_group)
	
	var last_of_new := _find_chain_end(block, is_group)
	last_of_new.block_below = target_block
	target_block.block_above = last_of_new
	
	if not is_head_insert:
		_notify_instruction_parent_if_middle_insert()
	
	if head_before and head_anchor:
		head_before.reflow_chain_with_anchor(head_anchor)
	
	_set_z_index_for_chain_snap(block, target_block, is_group)

## Behandelt BELOW-Snap (Einfügen unter einem Block).
##
## @param block: Der einzufügende Block
## @param is_group: true bei Group-Drag
func _handle_below_snap(block: DraggableBlock, is_group: bool) -> void:
	if _is_cyclic_insertion(block):
		return
	
	_prepare_block_for_snap(block)
	
	var head_before = target_block.get_chain_head()
	var head_anchor = head_before.global_position if head_before else null
	
	var target_old_bottom := target_block.block_below
	target_block.block_below = block
	block.block_above = target_block
	
	_handle_instruction_parent_below(block, is_group)
	
	var last_of_new := _find_chain_end(block, is_group)
	last_of_new.block_below = target_old_bottom
	if target_old_bottom:
		target_old_bottom.block_above = last_of_new
	
	if head_before and head_anchor:
		head_before.reflow_chain_with_anchor(head_anchor)
	
	_set_z_index_for_chain_snap(block, target_block, is_group)

## Behandelt CONDITION-Snap (Einfügen in Condition-Slot).
##
## @param block: Der einzufügende Block
func _handle_condition_snap(block: DraggableBlock) -> void:
	var zone = _find_snap_zone()
	if not zone:
		return
	
	var zone_name := ""
	if zone.snap_mode_string.begins_with("snap_"):
		zone_name = zone.snap_mode_string.substr(5)
	else:
		zone_name = zone.snap_mode_string
	
	if not target_block.has_method("set_condition_zone_child"):
		return
	
	var snap_indicator = zone.indicator
	if not snap_indicator or not is_instance_valid(snap_indicator):
		return
	
	block.global_position = snap_indicator.global_position
	block.block_above = null
	block.block_below = null
	
	if "condition_parent" in block:
		block.condition_parent = target_block
	
	target_block.set_condition_zone_child(zone_name, block)

## Findet die SnapZone basierend auf dem Snap-Modus.
##
## @return: Die gefundene SnapZone oder null
func _find_snap_zone() -> SnapZone:
	if target_zone and is_instance_valid(target_zone) and is_instance_valid(target_zone.indicator):
		return target_zone
	
	var mode_string := get_mode_string()
	
	if target_block.has_method("find_zone_by_mode"):
		var zone = target_block.find_zone_by_mode(mode_string)
		if zone and is_instance_valid(zone.indicator):
			return zone
	
	if target_block.has_method("get_snap_zones"):
		var zones = target_block.get_snap_zones()
		var target_zone_type := _mode_to_zone_type(snap_mode)
		
		for zone in zones:
			if zone.zone_type == target_zone_type and is_instance_valid(zone.indicator):
				return zone
	
	return null

## Konvertiert SnapMode zu SnapZone.ZoneType.
##
## @param mode: Der SnapMode
## @return: Der entsprechende ZoneType
func _mode_to_zone_type(mode: SnapMode) -> SnapZone.ZoneType:
	match mode:
		SnapMode.ABOVE:
			return SnapZone.ZoneType.TOP
		SnapMode.BELOW:
			return SnapZone.ZoneType.BOTTOM
		SnapMode.CONDITION:
			return SnapZone.ZoneType.CONDITION
		SnapMode.INSTRUCTION:
			return SnapZone.ZoneType.INSTRUCTION
		_:
			return SnapZone.ZoneType.BOTTOM

## Bereitet einen Block für das Snapping vor.
##
## @param block: Der vorzubereitende Block
func _prepare_block_for_snap(block: DraggableBlock) -> void:
	if block.has_method("detach_chain_links"):
		block.detach_chain_links()

## Prüft ob das Einfügen einen Zyklus erzeugen würde.
##
## @param block: Der einzufügende Block
## @return: true wenn Zyklus entstehen würde
func _is_cyclic_insertion(block: DraggableBlock) -> bool:
	return block._is_in_chain(target_block) or target_block._is_in_chain(block)

## Setzt den instruction_parent für einen Block und optional seine Chain.
##
## @param block: Der Block
## @param parent: Der neue instruction_parent
## @param is_group: true um die gesamte Chain zu setzen
func _set_instruction_parent(block: DraggableBlock, parent: DraggableBlock, is_group: bool) -> void:
	var current := block
	while current and is_instance_valid(current):
		current.instruction_parent = parent
		if not is_group:
			break
		current = current.block_below

## Behandelt instruction_parent beim Above-Snap.
##
## @param block: Der einzufügende Block
## @param is_group: true bei Group-Drag
## @return: true wenn es eine Head-Einfügung war
func _handle_instruction_parent_above(block: DraggableBlock, is_group: bool) -> bool:
	if not target_block.instruction_parent or not is_instance_valid(target_block.instruction_parent):
		return false
	
	var instr_parent = target_block.instruction_parent
	_set_instruction_parent(block, instr_parent, is_group)
	
	if instr_parent is ContainerBlock and "instruction_zones" in instr_parent:
		for zone_data in instr_parent.instruction_zones:
			if zone_data.get_first_child() == target_block:
				instr_parent.set_instruction_zone_child(zone_data.zone_name, block)
				return true
	
	return false

## Behandelt instruction_parent beim Below-Snap.
##
## @param block: Der einzufügende Block
## @param is_group: true bei Group-Drag
func _handle_instruction_parent_below(block: DraggableBlock, is_group: bool) -> void:
	if not target_block.instruction_parent or not is_instance_valid(target_block.instruction_parent):
		return
	
	var instr_parent = target_block.instruction_parent
	_set_instruction_parent(block, instr_parent, is_group)
	
	if instr_parent is ContainerBlock and instr_parent.has_method("_ensure_child_above_in_tree"):
		var current = block
		while current and is_instance_valid(current):
			instr_parent._ensure_child_above_in_tree(current)
			if not is_group:
				break
			current = current.block_below
	
	if instr_parent.has_method("_update_block_size"):
		instr_parent.call_deferred("_update_block_size")

## Benachrichtigt instruction_parent bei Middle-Insert.
func _notify_instruction_parent_if_middle_insert() -> void:
	if not target_block.instruction_parent or not is_instance_valid(target_block.instruction_parent):
		return
	
	var instr_parent = target_block.instruction_parent
	
	if instr_parent is ContainerBlock and instr_parent.has_method("_reorder_all_children_in_tree"):
		instr_parent._reorder_all_children_in_tree()
	
	if instr_parent.has_method("_update_block_size"):
		instr_parent.call_deferred("_update_block_size")

## Berechnet die Gesamthöhe einer Block-Chain.
##
## @param block: Der Start-Block
## @param is_group: true um die gesamte Chain zu berechnen
## @return: Die Gesamthöhe
func _calculate_chain_height(block: DraggableBlock, is_group: bool) -> float:
	var height := 0.0
	var current := block
	
	while current and is_instance_valid(current):
		height += current.get_total_height()
		if not is_group or not current.block_below:
			break
		current = current.block_below
	
	return height

## Findet das Ende einer Block-Chain.
##
## @param block: Der Start-Block
## @param is_group: true um die gesamte Chain zu durchlaufen
## @return: Der letzte Block in der Chain
func _find_chain_end(block: DraggableBlock, is_group: bool) -> DraggableBlock:
	if not is_group:
		return block
	
	var last := block
	while last.block_below and is_instance_valid(last.block_below):
		last = last.block_below
	
	return last

## Verlinkt zwei Chains miteinander.
##
## @param top: Der obere Block
## @param bottom: Der untere Block
func _link_chains(top: DraggableBlock, bottom: DraggableBlock) -> void:
	top.block_below = bottom
	bottom.block_above = top

## Positioniert einen Block am Indikator.
##
## @param block: Der zu positionierende Block
## @param indicator: Der ColorRect-Indikator
func _position_at_indicator(block: DraggableBlock, indicator: ColorRect) -> void:
	block.global_position = indicator.global_position
	
	if block.has_method("_update_indicator_positions"):
		block._update_indicator_positions()
	
	if block is ContainerBlock and block.has_method("_update_children_positions_direct"):
		block._update_children_positions_direct()

## Positioniert eine Group-Chain relativ zum ersten Block.
##
## @param block: Der Start-Block der Chain
func _position_group_chain(block: DraggableBlock) -> void:
	var current := block.block_below
	var offset_y := block.get_total_height()
	
	while current and is_instance_valid(current):
		current.global_position = Vector2(block.global_position.x, block.global_position.y + offset_y)
		offset_y += current.get_total_height()
		current = current.block_below

## Positioniert eine gesamte Chain am Indikator.
##
## @param block: Der Start-Block der Chain
## @param indicator: Der ColorRect-Indikator
func _position_entire_chain(block: DraggableBlock, indicator: ColorRect) -> void:
	var current := block
	var offset_y := 0.0
	
	while current and is_instance_valid(current):
		var new_pos := Vector2(indicator.global_position.x, indicator.global_position.y + offset_y)
		current.global_position = new_pos
		
		if current.has_method("_update_indicator_positions"):
			current._update_indicator_positions()
		
		offset_y += current.get_total_height()
		current = current.block_below

## Verschiebt eine Chain visuell um einen bestimmten Betrag.
##
## @param start: Der Start-Block der Chain
## @param shift_amount: Der Verschiebungsbetrag in Pixeln
func _shift_chain_visual(start: DraggableBlock, shift_amount: float) -> void:
	var current := start
	
	while current and is_instance_valid(current):
		current.global_position.y += shift_amount
		
		if current.has_method("_update_indicator_positions"):
			current._update_indicator_positions()
		
		current = current.block_below

## Benachrichtigt einen Container über eine Größenänderung.
##
## @param container: Der Container-Block
func _notify_container_size_change(container: DraggableBlock) -> void:
	if container.has_method("_update_block_size"):
		container._update_block_size()

## Setzt Z-Index für INSTRUCTION Snap: Container Z-Index + 1.
##
## @param block: Der einzufügende Block
## @param container: Der Container-Block
## @param is_group: true bei Group-Drag
func _set_z_index_for_instruction_snap(block: DraggableBlock, container: DraggableBlock, is_group: bool) -> void:
	var container_z_index = container.z_index if container and is_instance_valid(container) else 0
	var child_z_index = container_z_index + 1
	
	var current = block
	while current and is_instance_valid(current):
		current.z_index = child_z_index
		
		if current is ContainerBlock and current.has_method("_reset_children_z_index"):
			current._reset_children_z_index()
		
		if not is_group:
			break
		current = current.block_below

## Setzt Z-Index für Chain Snap (ABOVE/BELOW): Siblings bekommen gleichen Z-Index.
##
## @param block: Der einzufügende Block
## @param target: Der Ziel-Block
## @param is_group: true bei Group-Drag
func _set_z_index_for_chain_snap(block: DraggableBlock, target: DraggableBlock, is_group: bool) -> void:
	var target_z_index = target.z_index if target and is_instance_valid(target) else 0
	
	var current = block
	while current and is_instance_valid(current):
		current.z_index = target_z_index
		
		if current is ContainerBlock and current.has_method("_reset_children_z_index"):
			current._reset_children_z_index()
		
		if not is_group:
			break
		current = current.block_below

## Holt das Child einer Zone über den Owner-Block (ContainerBlock).
##
## @param zone: Die SnapZone
## @return: Das erste Kind in der Zone oder null
func _get_zone_child_from_owner(zone: SnapZone) -> DraggableBlock:
	if not zone or not zone.owner_block:
		return null
	
	var owner = zone.owner_block
	
	if owner is ContainerBlock and "instruction_zones" in owner:
		for zone_data in owner.instruction_zones:
			if zone_data.zone == zone or zone_data.indicator == zone.indicator:
				return zone_data.get_first_child()
	
	if zone.snap_mode_string and owner.has_method("get_instruction_zone_child"):
		var zone_name = zone.snap_mode_string
		if zone_name.begins_with("snap_"):
			zone_name = zone_name.substr(5)
		return owner.get_instruction_zone_child(zone_name)
	
	return null

## Setzt das Child einer Zone über den Owner-Block (ContainerBlock).
##
## @param zone: Die SnapZone
## @param child: Der neue Child-Block
func _set_zone_child_on_owner(zone: SnapZone, child: DraggableBlock) -> void:
	if not zone or not zone.owner_block:
		return
	
	var owner = zone.owner_block
	
	if owner is ContainerBlock and "instruction_zones" in owner:
		for zone_data in owner.instruction_zones:
			if zone_data.zone == zone or zone_data.indicator == zone.indicator:
				owner.set_instruction_zone_child(zone_data.zone_name, child)
				return
	
	if zone.snap_mode_string and owner.has_method("set_instruction_zone_child"):
		var zone_name = zone.snap_mode_string
		if zone_name.begins_with("snap_"):
			zone_name = zone_name.substr(5)
		owner.set_instruction_zone_child(zone_name, child)

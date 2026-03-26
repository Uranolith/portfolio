## Verwaltet das Kontextmenü zum Spawnen von Blöcken.
##
## Nutzt die Input Action "block_create_menu" (Strg+A oder Strg+Rechtsklick).
## Koordiniert Block-Selektion, Löschen und Menu-Anzeige.
class_name ContextMenuControler
extends Node

## Referenz zum BlockSpawnMenu
@export var spawn_menu: BlockSpawnMenu

## Referenz zur Canvas-Kamera (für World-Position-Berechnung)
var camera: Camera2D = null

## Initialisiert den Controller und findet die Kamera.
func _ready():
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() > 0:
		camera = cameras[0]
	else:
		push_warning("[ContextMenuController] Keine Kamera gefunden!")

## Verarbeitet Eingaben für Block-Löschen, Menu-Öffnen und Block-Deselektierung.
##
## @param event: Das Input-Event
func _input(event: InputEvent):
	if event.is_action_pressed("block_delete"):
		if DraggableBlock.selected_block and is_instance_valid(DraggableBlock.selected_block):
			if spawn_menu and spawn_menu.has_method("delete_selected_block"):
				spawn_menu.delete_selected_block()
				get_viewport().set_input_as_handled()
				return
	
	if event.is_action_pressed("block_create_menu"):
		_show_menu_at_mouse()
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if DraggableBlock.selected_block and is_instance_valid(DraggableBlock.selected_block):
				var hit_block = _check_if_block_clicked()
				if not hit_block:
					DraggableBlock.selected_block._deselect_block()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if not event.is_action("block_create_menu"):
				if DraggableBlock.selected_block and is_instance_valid(DraggableBlock.selected_block):
					var hit_block = _check_if_block_clicked()
					if not hit_block:
						DraggableBlock.selected_block._deselect_block()

## Prüft ob ein Block an der Mausposition geklickt wurde.
##
## @return: true wenn ein Block geklickt wurde
func _check_if_block_clicked() -> bool:
	var world_pos = _get_world_mouse_position()
	
	var all_blocks = get_tree().get_nodes_in_group("move_blocks")
	for block in all_blocks:
		if block is DraggableBlock and is_instance_valid(block):
			var block_rect = Rect2(block.global_position, block.size)
			if block_rect.has_point(world_pos):
				return true
	
	return false

## Zeigt das Spawn-Menü an der Mausposition an.
func _show_menu_at_mouse():
	if not spawn_menu:
		push_error("[ContextMenuController] Spawn-Menu nicht zugewiesen!")
		return
	
	var screen_pos = get_viewport().get_mouse_position()
	var world_pos = _get_world_mouse_position()
	
	spawn_menu.show_at_position(world_pos, screen_pos)

## Gibt die Mausposition in World-Space zurück.
##
## Nutzt die eingebaute Camera2D.get_global_mouse_position() Methode,
## die automatisch Zoom und Kamera-Position berücksichtigt.
##
## @return: Die Mausposition in World-Koordinaten
func _get_world_mouse_position() -> Vector2:
	if camera:
		return camera.get_global_mouse_position()
	else:
		return get_viewport().get_mouse_position()

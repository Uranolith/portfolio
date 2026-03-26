## State Machine für Drag-and-Drop-Operationen.
##
## Verwaltet den aktuellen Zustand eines Drag-Vorgangs und
## verhindert inkonsistente Zustände.
class_name DragState
extends RefCounted

## Enum für die verschiedenen Drag-Zustände
enum State {
	IDLE,              ## Kein Drag aktiv
	DRAGGING_SINGLE,   ## Einzelner Block wird gezogen
	DRAGGING_GROUP     ## Gruppe (Kette) wird gezogen
}

## Aktueller Drag-Zustand
var current_state: State = State.IDLE

## Maus-Offset relativ zum Block-Ursprung
var mouse_offset: Vector2 = Vector2.ZERO

## Startet einen Single-Block-Drag.
##
## @param offset: Der Maus-Offset
func start_single_drag(offset: Vector2) -> void:
	current_state = State.DRAGGING_SINGLE
	mouse_offset = offset

## Startet einen Gruppen-Drag (Kette).
##
## @param offset: Der Maus-Offset
func start_group_drag(offset: Vector2) -> void:
	current_state = State.DRAGGING_GROUP
	mouse_offset = offset

## Stoppt den aktuellen Drag.
func stop_drag() -> void:
	current_state = State.IDLE
	mouse_offset = Vector2.ZERO

## Prüft ob überhaupt ein Drag aktiv ist.
##
## @return: true wenn Drag aktiv, false sonst
func is_dragging() -> bool:
	return current_state != State.IDLE

## Prüft ob ein Gruppen-Drag aktiv ist.
##
## @return: true wenn Gruppen-Drag aktiv, false sonst
func is_group_drag() -> bool:
	return current_state == State.DRAGGING_GROUP

## Prüft ob ein Single-Drag aktiv ist.
##
## @return: true wenn Single-Drag aktiv, false sonst
func is_single_drag() -> bool:
	return current_state == State.DRAGGING_SINGLE

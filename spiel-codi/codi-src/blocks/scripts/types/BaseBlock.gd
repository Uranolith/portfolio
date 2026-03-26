## Base-Block für einfache Aktionen.
##
## Repräsentiert grundlegende Aktionen wie MOVE_FORWARD, TURN_LEFT, etc.
## Jeder BaseBlock hat einen spezifischen ActionType der seine Funktion bestimmt.
class_name BaseBlock
extends DraggableBlock

## Action-Type dieses Blocks (z.B. MOVE_FORWARD, TURN_LEFT)
var action_type: BlockData.ActionType = BlockData.ActionType.NONE

func _ready():
	super._ready()
	# Synchronisiere action_type aus BlockData
	if data and data.action_type != BlockData.ActionType.NONE:
		action_type = data.action_type
	_update_block_name_for_action()

## Synchronisiert Daten von BlockData zur visuellen Darstellung.
func _sync_from_data():
	super._sync_from_data()
	if data:
		action_type = data.action_type
		_update_block_name_for_action()

## Setzt den Action-Type und aktualisiert den Block-Namen.
##
## @param new_action_type: Der neue ActionType
func set_action_type(new_action_type: BlockData.ActionType):
	action_type = new_action_type
	if data:
		data.action_type = new_action_type
	_update_block_name_for_action()

## Gibt den aktuellen Action-Type zurück.
##
## @return: Der ActionType dieses Blocks
func get_action_type() -> BlockData.ActionType:
	return action_type

## Aktualisiert den Block-Namen basierend auf dem Action-Type.
func _update_block_name_for_action():
	var action_name = _get_action_name(action_type)
	if action_name != "":
		set_block_name(action_name)

## Gibt den lesbaren Namen für einen Action-Type zurück.
##
## @param action: Der ActionType
## @return: Der lesbare Name der Aktion
func _get_action_name(action: BlockData.ActionType) -> String:
	match action:
		BlockData.ActionType.MOVE_FORWARD:
			return "Move Forward"
		BlockData.ActionType.MOVE_BACKWARD:
			return "Move Backward"
		BlockData.ActionType.TURN_LEFT:
			return "Turn Left"
		BlockData.ActionType.TURN_RIGHT:
			return "Turn Right"
		BlockData.ActionType.JUMP:
			return "Jump"
		BlockData.ActionType.INTERACT:
			return "Interact"
		BlockData.ActionType.WAIT:
			return "Wait"
		_:
			return "Base Block"

## Basis-Ressource für alle Block-Daten.
##
## Speichert die interpretierbaren Daten eines Blocks unabhängig von der visuellen Darstellung.
## Diese Klasse trennt Daten (BlockData) von Darstellung (DraggableBlock).
## Wird verwendet für Serialisierung, Level-Loading und Interpreter.
extends Resource
class_name BlockData

## Block-Typen
enum BlockType {
	BASE,             ## Einfache Aktions-Blöcke
	CONDITION,        ## Bedingungsblöcke
	CASE_DISTINCTION, ## If/Else-Blöcke
	LOOP,             ## Schleifen-Blöcke
	PROGRAM           ## Programm-Hauptblock
}

## Aktions-Typen für BaseBlocks
enum ActionType {
	NONE,            ## Keine Aktion
	MOVE_FORWARD,    ## Vorwärts bewegen
	MOVE_BACKWARD,   ## Rückwärts bewegen
	TURN_LEFT,       ## Nach links drehen
	TURN_RIGHT,      ## Nach rechts drehen
	JUMP,            ## Springen
	INTERACT,        ## Interagieren
	WAIT             ## Warten
}

## Der Typ dieses Blocks
@export var block_type: BlockType = BlockType.BASE

## Eindeutige ID des Blocks
@export var block_id: String = ""

## Position des Blocks in der Welt
@export var position: Vector2 = Vector2.ZERO

## Aktions-Typ (nur für BaseBlocks relevant)
@export var action_type: ActionType = ActionType.NONE

## Gibt eine lesbare String-Repräsentation zurück.
##
## @return: String-Repräsentation der BlockData
func _to_string() -> String:
	var str_result = "[BlockData id=%s, type=%s]" % [block_id, BlockType.keys()[block_type]]
	if action_type != ActionType.NONE:
		str_result += " action=%s" % ActionType.keys()[action_type]
	return str_result

## Klont diese Ressource.
##
## @return: Eine Kopie dieser BlockData
func duplicate_data() -> BlockData:
	var data = BlockData.new()
	data.block_type = block_type
	data.block_id = block_id
	data.position = position
	data.action_type = action_type
	return data

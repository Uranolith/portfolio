## Ressource für Loop-Block-Daten.
##
## Speichert den Loop-Typ, die Bedingung und den Body (Array von Blöcken).
## Erweitert BlockData um Loop-spezifische Eigenschaften.
extends BlockData
class_name LoopBlockData

## Loop-Typen
enum LoopType {
	WHILE,     ## While-Schleife (Bedingung vor dem Body)
	DO_WHILE,  ## Do-While-Schleife (Bedingung nach dem Body)
	FOR        ## For-Schleife (feste Anzahl Wiederholungen)
}

## Der Typ dieser Schleife
@export var loop_type: LoopType = LoopType.WHILE

## Die Bedingung der Schleife (ConditionBlockData)
@export var case_condition: ConditionBlockData = null

## Der Body der Schleife (Array von BlockData)
@export var body: Array[BlockData] = []

## For-Loop Initialisierung (z.B. "i = 0")
@export var for_init: String = ""

## For-Loop Inkrement (z.B. "i++")
@export var for_increment: String = ""

func _init():
	block_type = BlockType.LOOP

## Gibt eine lesbare String-Repräsentation zurück.
##
## @return: String-Repräsentation der LoopBlockData
func _to_string() -> String:
	var type_str = LoopType.keys()[loop_type]
	var cond_str = case_condition._to_string() if case_condition else "???"
	return "%s (%s) { %d blocks }" % [type_str, cond_str, body.size()]

## Klont diese Ressource.
##
## @return: Eine Kopie dieser LoopBlockData
func duplicate_data() -> LoopBlockData:
	var data = LoopBlockData.new()
	data.block_type = block_type
	data.block_id = block_id
	data.position = position
	data.loop_type = loop_type
	data.for_init = for_init
	data.for_increment = for_increment
	
	if case_condition:
		data.case_condition = case_condition.duplicate_data()
	
	for block in body:
		if block.has_method("duplicate_data"):
			data.body.append(block.duplicate_data())
	
	return data

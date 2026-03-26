## Ressource für Case-Distinction-Block-Daten.
##
## Speichert die Bedingung und True/False-Zweige für If/If-Else-Blöcke.
## Erweitert BlockData um Case-Distinction-spezifische Eigenschaften.
extends BlockData
class_name CaseDistinctionBlockData

## Case-Typen
enum CaseType {
	IF,       ## Einfache If-Verzweigung (nur True-Branch)
	IF_ELSE   ## If-Else-Verzweigung (True- und False-Branch)
}

## Der Typ dieser Case-Distinction
@export var case_type: CaseType = CaseType.IF_ELSE

## Die Bedingung für die Verzweigung (ConditionBlockData)
@export var case_condition: ConditionBlockData = null

## Der True-Branch (Array von BlockData)
@export var true_branch: Array[BlockData] = []

## Der False-Branch (Array von BlockData, nur bei IF_ELSE)
@export var false_branch: Array[BlockData] = []

func _init():
	block_type = BlockType.CASE_DISTINCTION

## Gibt eine lesbare String-Repräsentation zurück.
##
## @return: String-Repräsentation der CaseDistinctionBlockData
func _to_string() -> String:
	var type_str = "IF_ELSE" if case_type == CaseType.IF_ELSE else "IF"
	var cond_str = case_condition._to_string() if case_condition else "???"
	return "%s (%s) { true: %d blocks, false: %d blocks }" % [
		type_str, 
		cond_str, 
		true_branch.size(), 
		false_branch.size()
	]

## Klont diese Ressource.
##
## @return: Eine Kopie dieser CaseDistinctionBlockData
func duplicate_data() -> CaseDistinctionBlockData:
	var data = CaseDistinctionBlockData.new()
	data.block_type = block_type
	data.block_id = block_id
	data.position = position
	data.case_type = case_type
	
	if case_condition:
		data.case_condition = case_condition.duplicate_data()
	
	for block in true_branch:
		if block.has_method("duplicate_data"):
			data.true_branch.append(block.duplicate_data())
	
	for block in false_branch:
		if block.has_method("duplicate_data"):
			data.false_branch.append(block.duplicate_data())
	
	return data

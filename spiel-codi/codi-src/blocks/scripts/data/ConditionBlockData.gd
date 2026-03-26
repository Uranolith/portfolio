## Ressource für Condition-Block-Daten.
##
## Speichert den Condition-Typ und optionale Werte (z.B. für REPEAT_COUNT).
## Erweitert BlockData um Condition-spezifische Eigenschaften.
extends BlockData
class_name ConditionBlockData

## Typen von Bedingungen
enum ConditionType {
	# Boolean Conditions (für If/While)
	CAN_MOVE_FORWARD,      ## Kann vorwärts bewegen
	CAN_MOVE_BACKWARD,     ## Kann rückwärts bewegen
	HAS_OBJECT_AHEAD,      ## Objekt vor dem Character
	IS_AT_GOAL,            ## Character am Ziel
	IS_AT_EDGE,            ## Character am Rand
	CAN_INTERACT,          ## Kann interagieren
	PATH_IS_CLEAR,         ## Weg ist frei
	
	# Loop-spezifische Conditions (für For-Schleifen)
	REPEAT_COUNT,          ## Wiederhole X-mal (benötigt Zahlen-Wert)
	REPEAT_UNTIL_EDGE,     ## Wiederhole bis Rand
	REPEAT_UNTIL_GOAL,     ## Wiederhole bis Ziel
	REPEAT_UNTIL_OBJECT,   ## Wiederhole bis Objekt
	REPEAT_UNTIL_BLOCKED,  ## Wiederhole bis blockiert
	
	# Counter-Conditions (für While/Do-While)
	COUNTER_EQUALS,        ## Counter == Wert (benötigt Zahlen-Wert)
	COUNTER_NOT_EQUALS,    ## Counter != Wert (benötigt Zahlen-Wert)
	COUNTER_GREATER_THAN,  ## Counter > Wert (benötigt Zahlen-Wert)
	COUNTER_LESS_THAN,     ## Counter < Wert (benötigt Zahlen-Wert)
	COUNTER_GREATER_EQUAL, ## Counter >= Wert (benötigt Zahlen-Wert)
	COUNTER_LESS_EQUAL,    ## Counter <= Wert (benötigt Zahlen-Wert)
	
	# Richtungs-Checks
	IS_FACING_NORTH,       ## Schaut nach Norden
	IS_FACING_EAST,        ## Schaut nach Osten
	IS_FACING_SOUTH,       ## Schaut nach Süden
	IS_FACING_WEST         ## Schaut nach Westen
}

## Der Typ dieser Condition
@export var condition_type: ConditionType = ConditionType.CAN_MOVE_FORWARD

## Optionaler Wert (für REPEAT_COUNT, COUNTER_* etc.)
@export var value: int = 0

func _init():
	block_type = BlockType.CONDITION

## Konvertiert einen String-ConditionType zu Enum.
##
## @param condition_string: Der Condition-String
## @return: Der entsprechende ConditionType
static func string_to_condition(condition_string: String) -> ConditionType:
	match condition_string:
		"can_move_forward": return ConditionType.CAN_MOVE_FORWARD
		"can_move_backward": return ConditionType.CAN_MOVE_BACKWARD
		"has_object_ahead": return ConditionType.HAS_OBJECT_AHEAD
		"is_at_goal": return ConditionType.IS_AT_GOAL
		"is_at_edge": return ConditionType.IS_AT_EDGE
		"can_interact": return ConditionType.CAN_INTERACT
		"path_is_clear": return ConditionType.PATH_IS_CLEAR
		"repeat_count": return ConditionType.REPEAT_COUNT
		"repeat_until_edge": return ConditionType.REPEAT_UNTIL_EDGE
		"repeat_until_goal": return ConditionType.REPEAT_UNTIL_GOAL
		"repeat_until_object": return ConditionType.REPEAT_UNTIL_OBJECT
		"repeat_until_blocked": return ConditionType.REPEAT_UNTIL_BLOCKED
		"counter_equals": return ConditionType.COUNTER_EQUALS
		"counter_not_equals": return ConditionType.COUNTER_NOT_EQUALS
		"counter_greater_than": return ConditionType.COUNTER_GREATER_THAN
		"counter_less_than": return ConditionType.COUNTER_LESS_THAN
		"counter_greater_equal": return ConditionType.COUNTER_GREATER_EQUAL
		"counter_less_equal": return ConditionType.COUNTER_LESS_EQUAL
		"is_facing_north": return ConditionType.IS_FACING_NORTH
		"is_facing_east": return ConditionType.IS_FACING_EAST
		"is_facing_south": return ConditionType.IS_FACING_SOUTH
		"is_facing_west": return ConditionType.IS_FACING_WEST
		_: return ConditionType.CAN_MOVE_FORWARD

## Konvertiert einen Enum-ConditionType zu String.
##
## @param condition: Der ConditionType
## @return: Der entsprechende String
static func condition_to_string(condition: ConditionType) -> String:
	match condition:
		ConditionType.CAN_MOVE_FORWARD: return "can_move_forward"
		ConditionType.CAN_MOVE_BACKWARD: return "can_move_backward"
		ConditionType.HAS_OBJECT_AHEAD: return "has_object_ahead"
		ConditionType.IS_AT_GOAL: return "is_at_goal"
		ConditionType.IS_AT_EDGE: return "is_at_edge"
		ConditionType.CAN_INTERACT: return "can_interact"
		ConditionType.PATH_IS_CLEAR: return "path_is_clear"
		ConditionType.REPEAT_COUNT: return "repeat_count"
		ConditionType.REPEAT_UNTIL_EDGE: return "repeat_until_edge"
		ConditionType.REPEAT_UNTIL_GOAL: return "repeat_until_goal"
		ConditionType.REPEAT_UNTIL_OBJECT: return "repeat_until_object"
		ConditionType.REPEAT_UNTIL_BLOCKED: return "repeat_until_blocked"
		ConditionType.COUNTER_EQUALS: return "counter_equals"
		ConditionType.COUNTER_NOT_EQUALS: return "counter_not_equals"
		ConditionType.COUNTER_GREATER_THAN: return "counter_greater_than"
		ConditionType.COUNTER_LESS_THAN: return "counter_less_than"
		ConditionType.COUNTER_GREATER_EQUAL: return "counter_greater_equal"
		ConditionType.COUNTER_LESS_EQUAL: return "counter_less_equal"
		ConditionType.IS_FACING_NORTH: return "is_facing_north"
		ConditionType.IS_FACING_EAST: return "is_facing_east"
		ConditionType.IS_FACING_SOUTH: return "is_facing_south"
		ConditionType.IS_FACING_WEST: return "is_facing_west"
		_: return "can_move_forward"

## Gibt einen Anzeige-Namen für die Condition zurück.
##
## @param condition: Der ConditionType
## @return: Der lesbare Name
static func get_display_name(condition: ConditionType) -> String:
	match condition:
		ConditionType.CAN_MOVE_FORWARD: return "Can Move Forward"
		ConditionType.CAN_MOVE_BACKWARD: return "Can Move Backward"
		ConditionType.HAS_OBJECT_AHEAD: return "Has Object Ahead"
		ConditionType.IS_AT_GOAL: return "Is At Goal"
		ConditionType.IS_AT_EDGE: return "Is At Edge"
		ConditionType.CAN_INTERACT: return "Can Interact"
		ConditionType.PATH_IS_CLEAR: return "Path Is Clear"
		ConditionType.REPEAT_COUNT: return "Repeat X Times"
		ConditionType.REPEAT_UNTIL_EDGE: return "Repeat Until Edge"
		ConditionType.REPEAT_UNTIL_GOAL: return "Repeat Until Goal"
		ConditionType.REPEAT_UNTIL_OBJECT: return "Repeat Until Object"
		ConditionType.REPEAT_UNTIL_BLOCKED: return "Repeat Until Blocked"
		ConditionType.COUNTER_EQUALS: return "Counter =="
		ConditionType.COUNTER_NOT_EQUALS: return "Counter !="
		ConditionType.COUNTER_GREATER_THAN: return "Counter >"
		ConditionType.COUNTER_LESS_THAN: return "Counter <"
		ConditionType.COUNTER_GREATER_EQUAL: return "Counter >="
		ConditionType.COUNTER_LESS_EQUAL: return "Counter <="
		ConditionType.IS_FACING_NORTH: return "Facing North"
		ConditionType.IS_FACING_EAST: return "Facing East"
		ConditionType.IS_FACING_SOUTH: return "Facing South"
		ConditionType.IS_FACING_WEST: return "Facing West"
		_: return "Unknown"

## Prüft ob die Condition einen Wert benötigt.
##
## Conditions wie REPEAT_COUNT oder COUNTER_* benötigen einen numerischen Wert.
##
## @param condition: Der ConditionType
## @return: true wenn ein Wert benötigt wird, false sonst
static func needs_value(condition: ConditionType) -> bool:
	return condition in [
		ConditionType.REPEAT_COUNT,
		ConditionType.COUNTER_EQUALS,
		ConditionType.COUNTER_NOT_EQUALS,
		ConditionType.COUNTER_GREATER_THAN,
		ConditionType.COUNTER_LESS_THAN,
		ConditionType.COUNTER_GREATER_EQUAL,
		ConditionType.COUNTER_LESS_EQUAL
	]

## Gibt eine lesbare String-Repräsentation zurück.
##
## @return: String-Repräsentation der ConditionBlockData
func _to_string() -> String:
	var result = "[ConditionBlockData type=%s" % get_display_name(condition_type)
	if needs_value(condition_type):
		result += ", value=%d" % value
	result += "]"
	return result

## Klont diese Ressource.
##
## @return: Eine Kopie dieser ConditionBlockData
func duplicate_data() -> ConditionBlockData:
	var data = ConditionBlockData.new()
	data.block_type = block_type
	data.block_id = block_id
	data.position = position
	data.condition_type = condition_type
	data.value = value
	return data

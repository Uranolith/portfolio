## Repräsentiert eine einzelne interpretierte Anweisung.
##
## Wird vom BlockInterpreter aus Block-Strukturen erstellt und
## vom CharacterExecutor ausgeführt. Kann verschachtelte Instructions
## für Loops und Conditionals enthalten.
class_name Instruction
extends RefCounted

## Typen von Instructions
enum InstructionType {
	MOVE_FORWARD,     ## Vorwärts bewegen
	MOVE_BACKWARD,    ## Rückwärts bewegen
	TURN_LEFT,        ## Nach links drehen
	TURN_RIGHT,       ## Nach rechts drehen
	JUMP,             ## Springen
	INTERACT,         ## Interagieren
	WAIT,             ## Warten
	LOOP_FOR,         ## For-Schleife
	LOOP_WHILE,       ## While-Schleife
	LOOP_DO_WHILE,    ## Do-While-Schleife
	CASE_IF,          ## If-Verzweigung
	CASE_IF_ELSE,     ## If-Else-Verzweigung
	CONDITION         ## Bedingung
}

## Der Typ dieser Instruction
var type: InstructionType

## Optionaler Wert (für Loop-Zähler, Conditions, etc.)
var value: Variant = null

## Bedingung (für Cases und Loops)
var case: Variant = null

## Verschachtelte Anweisungen (für Loop-Body, If-True-Branch)
var body: Array[Instruction] = []

## Else-Branch (für If-Else)
var else_body: Array[Instruction] = []

## Konstruktor.
##
## @param p_type: Der Instruction-Typ
## @param p_value: Optionaler Wert
## @param p_case: Optionale Bedingung
func _init(p_type: InstructionType, p_value: Variant = null, p_case: Variant = null):
	type = p_type
	value = p_value
	case = p_case

## Gibt eine lesbare String-Repräsentation zurück.
##
## @return: String-Repräsentation der Instruction
func _to_string() -> String:
	match type:
		InstructionType.MOVE_FORWARD:
			return "MoveForward()"
		InstructionType.MOVE_BACKWARD:
			return "MoveBackward()"
		InstructionType.TURN_LEFT:
			return "TurnLeft()"
		InstructionType.TURN_RIGHT:
			return "TurnRight()"
		InstructionType.JUMP:
			return "Jump()"
		InstructionType.INTERACT:
			return "Interact()"
		InstructionType.WAIT:
			return "Wait()"
		InstructionType.LOOP_FOR:
			return "For(%s) { %d instructions }" % [value, body.size()]
		InstructionType.LOOP_WHILE:
			return "While(%s) { %d instructions }" % [case, body.size()]
		InstructionType.LOOP_DO_WHILE:
			return "DoWhile(%s) { %d instructions }" % [case, body.size()]
		InstructionType.CASE_IF:
			return "If(%s) { %d instructions }" % [case, body.size()]
		InstructionType.CASE_IF_ELSE:
			return "IfElse(%s) { %d / %d instructions }" % [case, body.size(), else_body.size()]
		InstructionType.CONDITION:
			return "Condition(%s)" % value
	return "Unknown"

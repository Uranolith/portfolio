## Interpretiert Block-Strukturen in ausführbare Instructions.
##
## Durchläuft rekursiv alle Blöcke vom Program Block ausgehend und
## konvertiert sie in eine lineare Liste von Instructions für den CharacterExecutor.
class_name BlockInterpreter
extends RefCounted

## Signal wird gesendet, wenn die Interpretation startet
signal interpretation_started()

## Signal wird gesendet, wenn die Interpretation abgeschlossen ist
##
## @param instructions: Array der erzeugten Instructions
signal interpretation_completed(instructions: Array)

## Signal wird gesendet, wenn ein Fehler auftritt
##
## @param error_message: Die Fehlermeldung
signal interpretation_error(error_message: String)

## Der zu interpretierende Program Block
var _program_block: DraggableBlock = null

## Enum für Instruction Types (lokale Kopie für einfacheren Zugriff)
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

## Interpretiert das gesamte Programm vom Program Block ausgehend.
##
## Traversiert die Block-Struktur und generiert eine Liste von Instructions.
##
## @param program_block: Der Program-Block als Einstiegspunkt
## @return: Array von Instruction-Objekten
func interpret(program_block: DraggableBlock) -> Array:
	if not program_block:
		push_error("[BlockInterpreter] Program block is null")
		interpretation_error.emit("Program block is null")
		return []
	
	_program_block = program_block
	interpretation_started.emit()
	
	print("[BlockInterpreter] === Starting interpretation from Program Block ===")
	
	var instructions: Array = []
	
	if program_block is ContainerBlock:
		var container = program_block as ContainerBlock
		if container.instruction_zones.size() > 0:
			var first_zone = container.instruction_zones[0]
			var first_child = first_zone.get_first_child()
			
			if first_child:
				print("[BlockInterpreter] Found first block in program: %s" % first_child.block_name)
				var current_block = first_child
				
				while current_block and is_instance_valid(current_block):
					var block_instructions = _interpret_block(current_block)
					instructions.append_array(block_instructions)
					current_block = current_block.block_below
			else:
				print("[BlockInterpreter] Program block is empty (no blocks attached)")
		else:
			print("[BlockInterpreter] Program block has no instruction zones")
	else:
		push_error("[BlockInterpreter] Program block is not a ContainerBlock")
		interpretation_error.emit("Program block is not a ContainerBlock")
		return []
	
	print("[BlockInterpreter] === Interpretation completed. Total instructions: %d ===" % instructions.size())
	interpretation_completed.emit(instructions)
	
	return instructions

## Interpretiert einen einzelnen Block.
##
## Entscheidet basierend auf dem Block-Typ, welche Interpret-Methode aufgerufen wird.
##
## @param block: Der zu interpretierende Block
## @return: Array von Instructions
func _interpret_block(block: DraggableBlock) -> Array:
	if not block or not is_instance_valid(block):
		return []
	
	if not block.data:
		push_warning("[BlockInterpreter] Block has no data: %s" % block.block_name)
		return []
	
	var instructions: Array = []
	
	match block.data.block_type:
		BlockData.BlockType.BASE:
			var instruction = _interpret_base_block(block)
			if instruction:
				instructions.append(instruction)
		
		BlockData.BlockType.CONDITION:
			var instruction = _interpret_condition_block(block)
			if instruction:
				instructions.append(instruction)
		
		BlockData.BlockType.CASE_DISTINCTION:
			var instruction = _interpret_case_distinction_block(block)
			if instruction:
				instructions.append(instruction)
		
		BlockData.BlockType.LOOP:
			var instruction = _interpret_loop_block(block)
			if instruction:
				instructions.append(instruction)
		
		_:
			push_warning("[BlockInterpreter] Unknown block type: %s" % block.data.block_type)
	
	return instructions

## Hilfsfunktion zum Erstellen einer Instruction (als Dictionary).
##
## @param type: Der Instruction-Typ
## @param value: Optionaler Wert (z.B. Loop-Iterationen)
## @param case: Optionale Bedingung (z.B. "character.can_move_forward()")
## @return: Dictionary mit Instruction-Daten
func _create_instruction(type: InstructionType, value: Variant = null, case: Variant = null) -> Dictionary:
	return {
		"type": type,
		"value": value,
		"case": case,
		"body": [],
		"else_body": []
	}

## Interpretiert einen Base-Block.
##
## Konvertiert Action-Typen (MOVE_FORWARD, TURN_LEFT, etc.) in Instructions.
##
## @param block: Der Base-Block
## @return: Die generierte Instruction oder null
func _interpret_base_block(block: DraggableBlock):
	var base_block = block as BaseBlock
	if not base_block:
		push_warning("[BlockInterpreter] Block is not a BaseBlock: %s" % block.block_name)
		return null
	
	var action_type = base_block.get_action_type()
	var instruction_type: InstructionType
	
	match action_type:
		BlockData.ActionType.MOVE_FORWARD:
			instruction_type = InstructionType.MOVE_FORWARD
		BlockData.ActionType.MOVE_BACKWARD:
			instruction_type = InstructionType.MOVE_BACKWARD
		BlockData.ActionType.TURN_LEFT:
			instruction_type = InstructionType.TURN_LEFT
		BlockData.ActionType.TURN_RIGHT:
			instruction_type = InstructionType.TURN_RIGHT
		BlockData.ActionType.JUMP:
			instruction_type = InstructionType.JUMP
		BlockData.ActionType.INTERACT:
			instruction_type = InstructionType.INTERACT
		BlockData.ActionType.WAIT:
			instruction_type = InstructionType.WAIT
		_:
			push_warning("[BlockInterpreter] Unknown action type: %d" % action_type)
			return null
	
	print("[BlockInterpreter]   BaseBlock: %s" % InstructionType.keys()[instruction_type])
	return _create_instruction(instruction_type)

## Interpretiert einen Loop-Block.
##
## Konvertiert Loop-Typen (FOR, WHILE, DO_WHILE) in Instructions mit Body.
##
## @param block: Der Loop-Block
## @return: Die generierte Instruction oder null
func _interpret_loop_block(block: DraggableBlock):
	if not block.data or not (block.data is LoopBlockData):
		push_warning("[BlockInterpreter] Block data is not LoopBlockData")
		return null
	
	var loop_data = block.data as LoopBlockData
	var instruction = null
	var condition_code = "true"  # Default
	
	# Lese Condition aus der Condition-Zone (falls vorhanden)
	if block is ContainerBlock:
		var container = block as ContainerBlock
		if container.condition_zones.size() > 0:
			var condition_zone = container.condition_zones[0]
			var condition_block = condition_zone.get_child()
			
			if condition_block and is_instance_valid(condition_block):
				condition_code = _interpret_condition_block(condition_block)
				print("[BlockInterpreter]   Loop has condition: %s" % condition_code)
	
	match loop_data.loop_type:
		LoopBlockData.LoopType.FOR:
			# Bei For-Loops: Wenn Condition eine Zahl ist (z.B. REPEAT_COUNT), nutze sie
			# Sonst verwende 5 als Default
			var iterations = 5
			if condition_code.is_valid_int():
				iterations = int(condition_code)
			instruction = _create_instruction(InstructionType.LOOP_FOR, iterations)
			print("[BlockInterpreter]   LoopFor: %d iterations" % iterations)
		LoopBlockData.LoopType.WHILE:
			if condition_code.is_valid_int():
			# Zahl (z.B. "5") -> FOR-Schleife
				var iterations = int(condition_code)
				instruction = _create_instruction(InstructionType.LOOP_FOR, iterations)
				print("[BlockInterpreter]   LoopWhile (Auto-Converted to For): %d iterations" % iterations)
			else:
			# Text (z.B. "character.can_move()") While-Schleife
				instruction = _create_instruction(InstructionType.LOOP_WHILE, null, condition_code)
				print("[BlockInterpreter]   LoopWhile: case=%s" % condition_code)
		LoopBlockData.LoopType.DO_WHILE:
			instruction = _create_instruction(InstructionType.LOOP_DO_WHILE, null, condition_code)
			print("[BlockInterpreter]   LoopDoWhile: case=%s" % condition_code)
		_:
			push_warning("[BlockInterpreter] Unknown loop type: %d" % loop_data.loop_type)
			return null
	
	# Interpretiere verschachtelte Blöcke im Loop-Body
	if block is ContainerBlock:
		var container = block as ContainerBlock
		if container.instruction_zones.size() > 0:
			var first_zone = container.instruction_zones[0]
			var first_child = first_zone.get_first_child()
			
			if first_child:
				var current_block = first_child
				
				# Durchlaufe die gesamte Kette im Loop-Body
				while current_block and is_instance_valid(current_block):
					var nested_instructions = _interpret_block(current_block)
					instruction["body"].append_array(nested_instructions)
					current_block = current_block.block_below
	
	print("[BlockInterpreter]     Loop body contains %d instructions" % instruction["body"].size())
	return instruction

## Interpretiert einen CaseDistinction-Block.
##
## Konvertiert If/If-Else Strukturen in Instructions mit Body und Else-Body.
##
## @param block: Der CaseDistinction-Block
## @return: Die generierte Instruction oder null
func _interpret_case_distinction_block(block: DraggableBlock):
	if not block.data or not (block.data is CaseDistinctionBlockData):
		push_warning("[BlockInterpreter] Block data is not CaseDistinctionBlockData")
		return null
	
	var case_data = block.data as CaseDistinctionBlockData
	var instruction = null
	var condition_code = "true"  # Default
	
	# Lese Condition aus der Condition-Zone (falls vorhanden)
	if block is ContainerBlock:
		var container = block as ContainerBlock
		if container.condition_zones.size() > 0:
			var condition_zone = container.condition_zones[0]
			var condition_block = condition_zone.get_child()
			
			if condition_block and is_instance_valid(condition_block):
				condition_code = _interpret_condition_block(condition_block)
				print("[BlockInterpreter]   Case has condition: %s" % condition_code)
	
	match case_data.case_type:
		CaseDistinctionBlockData.CaseType.IF:
			instruction = _create_instruction(InstructionType.CASE_IF, null, condition_code)
			print("[BlockInterpreter]   CaseIf: case=%s" % condition_code)
		CaseDistinctionBlockData.CaseType.IF_ELSE:
			instruction = _create_instruction(InstructionType.CASE_IF_ELSE, null, condition_code)
			print("[BlockInterpreter]   CaseIfElse: case=%s" % condition_code)
		_:
			push_warning("[BlockInterpreter] Unknown case type: %d" % case_data.case_type)
			return null
	
	# Interpretiere verschachtelte Blöcke im Case-Body
	if block is ContainerBlock:
		var container = block as ContainerBlock
		
		# If-Branch (erste Instruction-Zone)
		if container.instruction_zones.size() > 0:
			var if_zone = container.instruction_zones[0]
			var first_child = if_zone.get_first_child()
			
			if first_child:
				var current_block = first_child
				
				while current_block and is_instance_valid(current_block):
					var nested_instructions = _interpret_block(current_block)
					instruction["body"].append_array(nested_instructions)
					current_block = current_block.block_below
		
		print("[BlockInterpreter]     If body contains %d instructions" % instruction["body"].size())
		
		# Else-Branch (zweite Instruction-Zone, nur bei IF_ELSE)
		if case_data.case_type == CaseDistinctionBlockData.CaseType.IF_ELSE:
			if container.instruction_zones.size() > 1:
				var else_zone = container.instruction_zones[1]
				var first_child = else_zone.get_first_child()
				
				if first_child:
					var current_block = first_child
					
					while current_block and is_instance_valid(current_block):
						var nested_instructions = _interpret_block(current_block)
						instruction["else_body"].append_array(nested_instructions)
						current_block = current_block.block_below
			
			print("[BlockInterpreter]     Else body contains %d instructions" % instruction["else_body"].size())
	
	return instruction

## Interpretiert einen Condition-Block (Bedingung/Ausdruck).
##
## Konvertiert Condition-Typen in ausführbaren Code-String.
##
## @param block: Der Condition-Block
## @return: Code-String für die Bedingung (z.B. "character.can_move_forward()")
func _interpret_condition_block(block: DraggableBlock) -> String:
	if not block.data or not (block.data is ConditionBlockData):
		push_warning("[BlockInterpreter] Block data is not ConditionBlockData")
		return "true"  # Fallback
	
	var cond_data = block.data as ConditionBlockData
	var condition_code = ""
	
	match cond_data.condition_type:
		# Boolean Conditions
		ConditionBlockData.ConditionType.CAN_MOVE_FORWARD:
			condition_code = "character.can_move_forward()"
		ConditionBlockData.ConditionType.CAN_MOVE_BACKWARD:
			condition_code = "character.can_move_backward()"
		ConditionBlockData.ConditionType.HAS_OBJECT_AHEAD:
			condition_code = "character.has_object_ahead()"
		ConditionBlockData.ConditionType.IS_AT_GOAL:
			condition_code = "character.is_at_goal()"
		ConditionBlockData.ConditionType.IS_AT_EDGE:
			condition_code = "character.is_at_edge()"
		ConditionBlockData.ConditionType.CAN_INTERACT:
			condition_code = "character.can_interact()"
		ConditionBlockData.ConditionType.PATH_IS_CLEAR:
			condition_code = "character.path_is_clear()"
		
		# Loop-spezifische Conditions (für For-Loops)
		ConditionBlockData.ConditionType.REPEAT_COUNT:
			condition_code = str(cond_data.value)  # Wird als Zahl für "for i in range(X)" verwendet
		ConditionBlockData.ConditionType.REPEAT_UNTIL_EDGE:
			condition_code = "not character.is_at_edge()"
		ConditionBlockData.ConditionType.REPEAT_UNTIL_GOAL:
			condition_code = "not character.is_at_goal()"
		ConditionBlockData.ConditionType.REPEAT_UNTIL_OBJECT:
			condition_code = "not character.has_object_ahead()"
		ConditionBlockData.ConditionType.REPEAT_UNTIL_BLOCKED:
			condition_code = "character.can_move_forward()"
		
		# Counter Conditions
		ConditionBlockData.ConditionType.COUNTER_EQUALS:
			condition_code = "counter == %d" % cond_data.value
		ConditionBlockData.ConditionType.COUNTER_NOT_EQUALS:
			condition_code = "counter != %d" % cond_data.value
		ConditionBlockData.ConditionType.COUNTER_GREATER_THAN:
			condition_code = "counter > %d" % cond_data.value
		ConditionBlockData.ConditionType.COUNTER_LESS_THAN:
			condition_code = "counter < %d" % cond_data.value
		ConditionBlockData.ConditionType.COUNTER_GREATER_EQUAL:
			condition_code = "counter >= %d" % cond_data.value
		ConditionBlockData.ConditionType.COUNTER_LESS_EQUAL:
			condition_code = "counter <= %d" % cond_data.value
		
		# Directional Conditions
		ConditionBlockData.ConditionType.IS_FACING_NORTH:
			condition_code = "character.is_facing_north()"
		ConditionBlockData.ConditionType.IS_FACING_EAST:
			condition_code = "character.is_facing_east()"
		ConditionBlockData.ConditionType.IS_FACING_SOUTH:
			condition_code = "character.is_facing_south()"
		ConditionBlockData.ConditionType.IS_FACING_WEST:
			condition_code = "character.is_facing_west()"
		
		_:
			push_warning("[BlockInterpreter] Unknown condition type: %d" % cond_data.condition_type)
			condition_code = "true"  # Fallback
	
	print("[BlockInterpreter]   Condition: %s" % condition_code)
	return condition_code

## Gibt die Instruction-Liste formatiert aus (Debug).
##
## @param instructions: Array der auszugebenden Instructions
## @param indent: Einrückungstiefe
func print_instructions(instructions: Array, indent: int = 0) -> void:
	var indent_str = "  ".repeat(indent)
	
	for instruction in instructions:
		print("%s%s" % [indent_str, _instruction_to_string(instruction)])
		
		# Rekursiv für verschachtelte Instructions
		if instruction["body"].size() > 0:
			print_instructions(instruction["body"], indent + 1)
		
		if instruction["else_body"].size() > 0:
			print("%sElse:" % indent_str)
			print_instructions(instruction["else_body"], indent + 1)

## Konvertiert eine Instruction zu einem String.
##
## @param instruction: Die Instruction als Dictionary
## @return: String-Repräsentation der Instruction
func _instruction_to_string(instruction: Dictionary) -> String:
	var type = instruction["type"]
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
			return "For(%s) { %d instructions }" % [instruction["value"], instruction["body"].size()]
		InstructionType.LOOP_WHILE:
			return "While(%s) { %d instructions }" % [instruction["case"], instruction["body"].size()]
		InstructionType.LOOP_DO_WHILE:
			return "DoWhile(%s) { %d instructions }" % [instruction["case"], instruction["body"].size()]
		InstructionType.CASE_IF:
			return "If(%s) { %d instructions }" % [instruction["case"], instruction["body"].size()]
		InstructionType.CASE_IF_ELSE:
			return "IfElse(%s) { %d / %d instructions }" % [instruction["case"], instruction["body"].size(), instruction["else_body"].size()]
		InstructionType.CONDITION:
			return "Condition(%s)" % instruction["value"]
	return "Unknown"

## Generiert ausführbaren Code aus Instructions.
##
## @param instructions: Array der Instructions
## @param indent: Einrückungstiefe
## @return: Generierter Code als String
func generate_code(instructions: Array, indent: int = 0) -> String:
	var code = ""
	var indent_str = "\t".repeat(indent)
	
	for instruction in instructions:
		var type = instruction["type"]
		match type:
			InstructionType.MOVE_FORWARD:
				code += "%scharacter.move_forward()\n" % indent_str
			InstructionType.MOVE_BACKWARD:
				code += "%scharacter.move_backward()\n" % indent_str
			InstructionType.TURN_LEFT:
				code += "%scharacter.turn_left()\n" % indent_str
			InstructionType.TURN_RIGHT:
				code += "%scharacter.turn_right()\n" % indent_str
			InstructionType.JUMP:
				code += "%scharacter.jump()\n" % indent_str
			InstructionType.INTERACT:
				code += "%scharacter.interact()\n" % indent_str
			InstructionType.WAIT:
				code += "%scharacter.wait()\n" % indent_str
			
			InstructionType.LOOP_FOR:
				code += "%sfor i in range(%s):\n" % [indent_str, instruction["value"]]
				code += generate_code(instruction["body"], indent + 1)
			
			InstructionType.LOOP_WHILE:
				code += "%swhile %s:\n" % [indent_str, instruction["case"]]
				code += generate_code(instruction["body"], indent + 1)
			
			InstructionType.LOOP_DO_WHILE:
				# Do-While wird als while true mit break am Ende simuliert
				code += "%swhile true:  # do-while\n" % indent_str
				code += generate_code(instruction["body"], indent + 1)
				code += "%s\tif not (%s):\n" % [indent_str, instruction["case"]]
				code += "%s\t\tbreak\n" % indent_str
			
			InstructionType.CASE_IF:
				code += "%sif %s:\n" % [indent_str, instruction["case"]]
				code += generate_code(instruction["body"], indent + 1)
			
			InstructionType.CASE_IF_ELSE:
				code += "%sif %s:\n" % [indent_str, instruction["case"]]
				code += generate_code(instruction["body"], indent + 1)
				code += "%selse:\n" % indent_str
				code += generate_code(instruction["else_body"], indent + 1)
			
			InstructionType.CONDITION:
				code += "%s# Condition: %s\n" % [indent_str, instruction["value"]]
	
	return code

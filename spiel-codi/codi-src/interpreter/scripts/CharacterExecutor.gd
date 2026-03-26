## Führt interpretierte Instructions auf dem Character aus.
##
## Nimmt Instructions vom BlockInterpreter und steuert den CharacterController.
## Unterstützt asynchrone Ausführung, Pause/Resume und verschachtelte Schleifen.
class_name CharacterExecutor
extends RefCounted

## Signal wird gesendet, wenn die Ausführung startet
signal execution_started()

## Signal wird für jeden Ausführungsschritt gesendet
##
## @param instruction_name: Name der ausgeführten Instruction
signal execution_step(instruction_name: String)

## Signal wird gesendet, wenn die Ausführung erfolgreich abgeschlossen wurde
signal execution_completed()

## Signal wird gesendet, wenn die Ausführung gestoppt wurde
signal execution_stopped()

## Signal wird gesendet, wenn ein Fehler auftritt
##
## @param error_message: Die Fehlermeldung
signal execution_error(error_message: String)

## Signal wird gesendet, wenn die Ausführung pausiert wird
signal execution_paused()

## Signal wird gesendet, wenn die Ausführung fortgesetzt wird
signal execution_resumed()

## Referenz zum CharacterController
var _character: CharacterController = null

## Aktueller Ausführungsstatus (läuft gerade)
var _is_running: bool = false

## Aktueller Pause-Status
var _is_paused: bool = false

## Aktuelle Instructions
var _instructions: Array = []

## Aktueller Ausführungs-Index
var _current_index: int = 0

## Counter-Stack für verschachtelte Schleifen.
## Jede Schleife pusht ihren Counter auf den Stack.
var _counter_stack: Array[int] = []

## Maximale Iterationen für Endlos-Schleifen-Schutz
const MAX_LOOP_ITERATIONS = 1000

## Gibt den aktuellen Counter zurück (oberster Stack-Wert).
##
## @return: Der aktuelle Counter-Wert
func _get_current_counter() -> int:
	if _counter_stack.is_empty():
		return 0
	return _counter_stack[_counter_stack.size() - 1]

## Setzt den aktuellen Counter (oberster Stack-Wert).
##
## @param value: Der neue Counter-Wert
func _set_current_counter(value: int) -> void:
	if _counter_stack.is_empty():
		_counter_stack.append(value)
	else:
		_counter_stack[_counter_stack.size() - 1] = value

## Pusht einen neuen Counter auf den Stack (für neue Schleife).
##
## @param initial_value: Der initiale Wert des Counters
func _push_counter(initial_value: int = 0) -> void:
	_counter_stack.append(initial_value)
	print("[CharacterExecutor] Counter pushed. Stack depth: %d, values: %s" % [_counter_stack.size(), _counter_stack])

## Popt den obersten Counter vom Stack (Schleife beendet).
##
## @return: Der gepoppte Counter-Wert
func _pop_counter() -> int:
	if _counter_stack.is_empty():
		return 0
	var value = _counter_stack.pop_back()
	print("[CharacterExecutor] Counter popped. Stack depth: %d, values: %s" % [_counter_stack.size(), _counter_stack])
	return value

## Initialisiert den Executor mit einem Character.
##
## @param character: Der zu steuernde CharacterController
func initialize(character: CharacterController) -> void:
	_character = character
	print("[CharacterExecutor] Initialisiert mit Character: %s" % character.name if character else "null")

## Führt eine Liste von Instructions aus.
##
## Asynchrone Ausführung mit await. Sendet Signale für jeden Schritt.
##
## @param instructions: Array von Instruction-Objekten
func execute(instructions: Array) -> void:
	if not _character:
		push_error("[CharacterExecutor] Kein Character initialisiert!")
		execution_error.emit("Kein Character initialisiert!")
		return
	
	if _is_running:
		push_warning("[CharacterExecutor] Bereits am Ausführen!")
		return
	
	_instructions = instructions
	_current_index = 0
	_counter_stack.clear()
	_is_running = true
	_is_paused = false
	
	execution_started.emit()
	print("[CharacterExecutor] === Starte Ausführung mit %d Instruktionen ===" % instructions.size())
	
	await _execute_instructions(instructions)
	
	_is_running = false
	execution_completed.emit()
	print("[CharacterExecutor] === Ausführung abgeschlossen ===")

## Pausiert die Ausführung.
func pause() -> void:
	if _is_running and not _is_paused:
		_is_paused = true
		execution_paused.emit()
		print("[CharacterExecutor] Pausiert")

## Setzt die Ausführung fort.
func resume() -> void:
	if _is_running and _is_paused:
		_is_paused = false
		execution_resumed.emit()
		print("[CharacterExecutor] Fortgesetzt")

## Stoppt die Ausführung.
func stop() -> void:
	if _is_running:
		_is_running = false
		_is_paused = false
		execution_stopped.emit()
		print("[CharacterExecutor] Gestoppt")

## Führt eine Liste von Instruktionen aus (rekursiv).
##
## @param instructions: Array von Instruction-Dictionaries
func _execute_instructions(instructions: Array) -> void:
	for instruction in instructions:
		if not _is_running:
			break
		
		# Warte während pausiert
		while _is_paused:
			await _character.get_tree().create_timer(0.1).timeout
			if not _is_running:
				return
		
		await _execute_instruction(instruction)

## Führt eine einzelne Instruktion aus.
##
## Dispatched basierend auf Instruction-Type zu den spezifischen Methoden.
##
## @param instruction: Das Instruction-Dictionary
func _execute_instruction(instruction: Dictionary) -> void:
	if not _is_running:
		return
	
	var type = instruction.get("type", -1)
	var value = instruction.get("value", null)
	var condition = instruction.get("case", "true")
	var body = instruction.get("body", [])
	var else_body = instruction.get("else_body", [])
	
	match type:
		BlockInterpreter.InstructionType.MOVE_FORWARD:
			execution_step.emit("Move Forward")
			await _character.move_forward()
		
		BlockInterpreter.InstructionType.MOVE_BACKWARD:
			execution_step.emit("Move Backward")
			await _character.move_backward()
		
		BlockInterpreter.InstructionType.TURN_LEFT:
			execution_step.emit("Turn Left")
			await _character.turn_left()
		
		BlockInterpreter.InstructionType.TURN_RIGHT:
			execution_step.emit("Turn Right")
			await _character.turn_right()
		
		BlockInterpreter.InstructionType.JUMP:
			execution_step.emit("Jump")
			await _character.jump()
		
		BlockInterpreter.InstructionType.INTERACT:
			execution_step.emit("Interact")
			await _character.interact()
		
		BlockInterpreter.InstructionType.WAIT:
			execution_step.emit("Wait")
			await _character.wait()
		
		BlockInterpreter.InstructionType.LOOP_FOR:
			await _execute_for_loop(value, body)
		
		BlockInterpreter.InstructionType.LOOP_WHILE:
			await _execute_while_loop(condition, body)
		
		BlockInterpreter.InstructionType.LOOP_DO_WHILE:
			await _execute_do_while_loop(condition, body)
		
		BlockInterpreter.InstructionType.CASE_IF:
			await _execute_if(condition, body)
		
		BlockInterpreter.InstructionType.CASE_IF_ELSE:
			await _execute_if_else(condition, body, else_body)
		
		_:
			push_warning("[CharacterExecutor] Unbekannter Instruction-Type: %d" % type)

## Führt eine For-Schleife aus.
##
## @param iterations: Anzahl der Iterationen
## @param body: Array von Instructions im Schleifenkörper
func _execute_for_loop(iterations, body: Array) -> void:
	var count = int(iterations) if iterations != null else 1
	execution_step.emit("For Loop (%d iterations)" % count)
	print("[CharacterExecutor] For-Loop: %d Iterationen" % count)
	
	# Pushe neuen Counter für diese Schleife
	_push_counter(0)
	
	for i in range(min(count, MAX_LOOP_ITERATIONS)):
		if not _is_running:
			break
		
		_set_current_counter(i)
		print("[CharacterExecutor]   For Iteration %d/%d (counter: %d)" % [i + 1, count, i])
		await _execute_instructions(body)
	
	# Pope Counter nach Schleifenende
	_pop_counter()

## Führt eine While-Schleife aus.
##
## @param condition: Die Bedingung als String
## @param body: Array von Instructions im Schleifenkörper
func _execute_while_loop(condition: String, body: Array) -> void:
	execution_step.emit("While Loop (%s)" % condition)
	print("[CharacterExecutor] While-Loop: %s" % condition)
	
	# Pushe neuen Counter für diese Schleife
	_push_counter(0)
	
	var iteration = 0
	while _is_running and iteration < MAX_LOOP_ITERATIONS:
		var result = _evaluate_condition(condition)
		if not result:
			break
		
		print("[CharacterExecutor]   While Iteration %d (counter: %d, condition: %s)" % [iteration + 1, _get_current_counter(), condition])
		await _execute_instructions(body)
		
		# Inkrementiere Counter nach jeder Iteration
		iteration += 1
		_set_current_counter(iteration)
	
	# Pope Counter nach Schleifenende
	_pop_counter()
	
	if iteration >= MAX_LOOP_ITERATIONS:
		push_warning("[CharacterExecutor] While-Loop erreichte maximale Iterationen!")

## Führt eine Do-While-Schleife aus.
##
## @param condition: Die Bedingung als String
## @param body: Array von Instructions im Schleifenkörper
func _execute_do_while_loop(condition: String, body: Array) -> void:
	execution_step.emit("Do-While Loop (%s)" % condition)
	print("[CharacterExecutor] Do-While-Loop: %s" % condition)
	
	# Pushe neuen Counter für diese Schleife
	_push_counter(0)
	
	var iteration = 0
	while _is_running and iteration < MAX_LOOP_ITERATIONS:
		print("[CharacterExecutor]   Do-While Iteration %d (counter: %d)" % [iteration + 1, _get_current_counter()])
		await _execute_instructions(body)
		
		# Inkrementiere Counter nach jeder Iteration
		iteration += 1
		_set_current_counter(iteration)
		
		var result = _evaluate_condition(condition)
		if not result:
			break
	
	# Pope Counter nach Schleifenende
	_pop_counter()
	
	if iteration >= MAX_LOOP_ITERATIONS:
		push_warning("[CharacterExecutor] Do-While-Loop erreichte maximale Iterationen!")

## Führt eine If-Anweisung aus.
##
## @param condition: Die Bedingung als String
## @param body: Array von Instructions im If-Body
func _execute_if(condition: String, body: Array) -> void:
	execution_step.emit("If (%s)" % condition)
	print("[CharacterExecutor] If: %s" % condition)
	
	var result = _evaluate_condition(condition)
	if result:
		print("[CharacterExecutor]   Condition true - führe Body aus")
		await _execute_instructions(body)
	else:
		print("[CharacterExecutor]   Condition false - überspringe Body")

## Führt eine If-Else-Anweisung aus.
##
## @param condition: Die Bedingung als String
## @param body: Array von Instructions im If-Body
## @param else_body: Array von Instructions im Else-Body
func _execute_if_else(condition: String, body: Array, else_body: Array) -> void:
	execution_step.emit("If-Else (%s)" % condition)
	print("[CharacterExecutor] If-Else: %s" % condition)
	
	var result = _evaluate_condition(condition)
	if result:
		print("[CharacterExecutor]   Condition true - führe If-Body aus")
		await _execute_instructions(body)
	else:
		print("[CharacterExecutor]   Condition false - führe Else-Body aus")
		await _execute_instructions(else_body)

## Evaluiert eine Bedingung.
##
## Unterstützt Negation mit "not" und delegiert an _evaluate_single_condition.
##
## @param condition: Die zu evaluierende Bedingung als String
## @return: Das Ergebnis der Evaluation
func _evaluate_condition(condition: String) -> bool:
	if not _character:
		return false
	
	# Prüfe auf Negation
	var is_negated = condition.begins_with("not ")
	var clean_condition = condition.substr(4).strip_edges() if is_negated else condition
	
	var result = _evaluate_single_condition(clean_condition)
	
	return !result if is_negated else result

## Evaluiert eine einzelne Bedingung (ohne Negation).
##
## Unterstützt Character-Methoden, Counter-Vergleiche und Boolean-Werte.
##
## @param condition: Die zu evaluierende Bedingung als String
## @return: Das Ergebnis der Evaluation
func _evaluate_single_condition(condition: String) -> bool:
	if condition == "true": return true
	if condition == "false": return false
	
	match condition:
		"character.can_move_forward()": return _character.can_move_forward()
		"character.can_move_backward()": return _character.can_move_backward()
		"character.has_object_ahead()": return _character.has_object_ahead()
		"character.is_at_goal()": return _character.is_at_goal()
		"character.is_at_edge()": return _character.is_at_edge()
		"character.can_interact()": return _character.can_interact()
		"character.path_is_clear()": return _character.path_is_clear()
		
		"character.is_facing_north()": return _character.is_facing_north()
		"character.is_facing_east()": return _character.is_facing_east()
		"character.is_facing_south()": return _character.is_facing_south()
		"character.is_facing_west()": return _character.is_facing_west()
	
	if condition.begins_with("counter"):
		return _evaluate_counter_condition(condition)
	
	if condition.is_valid_int():
		push_warning("[CharacterExecutor] Zahl '%s' als Condition erhalten. Interpretiere als FALSE, um Infinite Loop zu verhindern." % condition)
		return false
	
	# Fallback
	push_warning("[CharacterExecutor] Unbekannte Condition: %s - return true" % condition)
	return true

## Evaluiert Counter-basierte Bedingungen.
##
## Unterstützt Vergleiche: ==, !=, <, >, <=, >=
##
## @param condition: Die Counter-Bedingung als String (z.B. "counter >= 5")
## @return: Das Ergebnis des Vergleichs
func _evaluate_counter_condition(condition: String) -> bool:
	# Verwende den aktuellen Counter vom Stack (oberste Schleife)
	var counter_value = _get_current_counter()
	
	# Parse die Bedingung: "counter == 5", "counter > 3", etc.
	# Wichtig: Prüfe längere Operatoren zuerst (>=, <=, !=, ==)
	
	if ">=" in condition:
		var parts = condition.split(">=")
		if parts.size() == 2:
			var value = int(parts[1].strip_edges())
			var result = counter_value >= value
			print("[CharacterExecutor] Counter condition: %d >= %d = %s" % [counter_value, value, result])
			return result
	elif "<=" in condition:
		var parts = condition.split("<=")
		if parts.size() == 2:
			var value = int(parts[1].strip_edges())
			var result = counter_value <= value
			print("[CharacterExecutor] Counter condition: %d <= %d = %s" % [counter_value, value, result])
			return result
	elif "!=" in condition:
		var parts = condition.split("!=")
		if parts.size() == 2:
			var value = int(parts[1].strip_edges())
			var result = counter_value != value
			print("[CharacterExecutor] Counter condition: %d != %d = %s" % [counter_value, value, result])
			return result
	elif "==" in condition:
		var parts = condition.split("==")
		if parts.size() == 2:
			var value = int(parts[1].strip_edges())
			var result = counter_value == value
			print("[CharacterExecutor] Counter condition: %d == %d = %s" % [counter_value, value, result])
			return result
	elif ">" in condition:
		var parts = condition.split(">")
		if parts.size() == 2:
			var value = int(parts[1].strip_edges())
			var result = counter_value > value
			print("[CharacterExecutor] Counter condition: %d > %d = %s" % [counter_value, value, result])
			return result
	elif "<" in condition:
		var parts = condition.split("<")
		if parts.size() == 2:
			var value = int(parts[1].strip_edges())
			var result = counter_value < value
			print("[CharacterExecutor] Counter condition: %d < %d = %s" % [counter_value, value, result])
			return result
	
	push_warning("[CharacterExecutor] Konnte Counter-Condition nicht parsen: %s" % condition)
	return false

## Prüft ob die Ausführung läuft.
##
## @return: true wenn die Ausführung läuft
func is_running() -> bool:
	return _is_running

## Prüft ob die Ausführung pausiert ist.
##
## @return: true wenn die Ausführung pausiert ist
func is_paused() -> bool:
	return _is_paused

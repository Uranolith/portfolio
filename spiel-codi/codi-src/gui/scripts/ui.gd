## Hauptcontroller für die Benutzeroberfläche.
##
## Verwaltet LevelLoader, Blocks und UI-State.
## Koordiniert Interpreter, Executor und alle UI-Container.
extends Control

@export_group("Core Components")
## Referenz zum LevelLoader-Node
@export var level_loader_node: LevelLoader

## Startet automatisch ein Level bei _ready()
@export var start_level_on_ready: bool = true

## Pfad zum Standard-Level das geladen werden soll
@export var default_level_path: String = "res://levels/data/level_test.json"

@export_group("Container References")
## Referenz zum BlockCanvasContainer
@export var block_canvas_container: BlockCanvasContainer

## Referenz zum GameViewContainer
@export var game_view_container: GameViewContainer

## Referenz zum LevelDetailsContainer
@export var level_details_container: LevelDetailsContainer


## Block-Container (von BlockCanvasContainer)
var block_container: CanvasGroup:
	get:
		if block_canvas_container:
			return block_canvas_container.get_blocks_container()
		return null

## Canvas-Kamera (von BlockCanvasContainer)
var canvas_camera: Camera2D:
	get:
		if block_canvas_container:
			return block_canvas_container.get_canvas_camera()
		return null

## Character (von GameViewContainer)
var character_node: CharacterController:
	get:
		if game_view_container:
			return game_view_container.get_character()
		return null

## Level-Loader Referenz
var level_loader: LevelLoader:
	get:
		return level_loader_node

## Character Startposition (für Reset)
var _character_start_position: Vector2 = Vector2.ZERO

## Aktuelles Level
var current_level: LevelData = null

## BlockInterpreter-Instanz
var _interpreter = null

## CharacterExecutor-Instanz
var _executor = null

## Initialisiert die UI und alle Komponenten.
func _ready():
	DisplayServer.window_set_min_size(Vector2i(1280, 720))
	
	# Verbinde mit dem existierenden LevelLoader
	_connect_level_loader_signals()
	
	# Initialisiere Interpreter und Executor
	_setup_interpreter()
	_setup_executor()
	
	# Verbinde Container-Signale
	_connect_container_signals()
	
	# Speichere Character-Startposition
	if character_node:
		_character_start_position = character_node.global_position
	
	# Lade Startlevel wenn gewünscht
	if start_level_on_ready and default_level_path != "":
		call_deferred("_load_initial_level")

## Verbindet die Container-Signale.
func _connect_container_signals():
	# BlockCanvasContainer Signale
	if block_canvas_container:
		block_canvas_container.view_all_pressed.connect(_view_all_blocks)
		block_canvas_container.reset_canvas_pressed.connect(_on_reset_canvas_pressed)
	
	# GameViewContainer Signale (Run/Reset Buttons)
	if game_view_container:
		game_view_container.run_pressed.connect(_run_interpreter)
		game_view_container.reset_pressed.connect(_reset_character)

## Handler für Canvas-Reset.
func _on_reset_canvas_pressed():
	print("[UI] Canvas zurückgesetzt")


## Zeigt alle Blöcke an (passt Zoom an).
func _view_all_blocks():
	if not block_container or not canvas_camera:
		return
	
	var bounds: Rect2 = Rect2()
	var first = true
	
	for child in block_container.get_children():
		if child is DraggableBlock:
			var block = child as DraggableBlock
			var block_rect = Rect2(block.global_position, block.size)
			
			if first:
				bounds = block_rect
				first = false
			else:
				bounds = bounds.merge(block_rect)
	
	if not first:
		canvas_camera.fit_to_rect(bounds)
		print("[UI] Zeige alle Blöcke: %s" % bounds)
	else:
		print("[UI] Keine Blöcke gefunden")

## Setzt den Character zur Startposition zurück.
func _reset_character():
	# Stoppe laufende Ausführung
	if _executor and _executor.is_running():
		_executor.stop()
		print("[UI] Ausführung gestoppt")
	
	# Setze Character zurück
	if character_node:
		character_node.reset_to_start(_character_start_position)
	
	# Aktualisiere UI
	_update_execution_status("Ready")
	_update_current_action("-")
	if game_view_container:
		game_view_container.set_run_button_enabled(true)
	print("[UI] Character zurückgesetzt")

## Verarbeitet Eingaben für Code-Ausführung.
##
## @param event: Das Input-Event
func _input(event: InputEvent):
	# Run/Interpret Program
	if event.is_action_pressed("run_code"):
		_run_interpreter()
		get_viewport().set_input_as_handled()

## Initialisiert den BlockInterpreter.
func _setup_interpreter():
	_interpreter = BlockInterpreter.new()
	_interpreter.interpretation_started.connect(_on_interpretation_started)
	_interpreter.interpretation_completed.connect(_on_interpretation_completed)
	_interpreter.interpretation_error.connect(_on_interpretation_error)
	print("[UI] Interpreter initialisiert")

## Initialisiert den CharacterExecutor.
func _setup_executor():
	_executor = CharacterExecutor.new()
	_executor.execution_started.connect(_on_execution_started)
	_executor.execution_completed.connect(_on_execution_completed)
	_executor.execution_stopped.connect(_on_execution_stopped)
	_executor.execution_step.connect(_on_execution_step)
	_executor.execution_error.connect(_on_execution_error)
	
	if character_node:
		_executor.initialize(character_node)
		print("[UI] Executor initialisiert mit Character")
	else:
		print("[UI] Executor initialisiert (kein Character zugewiesen)")

## Verbindet die Signale des LevelLoaders.
func _connect_level_loader_signals():
	if not level_loader:
		push_error("[UI] LevelLoader-Node nicht gefunden!")
		return
	
	# Verbinde Signals
	level_loader.level_loaded.connect(_on_level_loaded)
	level_loader.block_spawned.connect(_on_block_spawned)
	level_loader.block_deleted.connect(_on_block_deleted)
	level_loader.block_limit_reached.connect(_on_block_limit_reached)
	
	print("[UI] Mit LevelLoader-Signalen verbunden")

## Lädt das initiale Level.
func _load_initial_level():
	if level_loader:
		print("[UI] Lade initiales Level: %s" % default_level_path)
		load_level(default_level_path)

## Lädt ein Level aus einer Datei.
##
## @param level_path: Pfad zur Level-Datei
## @return: true bei Erfolg
func load_level(level_path: String) -> bool:
	if not level_loader:
		push_error("[UI] LevelLoader nicht initialisiert!")
		return false
	
	var success = level_loader.load_level(level_path)
	
	if success:
		current_level = level_loader.current_level
		print("[UI] Level erfolgreich geladen: %s" % current_level.level_name)
	else:
		push_error("[UI] Konnte Level nicht laden: %s" % level_path)
	
	return success

## Lädt das nächste Level (zyklisch durch alle verfügbaren Levels).
func load_next_level():
	var levels = LevelLoader.get_available_levels()
	if levels.is_empty():
		print("[UI] Keine Levels gefunden!")
		return
	
	var current_index = levels.find(default_level_path)
	var next_index = (current_index + 1) % levels.size()
	default_level_path = levels[next_index]
	
	load_level(default_level_path)

## Lädt das Level neu.
func reload_level():
	if default_level_path != "":
		load_level(default_level_path)
	else:
		push_error("[UI] Kein Level zum Neuladen vorhanden!")


## Handler für level_loaded Signal.
##
## @param level_data: Die geladenen Level-Daten
func _on_level_loaded(level_data: LevelData):
	print("[UI] Level-Event: Geladen - %s" % level_data.level_name)
	_update_level_details(level_data)
	_reset_character()

## Aktualisiert die Level-Details-Anzeige.
##
## @param level_data: Die Level-Daten
func _update_level_details(level_data: LevelData):
	if level_details_container:
		level_details_container.set_level_name(level_data.level_name)
		# Zeige erstes Goal an oder Beschreibung wenn keine Goals vorhanden
		if level_data.goals.size() > 0:
			level_details_container.set_level_goal(level_data.goals[0])
		else:
			level_details_container.set_level_goal(level_data.level_description)
	_update_execution_status("Ready")
	_update_current_action("-")

## Aktualisiert den Ausführungsstatus.
##
## @param status: Der neue Status
func _update_execution_status(status: String):
	if level_details_container:
		level_details_container.set_execution_status(status)

## Aktualisiert die aktuelle Aktion.
##
## @param action: Die aktuelle Aktion
func _update_current_action(action: String):
	if level_details_container:
		level_details_container.set_current_action(action)

## Handler für block_spawned Signal.
##
## @param block: Der gespawnte Block
func _on_block_spawned(block: DraggableBlock):
	print("[UI] Block gespawnt: %s" % block.block_name)

## Handler für block_deleted Signal.
##
## @param block: Der gelöschte Block
func _on_block_deleted(block: DraggableBlock):
	if block and is_instance_valid(block):
		print("[UI] Block gelöscht: %s" % block.block_name)
	else:
		print("[UI] Block gelöscht (ungültige Referenz)")

## Handler für block_limit_reached Signal.
##
## @param block_type: Der Block-Typ dessen Limit erreicht wurde
func _on_block_limit_reached(block_type: String):
	print("[UI] Block-Limit erreicht: %s" % block_type)


## Führt den Interpreter aus.
func _run_interpreter():
	if not _interpreter:
		push_error("[UI] Interpreter nicht initialisiert!")
		return
	
	# Finde das Program Block
	var program_block: DraggableBlock = null
	
	if block_container:
		for child in block_container.get_children():
			if child is DraggableBlock:
				var block = child as DraggableBlock
				# Prüfe auf Program Block (über Name oder Class)
				if block is ProgramBlock or block.block_name == "Program":
					program_block = block
					break
	
	if not program_block:
		push_error("[UI] Kein Program Block gefunden!")
		return
	
	print("\n[UI] ========================================")
	print("[UI] === RUNNING INTERPRETER (run_code) ===")
	print("[UI] ========================================\n")
	
	# Interpretiere das Programm
	var instructions = _interpreter.interpret(program_block)
	
	# Gebe den generierten Code aus
	if instructions.size() > 0:
		var generated_code = _interpreter.generate_code(instructions)
		print("\n[UI] === GENERATED CODE ===")
		print(generated_code)
		print("[UI] ========================================\n")
		
		# Führe das Programm auf dem Character aus (wenn vorhanden)
		if character_node and _executor:
			print("[UI] Starte Programmausführung auf Character...")
			_executor.execute(instructions)
	else:
		print("[UI] Keine Instruktionen gefunden (Programm ist leer)\n")

## Handler für interpretation_started Signal.
func _on_interpretation_started():
	print("[UI] Interpretation gestartet...")

## Handler für interpretation_completed Signal.
##
## @param instructions: Array der generierten Instructions
func _on_interpretation_completed(instructions: Array):
	print("[UI] Interpretation abgeschlossen! Gesamt: %d Instructions" % instructions.size())

## Handler für interpretation_error Signal.
##
## @param error_message: Die Fehlermeldung
func _on_interpretation_error(error_message: String):
	push_error("[UI] Interpretation Fehler: %s" % error_message)


## Handler für execution_started Signal.
func _on_execution_started():
	print("[UI] Programmausführung gestartet...")
	_update_execution_status("Running...")
	if game_view_container:
		game_view_container.set_run_button_enabled(false)

## Handler für execution_completed Signal.
func _on_execution_completed():
	print("[UI] Programmausführung abgeschlossen!")
	_update_execution_status("Completed")
	_update_current_action("-")
	if game_view_container:
		game_view_container.set_run_button_enabled(true)

## Handler für execution_stopped Signal.
func _on_execution_stopped():
	print("[UI] Programmausführung gestoppt!")
	_update_execution_status("Stopped")
	_update_current_action("-")
	if game_view_container:
		game_view_container.set_run_button_enabled(true)

## Handler für execution_step Signal.
##
## @param instruction_name: Name der aktuellen Instruktion
func _on_execution_step(instruction_name: String):
	print("[UI] Ausführe: %s" % instruction_name)
	_update_current_action(instruction_name)

## Handler für execution_error Signal.
##
## @param error_message: Die Fehlermeldung
func _on_execution_error(error_message: String):
	push_error("[UI] Ausführungsfehler: %s" % error_message)
	_update_execution_status("Error!")
	if game_view_container:
		game_view_container.set_run_button_enabled(true)

## Führt das Programm auf dem Character aus.
func run_program():
	if not _interpreter:
		push_error("[UI] Interpreter nicht initialisiert!")
		return
	
	if not _executor:
		push_error("[UI] Executor nicht initialisiert!")
		return
	
	if not character_node:
		push_warning("[UI] Kein Character zugewiesen - nur Code-Ausgabe")
	
	# Finde das Program Block
	var program_block: DraggableBlock = null
	
	if block_container:
		for child in block_container.get_children():
			if child is DraggableBlock:
				var block = child as DraggableBlock
				if block is ProgramBlock or block.block_name == "Program":
					program_block = block
					break
	
	if not program_block:
		push_error("[UI] Kein Program Block gefunden!")
		return
	
	var instructions = _interpreter.interpret(program_block)
	
	if instructions.size() > 0 and character_node:
		_executor.execute(instructions)

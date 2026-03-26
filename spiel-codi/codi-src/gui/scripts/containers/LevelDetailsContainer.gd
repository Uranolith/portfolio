## Zeigt Details zum aktuellen Level an.
##
## Enthält Level-Name, Ziel, Status, aktuelle Aktion, verfügbare Blöcke und Hints.
## Dynamische Sichtbarkeit der Blöcke basierend auf der Höhe des Containers.
extends PanelContainer
class_name LevelDetailsContainer

@export_group("Header")
## Button zum Anzeigen/Verstecken der Hints
@export var show_hints_button: Button

@export_group("Labels")
## Label für den Level-Namen
@export var level_name_label: Label

## Label für das Level-Ziel
@export var level_goal_label: Label

## Label für den Ausführungsstatus
@export var execution_status_label: Label

## Label für die aktuelle Aktion
@export var current_action_label: Label

@export_group("Dynamic Sections")
## Container für Blöcke und Hints
@export var blocks_and_hints_container: Control

## Separator zwischen Blöcken und Hints
@export var blocks_and_hints_separator: HSeparator

## Sektion für Blöcke
@export var blocks_section: VBoxContainer

## Titel für Blöcke
@export var blocks_title: Label

## Liste der Blöcke
@export var blocks_list: VBoxContainer

## Sektion für Hints
@export var hints_section: VBoxContainer

## Titel für Hints
@export var hints_title: Label

## Liste der Hints
@export var hints_list: VBoxContainer

## Signal wird gesendet wenn "Show Hints" gedrückt wird
signal show_hints_pressed()

## Ob Hints sichtbar sind
var _hints_visible: bool = false

## Referenz zum LevelLoader
var _level_loader: LevelLoader = null

## Aktuelle Hints
var _current_hints: Array = []

## Block-Counter Dictionary
var _block_counters: Dictionary = {}

## Minimale Höhe ab der Blöcke angezeigt werden
const MIN_HEIGHT_FOR_BLOCKS: float = 265.0

## Initialisiert den Container.
func _ready():
	_connect_buttons()
	_update_hints_visibility()
	call_deferred("_connect_to_level_loader")
	
	resized.connect(_on_resized)
	_update_dynamic_sections()

## Verbindet die Button-Signale.
func _connect_buttons():
	if show_hints_button:
		show_hints_button.pressed.connect(_on_show_hints_pressed)

## Verbindet mit dem LevelLoader.
func _connect_to_level_loader():
	var loaders = get_tree().get_nodes_in_group("level_loader")
	if loaders.size() > 0:
		_level_loader = loaders[0] as LevelLoader
		if _level_loader:
			_level_loader.level_loaded.connect(_on_level_loaded)
			_level_loader.block_spawned.connect(_on_block_changed)
			_level_loader.block_deleted.connect(_on_block_changed)
			
			if _level_loader.current_level:
				_on_level_loaded(_level_loader.current_level)

## Handler für "Show Hints" Button.
func _on_show_hints_pressed():
	_hints_visible = not _hints_visible
	_update_hints_visibility()
	_update_dynamic_sections()
	show_hints_pressed.emit()

## Aktualisiert die Hints-Sichtbarkeit.
func _update_hints_visibility():
	if hints_section:
		hints_section.visible = _hints_visible
	if show_hints_button:
		show_hints_button.text = "▼" if _hints_visible else "?"
		show_hints_button.tooltip_text = "Hide Hints" if _hints_visible else "Show Hints"

## Handler für Level geladen.
##
## @param level_data: Die geladenen Level-Daten
func _on_level_loaded(level_data: LevelData):
	_current_hints = level_data.hints
	_update_hints_list()
	_update_block_counters()

## Handler für Block-Änderungen.
##
## @param _block: Der geänderte Block (nicht verwendet)
func _on_block_changed(_block):
	call_deferred("_update_block_counters")

## Handler für Container-Resize.
func _on_resized():
	call_deferred("_update_dynamic_sections")

## Aktualisiert die dynamischen Sektionen basierend auf der Höhe.
##
## KERNLOGIK: Höhen-basierte Sichtbarkeit.
func _update_dynamic_sections():
	var available_height = size.y
	var height_sufficient = available_height >= MIN_HEIGHT_FOR_BLOCKS
	
	var show_container = height_sufficient or _hints_visible
	
	if blocks_and_hints_container:
		blocks_and_hints_container.visible = show_container
	if blocks_section:
		blocks_section.visible = show_container
	if blocks_and_hints_separator:
		blocks_and_hints_separator.visible = show_container

## Wendet Text-Styling von einem Label auf ein anderes an.
##
## @param target_label: Das Ziel-Label
## @param source_label: Das Quell-Label
## @param custom_color: Optionale benutzerdefinierte Farbe
func _apply_text_style(target_label: Label, source_label: Label, custom_color: Color = Color.WHITE):
	print("[_apply_text_style] source_label: ", source_label)
	if not source_label:
		print("[_apply_text_style] source_label ist NULL!")
		if custom_color != Color.WHITE:
			target_label.add_theme_color_override("font_color", custom_color)
		return
		
	# Kopiere label_settings wenn vorhanden
	if source_label.label_settings:
		var new_settings = LabelSettings.new()
		new_settings = source_label.label_settings.duplicate()
		
		# Setze die Farbe
		if custom_color != Color.WHITE:
			new_settings.font_color = custom_color
		else:
			new_settings.font_color = source_label.label_settings.font_color
		
		target_label.label_settings = new_settings
	else:
		var font_size = source_label.get_theme_font_size("font_size")
		target_label.add_theme_font_size_override("font_size", font_size)
		
		if source_label.has_theme_font_override("font"):
			target_label.add_theme_font_override("font", source_label.get_theme_font("font"))
		
		if custom_color != Color.WHITE:
			target_label.add_theme_color_override("font_color", custom_color)

## Aktualisiert die Hints-Liste.
func _update_hints_list():
	if not hints_list:
		return
	
	for child in hints_list.get_children():
		child.queue_free()
	
	var style_source = hints_title if hints_title else blocks_title
	
	for hint in _current_hints:
		var hint_container = HBoxContainer.new()
		hint_container.add_theme_constant_override("separation", 4)
		
		var bullet_label = Label.new()
		bullet_label.text = "•"
		bullet_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		
		var text_label = Label.new()
		text_label.text = hint
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		
		# Style anwenden (Gelb)
		var yellow = Color(1.0, 0.9, 0.4)
		_apply_text_style(bullet_label, style_source, yellow)
		_apply_text_style(text_label, style_source, yellow)
		
		hint_container.add_child(bullet_label)
		hint_container.add_child(text_label)
		hints_list.add_child(hint_container)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL 
	spacer.custom_minimum_size.y = 3.0
	hints_list.add_child(spacer)

## Aktualisiert die Block-Counter Anzeige.
func _update_block_counters():
	if not blocks_list or not _level_loader:
		return
	
	for child in blocks_list.get_children():
		child.queue_free()
	
	_block_counters.clear()
	
	if not _level_loader.remaining_blocks:
		return
	
	for block_type in _level_loader.remaining_blocks.keys():
		var spawn_limit = _level_loader.remaining_blocks[block_type]
		var can_still_spawn = _level_loader.get_remaining_blocks(block_type)
		var current_count = _level_loader._count_blocks_of_type(block_type)
		
		var block_label = Label.new()
		
		if spawn_limit == -1:
			block_label.text = "• %s: %d (∞)" % [
				_get_block_display_name(block_type),
				current_count
			]
		else:
			block_label.text = "• %s: %d / %d" % [
				_get_block_display_name(block_type),
				current_count,
				spawn_limit
			]
		
		var target_color = Color(1, 1, 1, 1)
		if spawn_limit != -1 and can_still_spawn <= 0:
			target_color = Color(0.8, 0.3, 0.3)
		elif spawn_limit != -1 and can_still_spawn <= 2:
			target_color = Color(0.8, 0.6, 0.2)
			
		_apply_text_style(block_label, blocks_title, target_color)
		
		blocks_list.add_child(block_label)
		_block_counters[block_type] = block_label

## Setzt den Level-Namen.
##
## @param level_name: Der Level-Name
func set_level_name(level_name: String):
	if level_name_label: level_name_label.text = "Level: %s" % level_name

## Setzt das Level-Ziel.
##
## @param goal: Das Ziel
func set_level_goal(goal: String):
	if level_goal_label: level_goal_label.text = "Goal: %s" % goal

## Setzt den Ausführungsstatus.
##
## @param status: Der Status
func set_execution_status(status: String):
	if execution_status_label: execution_status_label.text = "Status: %s" % status

## Setzt die aktuelle Aktion.
##
## @param action: Die Aktion
func set_current_action(action: String):
	if current_action_label: current_action_label.text = "Action: %s" % action

## Setzt die Hints.
##
## @param hints: Array der Hints
func set_hints(hints: Array):
	_current_hints = hints
	_update_hints_list()

## Gibt den Anzeigenamen für einen Block-Typ zurück.
##
## @param block_type: Der Block-Typ
## @return: Der Anzeigename
func _get_block_display_name(block_type: String) -> String:
	match block_type:
		"base": return "Instructions"
		"condition": return "Conditions"
		"case_distinction": return "If/Else"
		"loop": return "Loops"
		"program": return "Program"
		_: return block_type.capitalize()

## Condition-Block für Bedingungen und Zählschleifen.
##
## Repräsentiert Bedingungen wie "Can Move Forward" oder Wiederholungen wie "Repeat X Times".
## Kann in Loop- und Case-Distinction-Blöcken verwendet werden.
## Unterstützt Wert-Eingabe für bestimmte Condition-Typen (z.B. REPEAT_COUNT).
class_name ConditionBlock
extends DraggableBlock

## LineEdit für die Wert-Eingabe (nur bei bestimmten Conditions sichtbar)
@export var value_input_line_edit: LineEdit

## Label zur Anzeige des aktuellen Werts
@export var value_display_label: Label

@onready var value_input: LineEdit = value_input_line_edit
@onready var value_display: Label = value_display_label

## Referenz zum Container, in dem dieser Condition-Block platziert ist
var condition_parent = null

## Condition-Type dieses Blocks (z.B. CAN_MOVE_FORWARD, REPEAT_COUNT)
var condition_type: ConditionBlockData.ConditionType = ConditionBlockData.ConditionType.CAN_MOVE_FORWARD

# Doppelklick-Erkennung für ValueInput
var _last_click_time: int = 0
const DOUBLE_CLICK_MS: int = 200
var _is_editing_value: bool = false

func _ready():
	snap_category = SnapCategory.CONDITION
	
	indicator_top_accepts = []
	indicator_bottom_accepts = []
	
	super._ready()
	
	# Synchronisiere condition_type aus BlockData
	if data and data is ConditionBlockData:
		condition_type = data.condition_type
	_update_block_name_for_condition()
	
	# Warte einen Frame für @onready Initialisierung
	await get_tree().process_frame
	
	# Konfiguriere ValueInput für Doppelklick-Bearbeitung
	_setup_value_input_double_click()

## Konfiguriert ValueInput für Doppelklick-Bearbeitung.
##
## Richtet die Signalverbindungen und initial-Sichtbarkeit ein.
func _setup_value_input_double_click():
	# Deaktiviere globalen Input-Handler initial
	set_process_input(false)
	
	# LineEdit ist standardmäßig versteckt
	if value_input:
		value_input.visible = false
		# Verbinde Signale für Beenden der Bearbeitung
		if not value_input.focus_exited.is_connected(_on_value_input_focus_exited):
			value_input.focus_exited.connect(_on_value_input_focus_exited)
		if not value_input.text_submitted.is_connected(_on_value_input_submitted):
			value_input.text_submitted.connect(_on_value_input_submitted)
	
	# Value-Display Label initialisieren (zeigt Wert wenn nicht editiert wird)
	_update_value_display()

## Aktiviert die Bearbeitung des ValueInput.
##
## Zeigt das LineEdit-Feld und setzt den Fokus darauf.
func _enable_value_input_editing():
	if not value_input:
		return
	_is_editing_value = true
	
	# Verstecke Value-Display Label und zeige Value-Input
	if value_display:
		value_display.visible = false
	
	value_input.visible = true
	value_input.text = str(data.value) if data and data is ConditionBlockData else "0"
	value_input.grab_focus()
	value_input.select_all()
	# Aktiviere globalen Input-Handler
	set_process_input(true)

## Deaktiviert die Bearbeitung des ValueInput.
##
## Übernimmt den eingegebenen Wert und versteckt das LineEdit-Feld.
func _disable_value_input_editing():
	if not value_input:
		return
	if not _is_editing_value:
		return
	_is_editing_value = false
	
	# Deaktiviere globalen Input-Handler
	set_process_input(false)
	
	# Wert übernehmen
	if value_input.text.is_valid_int() and data and data is ConditionBlockData:
		data.value = value_input.text.to_int()
	
	value_input.release_focus()
	value_input.visible = false
	
	# Zeige Value-Display Label wieder und aktualisiere es
	_update_value_display()
	
	_last_click_time = 0

## Aktualisiert das Value-Display Label.
##
## Zeigt den aktuellen Wert an, wenn der Condition-Typ einen Wert benötigt.
func _update_value_display():
	if not value_display:
		return
	
	# Prüfe ob dieser Condition-Typ einen Wert benötigt
	var needs_val = false
	if data and data is ConditionBlockData:
		needs_val = ConditionBlockData.needs_value(data.condition_type)
		value_display.text = str(data.value)
	else:
		value_display.text = "0"
	
	# Zeige Value-Display nur wenn Wert benötigt wird und nicht gerade editiert wird
	value_display.visible = needs_val and not _is_editing_value

## Globaler Input-Handler für Klick außerhalb des Value-Inputs.
##
## Beendet die Bearbeitung wenn außerhalb des LineEdit-Felds geklickt wird.
func _input(event: InputEvent):
	if not _is_editing_value:
		return
	
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			# Prüfe ob Klick außerhalb des ValueInput war
			if value_input and value_input.visible:
				var global_rect = value_input.get_global_rect()
				if not global_rect.has_point(mouse_event.global_position):
					# Klick außerhalb - Bearbeitung beenden
					_disable_value_input_editing()

## Callback wenn ValueInput Focus verliert.
func _on_value_input_focus_exited():
	call_deferred("_disable_value_input_editing")

## Callback wenn Enter im ValueInput gedrückt wird.
func _on_value_input_submitted(_new_text: String):
	_disable_value_input_editing()

## Prüft ob ein Punkt innerhalb des Value-Display-Labels liegt.
##
## Wird für Doppelklick-Erkennung auf dem Wert verwendet.
##
## @param local_point: Der lokale Punkt relativ zum Block
## @return: true wenn der Punkt im Value-Bereich liegt
func _is_point_in_value_area(local_point: Vector2) -> bool:
	# Prüfe nur wenn Block einen Wert braucht
	if not data or not data is ConditionBlockData:
		return false
	if not ConditionBlockData.needs_value(data.condition_type):
		return false
	
	# Prüfe ob Klick auf value_display war (nur wenn nicht gerade editiert wird)
	if not _is_editing_value and value_display and value_display.visible:
		var label_rect = value_display.get_rect()
		return label_rect.has_point(local_point)
	
	return false

## Überschreibt _gui_input für Doppelklick-Erkennung auf Value-Display.
##
## Ermöglicht Doppelklick auf den Wert zur Bearbeitung.
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			# Prüfe ob Klick auf ValueDisplay war
			var local_pos = mouse_event.position
			if _is_point_in_value_area(local_pos):
				var current_time = Time.get_ticks_msec()
				if current_time - _last_click_time < DOUBLE_CLICK_MS:
					# Doppelklick erkannt!
					_enable_value_input_editing()
					accept_event()
					return
				_last_click_time = current_time
	
	# Wichtig: Rufe parent _gui_input auf für Drag-Funktionalität
	super._gui_input(event)

## Synchronisiert Daten von BlockData zur visuellen Darstellung.
func _sync_from_data():
	super._sync_from_data()
	if data and data is ConditionBlockData:
		condition_type = data.condition_type
		_update_block_name_for_condition()
		
		# Zeige/Verstecke Value-Input basierend auf Condition-Typ und Edit-Modus
		var needs_val = ConditionBlockData.needs_value(data.condition_type)
		if value_input:
			value_input.visible = needs_val and _is_editing_value
			value_input.text = str(data.value)
		
		# Value-Display Label aktualisieren
		_update_value_display()

## Setzt den Condition-Type und aktualisiert den Block-Namen.
##
## @param new_condition_type: Der neue ConditionType
func set_condition_type(new_condition_type: ConditionBlockData.ConditionType):
	condition_type = new_condition_type
	if data and data is ConditionBlockData:
		data.condition_type = new_condition_type
	_update_block_name_for_condition()

## Gibt den aktuellen Condition-Type zurück.
##
## @return: Der ConditionType dieses Blocks
func get_condition_type() -> ConditionBlockData.ConditionType:
	return condition_type

## Aktualisiert den Block-Namen basierend auf dem Condition-Type.
func _update_block_name_for_condition():
	var condition_name = ConditionBlockData.get_display_name(condition_type)
	if condition_name != "":
		set_block_name(condition_name)

## Überschreibt Basis-Implementierung für ConditionBlockData.
func _init_default_data():
	data = ConditionBlockData.new()
	data.block_type = BlockData.BlockType.CONDITION
	data.block_id = _generate_block_id()
	data.position = global_position
	data.condition_type = ConditionBlockData.ConditionType.CAN_MOVE_FORWARD
	data.value = 0

## Condition-Blöcke zeigen das Standard Block-Name-Label.
##
## @return: Immer true
func _should_show_block_name_label() -> bool:
	return true

func _process(_delta):
	if not is_inside_tree():
		return
	
	if not data or not data is ConditionBlockData:
		return
	
	var cond_data = data as ConditionBlockData
	var needs_val = ConditionBlockData.needs_value(cond_data.condition_type)
	
	# Synchronisiere Value-Input zu BlockData wenn gerade editiert wird
	if value_input and _is_editing_value:
		if value_input.text.is_valid_int():
			cond_data.value = value_input.text.to_int()
	
	# Zeige/Verstecke Value-Input basierend auf Condition-Typ
	if value_input:
		value_input.visible = needs_val and _is_editing_value
	
	# Zeige/Verstecke Value-Display Label
	if value_display:
		value_display.visible = needs_val and not _is_editing_value
		if value_display.visible:
			value_display.text = str(cond_data.value)


## Extrahiert ConditionBlockData aus diesem Block.
##
## @return: Die BlockData dieses Blocks
func to_block_data() -> BlockData:
	_sync_to_data()
	
	if data and data is ConditionBlockData:
		var cond_data = data.duplicate_data() as ConditionBlockData
		return cond_data
	
	# Fallback
	return ConditionBlockData.new()

## Synchronisiert BlockData von UI (überschreibt Basis).
func _sync_to_data():
	if not data:
		return
	
	# Basis-Synchronisation
	data.position = global_position
	
	if not data is ConditionBlockData:
		return

## Factory-Methode: Erstellt ConditionBlock aus ConditionBlockData.
##
## @param block_data: Die BlockData mit der Konfiguration
## @param block_scene: Die PackedScene für den Block
## @return: Der erstellte ConditionBlock oder null bei Fehler
static func create_from_data(block_data: BlockData, block_scene: PackedScene) -> ConditionBlock:
	if not block_scene:
		push_error("[ConditionBlock] create_from_data: Kein block_scene übergeben")
		return null
	
	var block = block_scene.instantiate() as ConditionBlock
	if not block:
		push_error("[ConditionBlock] create_from_data: Konnte Block nicht instanziieren")
		return null
	
	block.data = block_data
	return block

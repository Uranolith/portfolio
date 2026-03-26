extends CanvasLayer

var panel: Panel = null
var content_label: RichTextLabel = null
var hint_label: Label = null
var f1_pressed_last_frame: bool = false

func _ready():
	layer = 9999
	
	panel = Panel.new()
	panel.position = Vector2(10, 10)
	panel.custom_minimum_size = Vector2(300, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.visible = false
	add_child(panel)
	
	var stylebox = panel.get_theme_stylebox("panel")
	if stylebox is StyleBoxFlat:
		var new_stylebox = stylebox.duplicate() as StyleBoxFlat
		new_stylebox.bg_color = Color.from_rgba8(0, 0, 0, 185)
		panel.add_theme_stylebox_override("panel", new_stylebox)
	
	content_label = RichTextLabel.new()
	content_label.bbcode_enabled = true
	content_label.fit_content = true
	content_label.scroll_following = false
	content_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	content_label.custom_minimum_size = Vector2(290, 0)
	content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	content_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var mono_font_res = null
	if ResourceLoader.exists("res://blocks/blocks_font.tres"):
		mono_font_res = load("res://blocks/blocks_font.tres")
	if mono_font_res:
		if mono_font_res is Font:
			content_label.add_theme_font_override("normal_font", mono_font_res)
		elif mono_font_res is LabelSettings and mono_font_res.font:
			content_label.add_theme_font_override("normal_font", mono_font_res.font)
	
	content_label.add_theme_font_size_override("normal_font_size", 11)
	content_label.add_theme_font_size_override("bold_font_size", 13)
	content_label.add_theme_constant_override("line_separation", 1)
	
	content_label.set_tab_stops([140.0])
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel.add_child(margin)
	margin.add_child(content_label)
	
	hint_label = Label.new()
	hint_label.text = "F1: Hotkey Guide"
	hint_label.position = Vector2(10, 10)
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.add_theme_color_override("font_color", Color(1, 0.9, 0.2, 0.95))
	hint_label.modulate = Color(1, 1, 1, 1)
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_label.visible = true
	add_child(hint_label)
	
	_update_content()
	
	await get_tree().process_frame
	_resize_panel()

func _process(_delta):
	if Input.is_action_just_pressed("close_overlays"):
		if panel.visible:
			panel.visible = false
			if hint_label:
				hint_label.visible = true
	
	var f1_pressed = Input.is_action_pressed("toggle_hotkey_guide")
	if f1_pressed and !f1_pressed_last_frame:
		panel.visible = not panel.visible
		if hint_label:
			hint_label.visible = not panel.visible
	f1_pressed_last_frame = f1_pressed

func _resize_panel():
	if not content_label or not panel:
		return
	
	await get_tree().process_frame
	
	var content_height = max(0, content_label.get_content_height())
	var content_width = max(0, content_label.get_content_width())
	
	var new_width = max(300, content_width + 10)
	var new_height = max(100, content_height + 10)
	
	panel.custom_minimum_size = Vector2(new_width, new_height)
	panel.size = panel.custom_minimum_size

func _update_content():
	if not content_label:
		return
	
	var text = "[center][b]HOTKEY GUIDE[/b][/center]\n\n"
	
	text += _format_action_line("toggle_hotkey_guide", "Hotkey Guide (Toggle)")
	text += _format_action_line("close_overlays", "Close Overlays")
	text += "\n"
	
	text += _format_action_line("block_move", "Move Single")
	text += _format_action_line("block_move_chain", "Move Block + Chain")
	text += "\n"
	
	text += _format_action_line("canvas_pan", "Pan Canvas")
	text += _format_action_line("canvas_zoom_in", "Zoom Canvas In")
	text += _format_action_line("canvas_zoom_out", "Zoom Canvas Out")
	text += "\n"
	
	text += _format_action_line("block_create_menu", "Create New Block")
	text += _format_action_line("block_select", "Select Block")
	text += _format_action_line("block_delete", "Delete Block")
	text += "\n"
	
	text += "[color=#888888]Protected Blocks: Red Border[/color]\n"
	text += "[color=#888888]Unprotected Blocks: White Border[/color]"
	
	content_label.text = text
	
	if panel and panel.visible:
		_resize_panel()

# Formatiert eine Input Action als Zeile im Hotkey Guide
# action_name: Name der Input Action (z.B. "toggle_hotkey_guide")
# description: Beschreibung der Aktion (z.B. "Hotkey Guide (Toggle)")
func _format_action_line(action_name: String, description: String) -> String:
	var keys = _get_action_display_name(action_name)
	if keys.is_empty():
		return ""
	
	var is_move_action = action_name in ["block_move", "block_move_chain", "canvas_pan"]
	if is_move_action:
		if "LMB" in keys:
			keys = keys.replace("LMB", "LMB (hold) + move")
		if "RMB" in keys:
			keys = keys.replace("RMB", "RMB (hold) + move")
		if "MMB" in keys:
			keys = keys.replace("MMB", "MMB (hold) + move")
	
	return "[color=#88AAFF]" + keys + "[/color]\t[color=#CCCCCC]" + description + "[/color]\n"

# Gibt einen lesbaren String für eine Input Action zurück
# Kombiniert mehrere Eingaben mit " / " (z.B. "Ctrl+A / Ctrl+RMB")
func _get_action_display_name(action_name: String) -> String:
	if not InputMap.has_action(action_name):
		return "[Not Configured]"
	
	var events = InputMap.action_get_events(action_name)
	if events.is_empty():
		return "[Not Configured]"
	
	var display_names = []
	for event in events:
		var display_name = _get_event_display_name(event)
		if not display_name.is_empty():
			display_names.append(display_name)
	
	if display_names.is_empty():
		return "[Unknown]"
	
	return " / ".join(display_names)

# Konvertiert ein InputEvent zu einem lesbaren String
func _get_event_display_name(event: InputEvent) -> String:
	if event is InputEventKey:
		return _get_key_display_name(event)
	elif event is InputEventMouseButton:
		return _get_mouse_button_display_name(event)
	else:
		return ""

# Gibt einen lesbaren String für ein Tastatur-Event zurück
# Berücksichtigt Modifier (Ctrl, Shift, Alt)
func _get_key_display_name(event: InputEventKey) -> String:
	var parts = []
	
	# Modifier hinzufügen
	if event.ctrl_pressed or event.command_or_control_autoremap:
		parts.append("Ctrl")
	if event.shift_pressed:
		parts.append("Shift")
	if event.alt_pressed:
		parts.append("Alt")
	if event.meta_pressed:
		parts.append("Meta")
	
	# Tastenname hinzufügen
	var key_name = OS.get_keycode_string(event.physical_keycode)
	if key_name.is_empty():
		key_name = OS.get_keycode_string(event.keycode)
	
	if not key_name.is_empty():
		parts.append(key_name)
	
	return "+".join(parts)

# Gibt einen lesbaren String für ein Maus-Button-Event zurück
# Berücksichtigt Modifier (Ctrl, Shift, Alt) und Maus-Aktionen
func _get_mouse_button_display_name(event: InputEventMouseButton) -> String:
	var parts = []
	
	# Modifier hinzufügen
	if event.ctrl_pressed:
		parts.append("Ctrl")
	if event.shift_pressed:
		parts.append("Shift")
	if event.alt_pressed:
		parts.append("Alt")
	
	# Maus-Button-Namen
	var button_name = ""
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			button_name = "LMB"
		MOUSE_BUTTON_RIGHT:
			button_name = "RMB"
		MOUSE_BUTTON_MIDDLE:
			button_name = "MMB"
		MOUSE_BUTTON_WHEEL_UP:
			button_name = "Mouse Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN:
			button_name = "Mouse Wheel Down"
		MOUSE_BUTTON_XBUTTON1:
			button_name = "Mouse X1"
		MOUSE_BUTTON_XBUTTON2:
			button_name = "Mouse X2"
		_:
			button_name = "Mouse Button " + str(event.button_index)
	
	parts.append(button_name)
	
	return "+".join(parts) if parts.size() > 1 else button_name

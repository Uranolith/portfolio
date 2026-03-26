## Camera2D Zoom und Pan Controller für Block-Canvas SubViewport.
##
## Nutzt die eingebauten Camera2D-Funktionen für Zoom und Position.
## Pan wird über die Input-Action "canvas_pan" gesteuert.
extends Camera2D

## Minimaler Zoom-Level
@export var min_zoom_level: float = 0.3

## Maximaler Zoom-Level
@export var max_zoom_level: float = 2.0

## Zoom-Schrittweite
@export var zoom_step: float = 0.1

## Geschwindigkeit für sanftes Zoomen
@export var zoom_smooth_speed: float = 15.0

## Canvas-Dimensionen (die Größe des virtuellen Arbeitsbereichs)
@export var canvas_size: Vector2 = Vector2(2000, 2000)

## Ziel-Zoom-Level
var target_zoom: float = 1.0

## Ziel-Position der Kamera
var target_position: Vector2 = Vector2.ZERO

## Ob gerade gezoomt wird
var is_zooming: bool = false

## Mausposition beim Zoomen
var zoom_mouse_pos: Vector2 = Vector2.ZERO

## Ob gerade gepannt wird
var is_panning: bool = false

## Startposition beim Pannen
var pan_start_position: Vector2 = Vector2.ZERO

## Kamera-Startposition beim Pannen
var camera_pan_start: Vector2 = Vector2.ZERO

## Gecachte Viewport-Größe
var _viewport_size: Vector2 = Vector2(800, 600)

## Dynamisch berechneter minimaler Zoom (Canvas muss Viewport ausfüllen)
var _effective_min_zoom: float = 0.3

## Signal wird gesendet wenn Program-Block gesucht werden soll
signal find_program_requested()

## Signal wird gesendet wenn alle Blöcke angezeigt werden sollen
signal view_all_requested()

## Signal wird gesendet wenn Canvas zurückgesetzt werden soll
signal reset_canvas_requested()

## Initialisiert die Kamera.
##
## Setzt die Kamera auf die obere linke Ecke und aktualisiert die Viewport-Größe.
func _ready() -> void:
	add_to_group("camera")
	
	enabled = true
	
	target_zoom = 1.0
	zoom = Vector2(target_zoom, target_zoom)
	
	# Warte einen Frame, damit der SubViewport die richtige Größe hat
	await get_tree().process_frame
	
	_update_viewport_size()
	
	_reset_to_top_left()
	
	position = target_position

## Setzt die Kamera auf die obere linke Ecke zurück.
func _reset_to_top_left() -> void:
	target_zoom = 1.0
	zoom = Vector2(target_zoom, target_zoom)
	
	# Kamera-Position so setzen, dass oben links des Canvas sichtbar ist
	var half_viewport = _viewport_size / 2.0 / target_zoom
	target_position = half_viewport
	position = target_position

## Aktualisiert die Viewport-Größe und berechnet minimalen Zoom.
func _update_viewport_size() -> void:
	var vp = get_viewport()
	var old_viewport_size = _viewport_size
	
	if vp:
		var new_size = vp.get_visible_rect().size
		if new_size.x > 0 and new_size.y > 0:
			_viewport_size = new_size
	
	# Berechne minimalen Zoom, sodass Canvas immer den Viewport ausfüllt
	var min_zoom_x = _viewport_size.x / canvas_size.x
	var min_zoom_y = _viewport_size.y / canvas_size.y
	_effective_min_zoom = max(min_zoom_level, max(min_zoom_x, min_zoom_y))
	
	# Wenn sich die Viewport-Größe geändert hat, passe die Position an
	# um den Canvas linksbündig zu halten
	if old_viewport_size != _viewport_size and old_viewport_size.x > 0:
		_adjust_position_for_viewport_change(old_viewport_size)

## Passt die Kamera-Position an wenn sich der Viewport ändert.
##
## Hält den Canvas linksbündig fixiert.
##
## @param old_viewport_size: Die vorherige Viewport-Größe
func _adjust_position_for_viewport_change(old_viewport_size: Vector2) -> void:
	var current_zoom_value = zoom.x
	
	# Berechne wie viel vom Canvas links oben sichtbar war
	var old_half_visible = old_viewport_size / 2.0 / current_zoom_value
	var new_half_visible = _viewport_size / 2.0 / current_zoom_value
	
	# Berechne die obere linke Ecke die vorher sichtbar war
	var old_top_left = position - old_half_visible
	
	# Halte die obere linke Ecke fixiert, berechne neue Kamera-Position
	var new_position = old_top_left + new_half_visible
	
	# Clampe die Position und setze sie
	position = clamp_camera_position(new_position)
	target_position = position

## Aktualisiert die Kamera jedes Frame.
##
## Führt sanftes Zoomen und Position-Interpolation durch.
##
## @param delta: Delta-Zeit seit letztem Frame
func _process(delta: float) -> void:
	# Aktualisiere Viewport-Größe falls sie sich geändert hat
	_update_viewport_size()
	
	var current_zoom_vec = zoom
	var target_zoom_vec = Vector2(target_zoom, target_zoom)
	
	if current_zoom_vec.distance_to(target_zoom_vec) > 0.001:
		zoom = zoom.lerp(target_zoom_vec, zoom_smooth_speed * delta)
		
		if is_zooming:
			position = position.lerp(target_position, zoom_smooth_speed * delta)
			
			position = clamp_camera_position(position)
			
			if current_zoom_vec.distance_to(target_zoom_vec) < 0.01:
				zoom = target_zoom_vec
				position = clamp_camera_position(target_position)
				is_zooming = false
	else:
		zoom = target_zoom_vec
		is_zooming = false

## Verarbeitet Eingaben für Pan und Zoom.
##
## @param event: Das Input-Event
func _input(event: InputEvent) -> void:
	# Canvas Pan mit Input Action
	if event.is_action_pressed("canvas_pan"):
		is_panning = true
		if event is InputEventMouseButton:
			pan_start_position = _get_local_mouse_position(event.position)
		camera_pan_start = position
		get_viewport().set_input_as_handled()
	elif event.is_action_released("canvas_pan"):
		is_panning = false
		get_viewport().set_input_as_handled()
	
	# Canvas Zoom mit Input Actions
	if event.is_action_pressed("canvas_zoom_in"):
		var mouse_pos = _get_local_mouse_position(get_viewport().get_mouse_position())
		zoom_in(mouse_pos)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("canvas_zoom_out"):
		var mouse_pos = _get_local_mouse_position(get_viewport().get_mouse_position())
		zoom_out(mouse_pos)
		get_viewport().set_input_as_handled()
	
	# Mouse Motion für Panning
	if event is InputEventMouseMotion:
		if is_panning:
			var current_mouse_pos = _get_local_mouse_position(event.position)
			var current_zoom_value = zoom.x
			var delta = (current_mouse_pos - pan_start_position)
			var new_position = camera_pan_start - delta / current_zoom_value
			position = clamp_camera_position(new_position)
			target_position = position
			get_viewport().set_input_as_handled()

## Konvertiert globale Mausposition zu lokaler Position im Viewport.
##
## @param global_pos: Die globale Mausposition
## @return: Die lokale Position im Viewport
func _get_local_mouse_position(global_pos: Vector2) -> Vector2:
	# Für SubViewport: Die Position ist bereits relativ zum SubViewport
	return global_pos

## Zoomt die Kamera hinein.
##
## @param mouse_pos: Die Mausposition für Zoom-Fokus
func zoom_in(mouse_pos: Vector2) -> void:
	var old_target = target_zoom
	target_zoom = clamp(target_zoom + zoom_step, _effective_min_zoom, max_zoom_level)
	
	if abs(old_target - target_zoom) > 0.001:
		calculate_zoom_to_point(mouse_pos)

## Zoomt die Kamera heraus.
##
## @param mouse_pos: Die Mausposition für Zoom-Fokus
func zoom_out(mouse_pos: Vector2) -> void:
	var old_target = target_zoom
	target_zoom = clamp(target_zoom - zoom_step, _effective_min_zoom, max_zoom_level)
	
	if abs(old_target - target_zoom) > 0.001:
		calculate_zoom_to_point(mouse_pos)

## Berechnet die neue Target-Position für Zoom zur Mausposition.
##
## @param mouse_screen_pos: Die Mausposition im Screen-Space
func calculate_zoom_to_point(mouse_screen_pos: Vector2) -> void:
	is_zooming = true
	zoom_mouse_pos = mouse_screen_pos
	
	var current_zoom_value = zoom.x
	var world_pos_under_mouse = position + (mouse_screen_pos - _viewport_size / 2) / current_zoom_value
	
	target_position = world_pos_under_mouse - (mouse_screen_pos - _viewport_size / 2) / target_zoom
	
	target_position = clamp_camera_position(target_position)

## Begrenzt die Kamera-Position basierend auf Canvas-Größe.
##
## Stellt sicher, dass der Canvas immer sichtbar bleibt.
##
## @param pos: Die zu begrenzende Position
## @return: Die begrenzte Position
func clamp_camera_position(pos: Vector2) -> Vector2:
	var current_zoom_value = zoom.x
	var visible_size = _viewport_size / current_zoom_value
	var half_visible = visible_size / 2
	
	var min_pos = half_visible
	
	var max_pos = canvas_size - half_visible
	
	if max_pos.x < min_pos.x:
		max_pos.x = canvas_size.x / 2.0
		min_pos.x = max_pos.x
	if max_pos.y < min_pos.y:
		max_pos.y = canvas_size.y / 2.0
		min_pos.y = max_pos.y
	
	return Vector2(
		clamp(pos.x, min_pos.x, max_pos.x),
		clamp(pos.y, min_pos.y, max_pos.y)
	)

## Setzt Zoom und Position zurück (oben links).
func reset_camera() -> void:
	_reset_to_top_left()
	is_panning = false
	is_zooming = false
	reset_canvas_requested.emit()

## Gibt den aktuellen Zoom-Level zurück.
##
## @return: Der aktuelle Zoom-Level
func get_zoom_level() -> float:
	return zoom.x

## Zentriert die Kamera auf eine Position.
##
## @param pos: Die Zielposition
func center_on_position(pos: Vector2) -> void:
	target_position = clamp_camera_position(pos)
	is_zooming = true

## Findet und zentriert auf den Program Block.
##
## Sendet das find_program_requested Signal.
func find_program_block() -> void:
	find_program_requested.emit()

## Zeigt alle Blöcke an (zoom out um alles zu sehen).
##
## Sendet das view_all_requested Signal.
func view_all_blocks() -> void:
	view_all_requested.emit()

## Passt Zoom an, um einen Bereich vollständig zu zeigen.
##
## @param rect: Der anzuzeigende Bereich
func fit_to_rect(rect: Rect2) -> void:
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	
	# Berechne benötigten Zoom mit etwas Padding
	var padding = 50.0
	var padded_rect = rect.grow(padding)
	
	var zoom_x = _viewport_size.x / padded_rect.size.x
	var zoom_y = _viewport_size.y / padded_rect.size.y
	target_zoom = clamp(min(zoom_x, zoom_y), _effective_min_zoom, max_zoom_level)
	
	target_position = clamp_camera_position(rect.get_center())
	is_zooming = true

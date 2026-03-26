## Verwaltet die Game-View mit dem Character.
##
## Enthält den SubViewport mit dem Character und der Spielwelt.
## Koordiniert die Kommunikation zwischen UI-Buttons und dem Game-Bereich.
extends PanelContainer
class_name GameViewContainer

## Die Kamera für die Game-View
@export var game_camera: Camera2D

## Der Character-Controller
@export var character: CharacterController

## Button zum Starten des Programms
@export var run_button: Button

## Button zum Zurücksetzen
@export var reset_button: Button

## Signal wird gesendet wenn "Run" gedrückt wird
signal run_pressed()

## Signal wird gesendet wenn "Reset" gedrückt wird
signal reset_pressed()

## Initialisiert den Container und verbindet die Buttons.
func _ready():
	_connect_buttons()

## Verbindet die Button-Signale mit den Handler-Methoden.
func _connect_buttons():
	if run_button:
		run_button.pressed.connect(_on_run_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

## Handler für "Run" Button.
func _on_run_pressed():
	run_pressed.emit()

## Handler für "Reset" Button.
func _on_reset_pressed():
	reset_pressed.emit()

## Gibt die Character-Referenz zurück.
##
## @return: Der Character-Controller
func get_character() -> CharacterController:
	return character

## Gibt die Game-Kamera zurück.
##
## @return: Die Game-Kamera
func get_game_camera() -> Camera2D:
	return game_camera

## Zentriert die Kamera auf den Character.
func center_on_character():
	if game_camera and character:
		game_camera.position = character.global_position

## Setzt die Kamera-Position.
##
## @param pos: Die neue Position
func set_camera_position(pos: Vector2):
	if game_camera:
		game_camera.position = pos

## Setzt den Kamera-Zoom.
##
## @param zoom_level: Der Zoom-Level
func set_camera_zoom(zoom_level: float):
	if game_camera:
		game_camera.zoom = Vector2(zoom_level, zoom_level)

## Aktiviert/Deaktiviert den Run-Button.
##
## @param enabled: true zum Aktivieren, false zum Deaktivieren
func set_run_button_enabled(enabled: bool):
	if run_button:
		run_button.disabled = not enabled

## Aktiviert/Deaktiviert den Reset-Button.
##
## @param enabled: true zum Aktivieren, false zum Deaktivieren
func set_reset_button_enabled(enabled: bool):
	if reset_button:
		reset_button.disabled = not enabled


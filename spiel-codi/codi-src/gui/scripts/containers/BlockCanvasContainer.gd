## Verwaltet den Block-Canvas Bereich.
##
## Enthält den SubViewport mit den Blöcken und die Steuerungs-Buttons.
## Koordiniert die Kommunikation zwischen UI-Buttons und der Canvas-Kamera.
extends PanelContainer
class_name BlockCanvasContainer

## Button zum Anzeigen aller Blöcke
@export var view_all_button: Button

## Button zum Zurücksetzen des Canvas
@export var reset_canvas_button: Button

## Die Kamera für den Canvas
@export var canvas_camera: Camera2D

## Container für die Blöcke
@export var blocks_container: CanvasGroup

## Signal wird gesendet wenn "View All" gedrückt wird
signal view_all_pressed()

## Signal wird gesendet wenn "Reset Canvas" gedrückt wird
signal reset_canvas_pressed()

## Initialisiert den Container und verbindet die Buttons.
func _ready():
	_connect_buttons()

## Verbindet die Button-Signale mit den Handler-Methoden.
func _connect_buttons():
	if view_all_button:
		view_all_button.pressed.connect(_on_view_all_pressed)
	if reset_canvas_button:
		reset_canvas_button.pressed.connect(_on_reset_canvas_pressed)

## Handler für "View All" Button.
##
## Sendet das Signal und ruft die Kamera-Methode auf.
func _on_view_all_pressed():
	view_all_pressed.emit()
	if canvas_camera and canvas_camera.has_method("view_all_blocks"):
		canvas_camera.view_all_blocks()

## Handler für "Reset Canvas" Button.
##
## Sendet das Signal und ruft die Kamera-Methode auf.
func _on_reset_canvas_pressed():
	reset_canvas_pressed.emit()
	if canvas_camera and canvas_camera.has_method("reset_camera"):
		canvas_camera.reset_camera()

## Gibt die Blocks-Container-Referenz zurück.
##
## @return: Der Blocks-Container
func get_blocks_container() -> CanvasGroup:
	return blocks_container

## Gibt die Canvas-Kamera zurück.
##
## @return: Die Canvas-Kamera
func get_canvas_camera() -> Camera2D:
	return canvas_camera

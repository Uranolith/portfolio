## Canvas-Hintergrund mit Shader-basiertem Grid.
##
## Aktualisiert Shader-Parameter basierend auf der Kamera-Position und Zoom
## für ein parallax-scrollendes Grid-Pattern.
extends ColorRect

## Die Ziel-Kamera deren Position und Zoom verfolgt werden soll
@export var target_camera: Camera2D

## Aktualisiert die Shader-Parameter jedes Frame basierend auf Kamera-Position und Zoom.
##
## @param _delta: Delta-Zeit seit letztem Frame (nicht verwendet)
func _process(_delta):
	if not target_camera:
		return
		
	var cam_pos = target_camera.global_position
	var viewport_size = get_viewport_rect().size
	var cam_zoom = target_camera.zoom.x
	
	# Berechne Offset für Shader basierend auf Kamera-Position und Zoom
	var offset = cam_pos - (viewport_size / 2.0) / cam_zoom
	
	# Übergebe Parameter an Shader
	material.set_shader_parameter("camera_position", offset)
	material.set_shader_parameter("camera_zoom", cam_zoom)

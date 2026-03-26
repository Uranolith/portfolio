## Steuert den 2D Isometric Character.
##
## Wird vom CharacterExecutor angesteuert und führt Bewegungen,
## Drehungen und Aktionen aus. Nutzt ein Kachel-basiertes Bewegungssystem.
extends CharacterBody2D
class_name CharacterController

## Signal wird gesendet, wenn eine Aktion abgeschlossen wurde
signal action_completed()

## Signal wird gesendet, wenn eine Bewegung startet
signal movement_started()

## Signal wird gesendet, wenn eine Bewegung endet
signal movement_finished()

## Richtungen (isometrisch)
enum Direction {
	NORTH = 0,  ## Oben-rechts
	EAST = 1,   ## Unten-rechts
	SOUTH = 2,  ## Unten-links
	WEST = 3    ## Oben-links
}

## Bewegungsgeschwindigkeit
@export var move_speed: float = 100.0

## Schrittweite für kachel-basierte Bewegung
@export var tile_size: Vector2 = Vector2(32, 32)

## Verzögerung zwischen Aktionen
@export var action_delay: float = 0.3

@onready var animated_sprite: AnimatedSprite2D = _find_animated_sprite()

## Findet die AnimatedSprite2D (Fallback wenn nicht direkt vorhanden).
##
## @return: Die gefundene AnimatedSprite2D oder null
func _find_animated_sprite() -> AnimatedSprite2D:
	# Versuche direkt zu finden
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		return sprite
	
	# Suche in allen Children
	for child in get_children():
		if child is AnimatedSprite2D:
			return child
	
	return null

## Aktuelle Blickrichtung des Characters
var current_direction: Direction = Direction.SOUTH

## Ob der Character gerade eine Aktion ausführt
var is_busy: bool = false

## Zielposition für Bewegung
var _target_position: Vector2 = Vector2.ZERO

## Bewegungs-Flag
var _is_moving: bool = false

func _ready():
	_target_position = global_position
	print("[CharacterController] _ready() - Position: %s" % global_position)
	
	# Warte einen Frame für @onready Initialisierung
	await get_tree().process_frame
	
	if animated_sprite:
		print("[CharacterController] AnimatedSprite2D gefunden: %s" % animated_sprite.name)
		_update_animation()
		animated_sprite.play()  # Stelle sicher, dass Animation läuft
	else:
		push_warning("[CharacterController] AnimatedSprite2D nicht gefunden!")

func _physics_process(_delta):
	if _is_moving:
		var direction_to_target = (_target_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(_target_position)
		
		if distance_to_target < 2.0:
			# Ziel erreicht
			global_position = _target_position
			_is_moving = false
			_play_idle_animation()
			movement_finished.emit()
		else:
			# Bewege zum Ziel
			velocity = direction_to_target * move_speed
			move_and_slide()


## Bewegt den Character einen Schritt vorwärts.
##
## Asynchrone Ausführung mit await.
func move_forward() -> void:
	if is_busy:
		return
	
	is_busy = true
	var offset = _get_direction_offset(current_direction)
	_start_movement(global_position + offset)
	await movement_finished
	await get_tree().create_timer(action_delay).timeout
	is_busy = false
	action_completed.emit()

## Bewegt den Character einen Schritt rückwärts.
##
## Asynchrone Ausführung mit await.
func move_backward() -> void:
	if is_busy:
		return
	
	is_busy = true
	var offset = _get_direction_offset(current_direction) * -1
	_start_movement(global_position + offset)
	await movement_finished
	await get_tree().create_timer(action_delay).timeout
	is_busy = false
	action_completed.emit()

## Dreht den Character nach links (gegen Uhrzeigersinn).
##
## Asynchrone Ausführung mit await.
func turn_left() -> void:
	if is_busy:
		return
	
	is_busy = true
	current_direction = (current_direction - 1) as Direction
	if current_direction < 0:
		current_direction = Direction.WEST
	_update_animation()
	await get_tree().create_timer(action_delay).timeout
	is_busy = false
	action_completed.emit()

## Dreht den Character nach rechts (im Uhrzeigersinn).
##
## Asynchrone Ausführung mit await.
func turn_right() -> void:
	if is_busy:
		return
	
	is_busy = true
	current_direction = ((current_direction + 1) % 4) as Direction
	_update_animation()
	await get_tree().create_timer(action_delay).timeout
	is_busy = false
	action_completed.emit()

## Character springt.
##
## Asynchrone Ausführung mit await.
func jump() -> void:
	if is_busy:
		return
	
	is_busy = true
	
	# Einfache Sprung-Animation (hoch und runter)
	var original_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 0.2)
	tween.tween_property(self, "position:y", original_pos.y, 0.2)
	await tween.finished
	
	await get_tree().create_timer(action_delay).timeout
	is_busy = false
	action_completed.emit()

## Character interagiert mit einem Objekt.
##
## Asynchrone Ausführung mit await.
func interact() -> void:
	if is_busy:
		return
	
	is_busy = true
	
	# TODO: Implementiere Interaktionslogik mit Level-Objekten
	print("[CharacterController] Interact at position: %s" % global_position)
	
	await get_tree().create_timer(action_delay * 2).timeout
	is_busy = false
	action_completed.emit()

## Character wartet.
##
## Asynchrone Ausführung mit await.
func wait() -> void:
	if is_busy:
		return
	
	is_busy = true
	await get_tree().create_timer(action_delay * 2).timeout
	is_busy = false
	action_completed.emit()

## Prüft ob der Character vorwärts laufen kann.
##
## @return: true wenn Bewegung möglich
func can_move_forward() -> bool:
	# TODO: Implementiere Kollisionsprüfung
	return true

## Prüft ob der Character rückwärts laufen kann.
##
## @return: true wenn Bewegung möglich
func can_move_backward() -> bool:
	# TODO: Implementiere Kollisionsprüfung
	return true

## Prüft ob ein Objekt vor dem Character ist.
##
## @return: true wenn Objekt vorhanden
func has_object_ahead() -> bool:
	# TODO: Implementiere Raycast oder Area2D-Prüfung
	return false

## Prüft ob der Character am Ziel ist.
##
## @return: true wenn am Ziel
func is_at_goal() -> bool:
	# TODO: Implementiere Zielprüfung mit Level
	return false

## Prüft ob der Character am Rand ist.
##
## @return: true wenn am Rand
func is_at_edge() -> bool:
	# TODO: Implementiere Randprüfung mit Level
	return false

## Prüft ob der Character interagieren kann.
##
## @return: true wenn Interaktion möglich
func can_interact() -> bool:
	# TODO: Implementiere Interaktionsprüfung
	return false

## Prüft ob der Pfad frei ist.
##
## @return: true wenn Pfad frei
func path_is_clear() -> bool:
	return can_move_forward()

## Prüft ob der Character nach Norden schaut.
##
## @return: true wenn Richtung NORTH
func is_facing_north() -> bool:
	return current_direction == Direction.NORTH

## Prüft ob der Character nach Osten schaut.
##
## @return: true wenn Richtung EAST
func is_facing_east() -> bool:
	return current_direction == Direction.EAST

## Prüft ob der Character nach Süden schaut.
##
## @return: true wenn Richtung SOUTH
func is_facing_south() -> bool:
	return current_direction == Direction.SOUTH

## Prüft ob der Character nach Westen schaut.
##
## @return: true wenn Richtung WEST
func is_facing_west() -> bool:
	return current_direction == Direction.WEST

## Gibt den Bewegungs-Offset für eine Richtung zurück.
##
## Kardinale Richtungen: Oben (Y-), Rechts (X+), Unten (Y+), Links (X-).
##
## @param dir: Die Richtung
## @return: Der Offset-Vector
func _get_direction_offset(dir: Direction) -> Vector2:
	match dir:
		Direction.NORTH:
			return Vector2(0, -tile_size.y)  # Oben
		Direction.EAST:
			return Vector2(tile_size.x, 0)   # Rechts
		Direction.SOUTH:
			return Vector2(0, tile_size.y)   # Unten
		Direction.WEST:
			return Vector2(-tile_size.x, 0)  # Links
	return Vector2.ZERO

## Startet eine Bewegung zur Zielposition.
##
## @param target: Die Zielposition
func _start_movement(target: Vector2) -> void:
	_target_position = target
	_is_moving = true
	movement_started.emit()
	_play_move_animation()

## Aktualisiert die Animation basierend auf der Richtung.
func _update_animation() -> void:
	_play_idle_animation()

## Spielt die Idle-Animation.
func _play_idle_animation() -> void:
	if not animated_sprite:
		return
	
	match current_direction:
		Direction.NORTH:
			animated_sprite.play("idle_north")
		Direction.EAST:
			animated_sprite.play("idle_east")
		Direction.SOUTH:
			animated_sprite.play("idle_south")
		Direction.WEST:
			animated_sprite.play("idle_west")

## Spielt die Bewegungs-Animation.
func _play_move_animation() -> void:
	if not animated_sprite:
		return
	
	match current_direction:
		Direction.NORTH:
			animated_sprite.play("move_north")
		Direction.EAST:
			animated_sprite.play("move_east")
		Direction.SOUTH:
			animated_sprite.play("move_south")
		Direction.WEST:
			animated_sprite.play("move_west")

## Setzt den Character zurück zur Startposition.
##
## @param start_position: Die Startposition
## @param start_direction: Die Start-Richtung (Standard: SOUTH)
func reset_to_start(start_position: Vector2, start_direction: Direction = Direction.SOUTH) -> void:
	global_position = start_position
	_target_position = start_position
	current_direction = start_direction
	is_busy = false
	_is_moving = false
	_update_animation()

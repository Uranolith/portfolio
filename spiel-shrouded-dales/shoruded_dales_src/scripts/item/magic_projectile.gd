class_name MagicProjectile
extends Area2D

@export var speed = 100
@export var travel_time = 2
@export var player: PlayerCharacter
@export var wait_time: float
@export var base_attack: int = 10
var animation: String = "STRONG"
var direction: float 

var velocity = Vector2i()


@export var _animation_player: AnimationPlayer
@onready var animation_player: AnimationPlayer = _animation_player

@export var _timer: Timer
@onready var timer: Timer = _timer

func _ready():
	if player:
		position = player.position + player.last_direction*10
		direction = player.last_direction.x
		if direction < 0:
			scale.x = -1
	if animation_player:
		animation_player.play(animation)
	if timer:
		if wait_time > 0:
			timer.wait_time = wait_time
		timer.start()


func _physics_process(delta):
	velocity.x = speed * delta * direction
	translate(velocity)
	

func _on_timer_timeout():
	queue_free()
	print("free %s" % self)


func _on_body_entered(body):
	if body is BaseEnemy:
		SignalManager.take_damage.emit(body, self)
		queue_free()
		print("free %s" % self)
	if body is TileMap:
		queue_free()
		print("free %s" % self)

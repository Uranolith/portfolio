extends Node2D

@onready var audio_area = $AudioArea
var active : bool = false

func _on_checkpointtrigger_body_entered(body):
	if (body is PlayerCharacter && !active):
		print("Player in Zone",body)
		$AnimatedSprite2D.play("checkpoint aktivated")
		body.respawn_location = position
		SignalManager.change_audio.emit("kindle_spawnpoint", "SFX")
		active = true
		audio_area.active = true
		audio_area.audioplayer.play()
		

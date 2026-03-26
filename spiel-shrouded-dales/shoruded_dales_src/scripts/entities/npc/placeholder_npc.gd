extends AnimatedSprite2D

@onready var dialog_box = $Dialog_Box

func _ready():
	dialog_box.visible = false
	
func toggle_Dialog_box(dialogstatus: bool ) -> void:
	dialog_box.visible = dialogstatus
	

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		print("Player detected")
		toggle_Dialog_box(true)
		


func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		toggle_Dialog_box(false)

class_name EnemyStateMachine
extends StateMachine

func _ready():
	for child in get_children():
		if child is State:
			states.append(child)
			
			# feed information to the states
			child.actor = actor
			#child.playback = animation_tree["parameters/playback"]
		else:
			push_warning("Child" + child.name + "is not a State for the player_StateMachine")

func _on_area_2d_body_entered(body):
	if body is PlayerCharacter:
		print(self.name + " says: I see you...")
		#next_state = chase

func _on_area_2d_body_exited(body):
	if body is PlayerCharacter:
		print(self.name + " says: I must have imagined")
		#next_state = idle


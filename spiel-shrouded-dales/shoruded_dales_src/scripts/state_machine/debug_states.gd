extends Label
# sole purpose is debugging output

@export var actor:CharacterBody2D
@export var state_machine : StateMachine

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = "S: " + state_machine.current_state.get_name()
	

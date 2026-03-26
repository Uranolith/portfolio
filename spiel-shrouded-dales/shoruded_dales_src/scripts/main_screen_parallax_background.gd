extends ParallaxBackground
@export var charactersprite: AnimatedSprite2D 
@export var monstersprite: AnimatedSprite2D
#1:var protected_x_position = 600

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#1:charactersprite.position.x=protected_x_position
	charactersprite.position.x += 80*delta 
	monstersprite.position.x += 80*delta 
	if charactersprite.position.x > 1280:
		charactersprite.position.x = 0
	if monstersprite.position.x > 1280:
		monstersprite.position.x = 0
	
	scroll_offset.x -= 40*delta

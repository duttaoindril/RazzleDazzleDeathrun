extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var playerDetection

func _ready():
	print("SPIKE IS INITIALIZED")
	playerDetection = get_node("Area2D")
	set_fixed_process(true)

func _fixed_process(delta):
	print(playerDetection.get_overlapping_bodies())
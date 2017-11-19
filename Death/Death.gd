extends KinematicBody2D

var state
var preset

func _ready():
	state = {
		"": get_parent(),
		"id": get_name()[get_name().length()-1],
		"otherId": str(int(!(int(get_name()[get_name().length()-1])-1))+1),
		"facing": Vector2(1, 0),
		"sprite": get_node("DeathSprite"),
	}
	pass

func init(name, set):
	set_name(name)
	preset = set
	set_pos(preset["position"])
	return self
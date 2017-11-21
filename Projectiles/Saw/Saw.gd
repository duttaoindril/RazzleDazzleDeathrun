extends KinematicBody2D
#SETUP/Global/Constants
const MOVE_SPEED = 1
const GRAVITY = .2
const DAMPEN = 0.8
const JUMP_MULT = 25
const MOVE_SPEED = 1
var state
#ON INSTANCE RUN ---------------------------------------------------------------------------------------------
func _ready():
	state = {"id":get_name()[get_name().length()-1],
	"otherId":str(int(!(int(get_name()[get_name().length()-1])-1))+1),
	"name": get_name(),
	"grounded":false,
	"velocity":Vector2(),
	"facing":Vector2(1,0),
	"sprite":get_node("PlayerSprite"),
	"body": get_node("PlayerBody"),
	"action":"idle"}
	set_fixed_process(true)
#INITIALIZATION ----------------------------------------------------------------------------------------------
func init(name, set):
	preset = set
	set_name(name)
	set_pos(preset["position"])
	state["facing"] = preset["facing"]
	return self
#RUNS 60HZ ----------------------------------------------------------------------------------------------
func _fixed_process(delta):
#LEFT AND RIGHT CONTROLS
	if Input.is_action_pressed("left"+state["id"]):
		velocity.x -= MOVE_SPEED 
	elif Input.is_action_pressed("right"+state["id"]):
		velocity.x += MOVE_SPEED 
	if Input.is_action_pressed("up"+state["id"]) && state["grounded"]:
		velocity.y = gravity * -25
		if (is_colliding()) and test_move(Vector2(0,1)):
			velocity.y -= gravity * 5
	if !(is_colliding()):
		velocity.y += gravity
	else:
		velocity.y = 0
	var dampen = 0.8
	velocity += velocity * delta
	velocity.x *= dampen
	move(state["velocity"])
	if (is_colliding()):
		var n = get_collision_normal()
		velocity = n.slide(velocity)
	move(velocity)
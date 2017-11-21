extends KinematicBody2D
#SETUP/Global/Constants
const MOVE_SPEED = 1
const GRAVITY = .2
const DAMPEN = 0.8
const JUMP_MULT = 25
const MOVE_SPEED = 1
var state = {}
#ON INSTANCE RUN ---------------------------------------------------------------------------------------------
func _ready():
	state = {"id":get_name()[get_name().length()-1],
	"otherId":str(int(!(int(get_name()[get_name().length()-1])-1))+1),
	"name": get_name(),
	"facing":Vector2(1,0),
	"velocity":Vector2(),
	"grounded":false,
	"action":"idle",
	"sprite":get_node("SawSprite"),
	"body": get_node("SawBody"),
	"core": get_node("SawCore"),
	"name": get_node("SurvivorName"),
	"sound": get_node("FX")}
	state["name"].set_text(get_name())
	set_fixed_process(true)
	set_process_input(true)
#INITIALIZATION ----------------------------------------------------------------------------------------------
func init(name, set):
	preset = set
	set_name(name)
	state["position"] = preset["position"]
	reset()
	return self
#RUNS 60HZ ----------------------------------------------------------------------------------------------
func _fixed_process(delta):
	if !get_viewport_rect().has_point(get_pos()):
		reset()
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
#HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func reset():
	set_pos(state["position"])
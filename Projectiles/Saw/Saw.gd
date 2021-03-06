extends KinematicBody2D
#SETUP/Global/Constants
const MOVE_SPEED = .8
const GRAVITY = .4
const DAMPEN = 0.8
var state = {}
var preset
#ON INSTANCE RUN ---------------------------------------------------------------------------------------------
func _ready():
	state["game"] = get_parent()
	state["map0"] = state["game"].s("layer0")
	state["otherId"] = str(int(!(int(state["id"])-1))+1)
	state["facing"] = Vector2(1,0)
	state["velocity"] = Vector2()
	state["grounded"] = false
	state["action"] = "idle"
	state["sprite"] = get_node("SawSprite")
	state["body"] = get_node("SawShape")
	state["core"] = get_node("SawCore")
	state["jump"] = get_node("SawJump")
	state["name"] = get_node("SawName")
	state["survivor"] = state["game"].get_node("Player "+str(state["otherId"]))
	state["death"] = state["game"].get_node("Player "+str(state["id"]))
	state["name"].set_text(get_name())
	add_collision_exception_with(state["survivor"])
	set_fixed_process(true)
	set_process_input(true)
#INITIALIZATION ----------------------------------------------------------------------------------------------
func init(name, set, id):
	preset = set
	set_name(name)
	state["id"] = id
	state["position"] = preset["position"]
	reset()
	return self
#RUNS 60HZ ----------------------------------------------------------------------------------------------
func _fixed_process(delta):
	state["grounded"] = state["jump"].overlaps_body(state["map0"])
	if !get_viewport_rect().has_point(get_pos()):
		reset()
	if state["core"].overlaps_body(state["survivor"]):
		state["survivor"].death()
		queue_free()
	#CONTROLS	
	if Input.is_action_pressed("left"+str(state["id"])):
		state["facing"].x = -1
		state["velocity"].x -= MOVE_SPEED 
		state["sprite"].play("move")
		state["death"].controlSawLeft()
	elif Input.is_action_pressed("right"+str(state["id"])):
		state["facing"].x = 1
		state["velocity"].x += MOVE_SPEED
		state["sprite"].play("move")
		state["death"].controlSawRight()
	else:
		state["death"].controlSawIdle()
		state["sprite"].play("idle")
	if (Input.is_action_pressed("up"+str(state["id"])) || Input.is_action_pressed("action"+str(state["id"]))) && state["grounded"]:
		state["velocity"].y = GRAVITY * -25
		state["death"].controlSawUp()
		if (is_colliding()) and test_move(Vector2(0,1)):
			state["velocity"].y -= GRAVITY * 5
	state["sprite"].set_flip_h(state["facing"].x+1)
	if !(is_colliding()):
		state["velocity"].y += GRAVITY
	else:
		state["velocity"].y = 0
	state["velocity"] += state["velocity"] * delta
	state["velocity"].x *= DAMPEN
	move(state["velocity"])
	if (is_colliding()):
		var n = get_collision_normal()
		state["velocity"] = n.slide(state["velocity"])
	move(state["velocity"])
#HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func reset():
	set_pos(state["position"])
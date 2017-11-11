extends KinematicBody2D
#Global Constants
const MOVE_SPEED = 1
const GRAVITY = .2
const DAMPEN = 0.8
const JUMP_MULT = 30
const JUMP_SPEED = JUMP_MULT*GRAVITY
const ATTACK_DELAY = 65
const RELOAD_SPEED = 0.5
#Global Variables
var state

func _ready():
	state = {
		"id": get_name()[get_name().length()-1],
		"otherId": str(int(!(int(get_name()[get_name().length()-1])-1))+1),
		"name": get_name(),
		"health": "<3 <3 <3",
		"delay": ATTACK_DELAY,
		"grounded": false,
		"velocity": Vector2(),
		"facing": Vector2(1, 0),
#		"sprite": get_node("PlayerSprite"),
#		"sound": get_node("Sound"),
#		"body": get_node("PlayerBody"),
		"directions": {
			Vector2(-1, 1): "head",
			Vector2(1, 1): "head",
			Vector2(-1, 0): "left",
			Vector2(1, 0): "right"
		},
#		"nameLabel": get_node("PlayerName")
	}
	set_fixed_process(true)
	
func _fixed_process(delta):
	# Left and right movements
	if Input.is_action_pressed("right"+state["id"]):
		state["facing"].x = 1
		state["velocity"].x += MOVE_SPEED
		if (state["action"] == "idle"):
			state["sprite"].play("move")
	elif Input.is_action_pressed("left"+state["id"]):
		state["facing"].x = -1
		state["velocity"].x -= MOVE_SPEED
	if Input.is_action_pressed("down"+state["id"]): #This is going to do nothing for now
		state["velocity"].y = GRAVITY*-JUMP_MULT
		if (state["action"] == "idle"):
			state["sprite"].play("move")
	elif state["action"] == "idle":
		state["sprite"].play("idle")
	if Input.is_action_pressed("up"+state["id"] && state["ground"]):
		state["action"] = "jump"
		state["velocity"].y = GRAVITY*-JUMP_MULT
		if (is_colliding()) and test_move(Vector2(0,1)):
			state["velocity"].y -= GRAVITY * 5
	state["sprite"].set_flip_h(state["facing"].x+1)
	
	if(!is_colliding()):
		   state["velocity"].y += GRAVITY
	else:
       state["velocity"].y = 0
	
	state["velocity"] += state["velocity"] * delta
	state["velocity"].x *= DAMPEN
	move(state["velocity"].y)
	if is_colliding(): 
		var n = get_collision_normal()
		state["velocity"] = n.slide(state["velocity"])
		move(state["velocity"])
	
func _PlayerAnimation_finished():
	state["sprite"].play("idle")
	state["action"]="idle"
extends KinematicBody2D

#PRE SETUP
const MOVE_SPEED = 1
const GRAVITY = .2
const DAMPEN = 0.8
const JUMP_MULT = 30
var state

func _ready():
	state = {
		"id": get_name()[get_name().length()-1],
		"otherId": str(int(!(int(get_name()[get_name().length()-1])-1))+1),
		"name": get_name(),
		"grounded": false,
		"velocity": Vector2(),
		"facing": Vector2(1,0),
		"sprite": get_node("PlayerSprite"),
		"body": get_node("PlayerBody"),
		"action": "idle"
	}
	set_fixed_process(true)

func _fixed_process(delta):
	#LEFT AND RIGHT CONTROLS
	if Input.is_action_pressed("left"+state["id"]):
		state["velocity"].x -= MOVE_SPEED 
	elif Input.is_action_pressed("right"+state["id"]):
		state["velocity"].x += MOVE_SPEED 
	if Input.is_action_pressed("up"+state["id"]) && state["grounded"]:
		state["velocity"].y = -JUMP_MULT*GRAVITY
		if is_colliding() && test_move(Vector2(0,1)):
			state["velocity"].y -= GRAVITY*5
	if !is_colliding():
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

func die():
	get_parent().playerBeat(int(state["id"]), int(state["otherId"]))

func _on_PlayerSprite_finished():
	state["sprite"].play("idle")
	state["action"] = "idle"
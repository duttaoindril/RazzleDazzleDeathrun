extends KinematicBody2D
#SETUP
const MOVE_SPEED = 1
const GRAVITY = .2
const DAMPEN = 0.8
const JUMP_MULT = 30
var preset
var state = {}
#TODO
# - Handle Tie Scores
# - Implement Animations
# - Area Detection
# - Jumping
# - Death Controls
# - Win Detection
# - Preset
func _ready():
	state["game"] = get_parent()
	state["id"] = get_name()[get_name().length()-1]
	state["otherId"] = str(int(!(int(get_name()[get_name().length()-1])-1))+1)
	state["action"] = "idle"
	state["position"] = get_pos()
	state["velocity"] = Vector2()
	state["grounded"] = false
	state["feet"] = get_node("PlayerBottom")
	state["body"] = get_node("PlayerBody")
	state["sprite"] = get_node("PlayerSprite")
	state["name"] = get_node("PlayerName")
	state["name"].set_text(get_name())
	set_fixed_process(true)
	set_process_input(true)
#Initializes the Player with correct properties
func init(name, set):
	preset = set
	set_name(name)
	set_pos(preset["worldposition"])
	state["facing"] = preset["facing"]
	return self
#RUNS 60HZ
func _fixed_process(delta):
	#LEFT AND RIGHT CONTROLS
	if Input.is_action_pressed("left"+state["id"]):
		state["velocity"].x -= MOVE_SPEED
	elif Input.is_action_pressed("right"+state["id"]):
		state["velocity"].x += MOVE_SPEED
	#JUMP CONTROLS
	if Input.is_action_pressed("up"+state["id"]) && state["grounded"]:
		state["velocity"].y = -JUMP_MULT*GRAVITY
		if is_colliding() && test_move(Vector2(0,1)):
			state["velocity"].y -= GRAVITY*5
	#PHYSICS
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
#HANDLE JUMPING OR ACTION
func _input(event): #shooting, attacking and jumping
	if event.is_action_pressed("action"+state["id"]) && state["grounded"]: #JUMP
		state["action"] = "jump"
		state["sprite"].play("jump")
		state["sound"].play("jump")
		state["velocity"].y = GRAVITY * -JUMP_MULT
		if is_colliding() && test_move(Vector2(0,1)):
			state["velocity"].y -= GRAVITY * 5
#DEATH HANDLING
func death():
	get_parent().playerBeat(int(state["id"]), int(state["otherId"]))
#ANIMATION FINISH HANDLING
func _on_PlayerSprite_finished():
	state["sprite"].play("idle")
	state["action"] = "idle"
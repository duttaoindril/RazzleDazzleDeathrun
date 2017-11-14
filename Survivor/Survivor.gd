extends KinematicBody2D
#SETUP
const MOVE_SPEED = 1
const GRAVITY = .2
const DAMPEN = 0.8
const JUMP_MULT = 25
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
	state["map0"] = state["game"].get("layer0")
	state["id"] = get_name()[get_name().length()-1]
	state["otherId"] = str(int(!(int(get_name()[get_name().length()-1])-1))+1)
	state["action"] = "idle"
	state["grounded"] = false
	state["position"] = get_pos()
	state["velocity"] = Vector2()
	state["directions"] = ["head", "right", "feet", "left"]
	state["facings"] = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, 0)]
	state["facingsRotation"] = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	state["coreTile"] = ["", false]
	state["headTile"] = ["", false]
	state["leftTile"] = ["", false]
	state["rightTile"] = ["", false]
	state["feetTile"] = ["", false]
	state["checkTile"] = ["", false, "core"]
	state["head"] = get_node("SurvivorTop")
	state["right"] = get_node("SurvivorRight")
	state["feet"] = get_node("SurvivorBottom")
	state["left"] = get_node("SurvivorLeft")
	state["core"] = get_node("SurvivorCore")
	state["jump"] = get_node("SurvivorJump")
	state["sprite"] = get_node("SurvivorSprite")
	state["body"] = get_node("SurvivorBody")
	state["sound"] = get_node("FX")
	state["name"] = get_node("SurvivorName")
	state["name"].set_text(get_name())
	set_fixed_process(true)
	set_process_input(true)
#Initializes the Survivor with correct properties
func init(name, set):
	preset = set
	set_name(name)
	set_pos(preset["worldposition"])
	state["facing"] = preset["facing"]
	return self
#RUNS 60HZ
func _fixed_process(delta):
	if !get_viewport_rect().has_point(get_pos()):
		death()
	state["position"] = get_pos()
	state["grounded"] = state["jump"].get_overlapping_bodies().has(state["map0"])
	print("~~~~")
	for direction in state["directions"]:
		var checkATile = state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)]+state["facingsRotation"][state["directions"].find(direction)+2]
		var checkBTile = state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)]+state["facingsRotation"][state["directions"].find(direction)]
		if direction == "feet": print(state[direction].overlaps_body(state["map0"])) #," ",direction, " A: ", checkATile, state["position"].distance_to(state["game"].getPosFromIdx(checkATile)), state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)], " B: ", checkBTile, state["position"].distance_to(state["game"].getPosFromIdx(checkBTile)))
		state[direction+"Tile"] = state["game"].getTile(state["game"].getIdxFromPos(state["position"])+state["facings"][state["directions"].find(direction)], state["directions"].find(direction)) if state[direction].get_overlapping_bodies().has(state["map0"]) && state["game"].hasTile(state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)]) else ["", false]
		checkDeathDirectional(direction)
#		if state[direction].get_overlapping_bodies().has(state["map0"]) && state["game"].hasTile(state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)]):
#			for direction in state["directions"]:
#				var idx = state["directions"].find(direction)
#				var facing = state["facings"][idx]
#				var xIndex = vec2Array(facing.abs())[0] == 1
#				var yIndex = vec2Array(facing.abs())[1] == 1
#				var facingCheck = 0 if xIndex else (1 if yIndex else -1)
#				var positionCheck = vec2Array(state["position"])[facingCheck]/state["game"].get("tileSize")
#				var positionCheckDirection = round((positionCheck-floor(positionCheck))*10)/10
#				if facingCheck != -1 && (positionCheckDirection > .5 || positionCheckDirection < .5):
#					print("idx: ", idx, " facing: ", facing, " xIndex: ", xIndex, " yIndex: ", yIndex, " facingCheck: ", facingCheck, " positionCheck: ", positionCheck, " positionCheckDirection: ",  positionCheckDirection)
#				print("idx: ", idx, " facing: ", facing, " xIndex: ", xIndex, " yIndex: ", yIndex, " facingCheck: ", facingCheck, " positionCheck: ", positionCheck, " positionCheckDirection: ",  positionCheckDirection)
#				print(str(state["game"].getIdxFromPos(state["position"])+state["facings"][state["directions"].find(direction)]))
#		print("(",state["position"].x/state["game"].get("tileSize"),", ",state["position"].y/state["game"].get("tileSize"))
#		print(str(state["game"].getIdxFromPos(state["position"])))
#		state["game"]
#		state["checkTile"] = state["game"].getTile(state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)], state["directions"].find(direction)) if state[direction].get_overlapping_bodies().has(state["map0"]) && state["game"].hasTile(state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)]) else ["", false]
#			print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
#			print("Position: ",state["position"])
#			print("Grounded: ",state["grounded"])
#			print("Tile Position: ", state["game"].getIdxFromPos(state["position"]))
#			state[direction+"Tile"] = state["game"].getTile(state["game"].getIdxFromPos(get_pos())+state["facings"][state["directions"].find(direction)], state["directions"].find(direction))
#		else: state[direction+"Tile"] = ["", false]
	#AIM UP OR NOT DIRECTION CONTROLS
	if Input.is_action_pressed("up"+state["id"]): state["facing"].y = 1
	else: state["facing"].y = 0
	#LEFT AND RIGHT CONTROLS
	if Input.is_action_pressed("left"+state["id"]):
		state["facing"].x = 1
		state["velocity"].x -= MOVE_SPEED
		if state["action"] == "idle":
			state["sprite"].play("move")
	elif Input.is_action_pressed("right"+state["id"]):
		state["facing"].x = -1
		state["velocity"].x += MOVE_SPEED
		if state["action"] == "idle":
			state["sprite"].play("move")
	elif state["action"] == "idle":
		state["sprite"].play("idle")
	if state["action"] == "jump":
		if state["velocity"].y == 0 && state["grounded"]:
			state["action"] = "idle"
#		elif state["velocity"].y == 0:
#			state["sprite"].set_frame(0)
#		elif state["velocity"].y < -JUMP_SPEED/2:
#			state["sprite"].set_frame(1)
#		elif state["velocity"].y > -JUMP_SPEED/2:
#			state["sprite"].set_frame(2)
#		elif state["velocity"].y > JUMP_SPEED/2:
#			state["sprite"].set_frame(3)
#		elif state["velocity"].y > JUMP_SPEED:
#			state["sprite"].set_frame(4)
	state["sprite"].set_flip_h(state["facing"].x+1)
	#PHYSICS
	if !is_colliding():
		state["velocity"].y += GRAVITY
#	else:
#		state["velocity"].y = 0
	state["velocity"] += state["velocity"] * delta
	state["velocity"].x *= DAMPEN
	move(state["velocity"])
	if (is_colliding()):
		var n = get_collision_normal()
		state["velocity"] = n.slide(state["velocity"])
	move(state["velocity"])
#HANDLE JUMPING OR ACTION
func _input(event): #shooting, attacking and jumping
	if (event.is_action_pressed("up"+state["id"]) || event.is_action_pressed("action"+state["id"])) && state["grounded"]: #JUMP
		state["action"] = "jump"
		state["sprite"].play("jump")
		state["sound"].play("jump")
		state["velocity"].y = GRAVITY * -JUMP_MULT
		if is_colliding() && test_move(Vector2(0,1)):
			state["velocity"].y -= GRAVITY * 5
#ANIMATION FINISH HANDLING
func _on_SurvivorSprite_finished():
	state["sprite"].play("idle")
	state["action"] = "idle"
#DEATH HANDLING
func checkDeath():
	for direction in state["directions"]:
		checkDeathDirectional(direction)
func checkDeathDirectional(s):
	if state[s+"Tile"][1] || (state["checkTile"][2] == s && state["checkTile"][1]):
		death()
func death():
	state["game"].roundEnd(false, true)
#HELPER FUNCTIONS
func vec2Array(v):
	return [v.x, v.y]
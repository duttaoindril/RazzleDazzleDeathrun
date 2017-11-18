extends KinematicBody2D
#SETUP/Global/Constants
const MOVE_SPEED = 1
const GRAVITY = .2
const DAMPEN = 0.8
const JUMP_MULT = 25
var preset
var state = {}
#TODO ----------------------------------------------------------------------------------------------
# - Handle Tie Scores
# - Implement Animations
# - Area Detection
# - Jumping
# - Death Controls
# - Win Detection
# - Preset
#ON INSTANCE RUN ----------------------------------------------------------------------------------------------
func _ready():
	state["game"] = get_parent()
	state["map0"] = state["game"].get("layer0")
	state["name"] = get_node("SurvivorName")
	state["id"] = get_name()[get_name().length()-1]
	state["otherId"] = str(int(!(int(get_name()[get_name().length()-1])-1))+1)
	state["action"] = "idle"
	state["grounded"] = false
	state["position"] = get_pos()
	state["velocity"] = Vector2()
	state["fallThrough"] = false
	state["sprite"] = get_node("SurvivorSprite")
	state["body"] = get_node("SurvivorBody")
	state["head"] = get_node("SurvivorTop")
	state["right"] = get_node("SurvivorRight")
	state["feet"] = get_node("SurvivorBottom")
	state["left"] = get_node("SurvivorLeft")
	state["core"] = get_node("SurvivorCore")
	state["jump"] = get_node("SurvivorJump")
	state["directions"] = ["head", "right", "feet", "left", "core", "grounded", "core"]
#	state["directionDistances"] = [66, 66, 66, 66, 50, 8, 6, 11, 6, 0]
	state["facings"] = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, 0)]
	state["facingsRotation"] = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	state["coreTile"] = ["", false]
	state["headTile"] = ["", false]
	state["leftTile"] = ["", false]
	state["rightTile"] = ["", false]
	state["feetTile"] = ["", false]
	state["checkTile"] = ["", false]
	state["sound"] = get_node("FX")
	state["name"].set_text(get_name())
	set_fixed_process(true)
	set_process_input(true)
#INITIALIZATION ----------------------------------------------------------------------------------------------
func init(name, set):
	preset = set
	set_name(name)
	set_pos(preset["worldposition"])
	state["facing"] = preset["facing"]
	return self
#RUNS 60HZ ----------------------------------------------------------------------------------------------
func _fixed_process(delta):
	updateState(Input) #UPDATE DATA AND CHECK IF DEAD OR NOT
	#AIM UP AND DOWN DIRECTION CONTROLS
	if pressed("up"): state["facing"].y = 1
	elif pressed("down"): state["facing"].y = -1
	else: state["facing"].y = 0
	#AIM LEFT AND RIGHT DIRECTION CONTROLS
	if moveLR():
		handleMove(pressed("right"))
	elif state["action"] == "idle":
		state["leftOrRight"] = false
		state["sprite"].play("idle")
	else:
		state["leftOrRight"] = false
	state["sprite"].set_flip_h(state["facing"].x+1)
	#JUMP SPRITE MANAGEMENT
#	print(state["action"]," | ",getSpriteFrame()," | ",state["velocity"].y," | ",state["grounded"]," | ",isJumping())
	if isFrame("launch8"):
		state["action"] = "jump"
		state["sprite"].play("jump")
	if isJumping() && state["velocity"].y > 0:
		state["action"] = "fall"
		state["sprite"].play("fall")
	if state["action"] == "fall" && !isJumping():
		state["action"] = "fallL"
		state["sprite"].play("land")
	if isFrame("land2"):
		state["sprite"].play("idle")
		state["action"] = "idle"
	#PHYSICS
	if !is_colliding(): state["velocity"].y += GRAVITY
	else: state["velocity"].y = 0
	state["velocity"] += state["velocity"] * delta
	state["velocity"].x *= DAMPEN
	move(state["velocity"])
	if is_colliding(): state["velocity"] = get_collision_normal().slide(state["velocity"])
	move(state["velocity"])
#HANDLE JUMPING OR ACTION ----------------------------------------------------------------------------------------------
func _input(event): #jumping and falling through
	if (pressedI(event, "up") || pressedI(event, "action")) && state["grounded"] && isFloatingLR(): #JUMP
		state["velocity"].y = GRAVITY * -JUMP_MULT
		if is_colliding() && test_move(Vector2(0,1)): state["velocity"].y -= GRAVITY * 5
		else:
			state["sound"].play("jump")
			state["action"] = "jumpL"
			state["sprite"].play("launch")
	elif pressedI(event, "down") && state["grounded"] && state["game"].getTileName(dirTile("feet")).find("platform") != -1 && !state["game"].hasTile(dirTile("feet")+dir2face("feet")): #Fall Through
		state["action"] = "fall"
		state["sprite"].play("fall")
		state["velocity"].y = 0.01
		state["fallThrough"] = true
	elif pressedR(event, "suicide"): death()
#ANIMATION FINISH HANDLING ----------------------------------------------------------------------------------------------
func isFrame(string):
	return getSpriteFrame() == string
func getSpriteFrame():
	return state["sprite"].get_animation()+str(state["sprite"].get_frame())
#STATE HANDLING & HELPERS ----------------------------------------------------------------------------------------------
func updateState(input):
	state["input"] = input
	state["position"] = get_pos()
	state["grounded"] = dirTouch("jump")
	if state["fallThrough"] && dirTouch("head"): state["fallThrough"] = false
	state["body"].set_trigger(state["fallThrough"])
	checkDeath()
func pressed(dir):
	return pressedI(state["input"], dir)
func pressedI(input, dir):
	return input.is_action_pressed(dir+state["id"])
func pressedR(input, dir):
	return input.is_action_pressed(dir)
func isJumping():
	return !(state["grounded"] && state["velocity"].y == 0)
func isFloatingLR():
	return !(!state["velocity"].y == 0 && !state["leftOrRight"])
func moveLR():
	return pressed("left") || pressed("right")
func handleMove(right):
	right = 1 if right else -1
	state["leftOrRight"] = true
	state["facing"].x = -1*right
	state["velocity"].x += MOVE_SPEED*right
	if state["action"] == "idle":
		state["sprite"].play("move")
#MAP HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func getPosIdx():
	return pos2Idx(state["position"])
func posPosDis(pos):
	return pos2Dis(state["position"], pos)
func posIdxDis(idx):
	return posPosDis(idx2Pos(idx))
func dirTouch(dir):
	return state[dir].overlaps_body(state["map0"])
func dirFind(dir):
	return state["directions"].find(dir)
func dirFindL(dir):
	return state["directions"].find_last(dir)
func dir2face(dir):
	return state["facings"][dirFind(dir)]
func dir2facerm(dir, m):
	return state["facingsRotation"][dirFind(dir)+m]
func dir2facer(dir):
	return dir2facerm(dir, 0)
func dirDistm(dir, m):
	return state["directionDistances"][dirFind(dir) + m]
func dirDist(dir):
	return dirDistm(dir, 0)
func getDirPlus(dir):
	return dirDistm(dir, 5)
func dirTile(dir):
	return getPosIdx()+dir2face(dir)
func dirTileInv(dir):
	var inv = []
	for direction in state["directions"]:
		if direction != dir && !inv.has(dirTile(direction)): inv.append(dirTile(direction))
	return inv
func checkTiles(dir):
	return [dirTile(dir)+dir2facerm(dir, 2), dirTile(dir)+dir2facer(dir)]
#DEATH HANDLING & HELPERS ----------------------------------------------------------------------------------------------
func _on_SurvivorJump_body_enter(body):
	var checks = checkTiles("feet")
	for check in checks:
		if check == Vector2(17, 10): print("Body Checking"); #IF THIS DOES NOT PRINT AND YOU GET THROUGH, I HAVE TRIED EVERYTHING, I'M SORRY.
		if idxKill(check, "feet")[1] && posIdxDis(check) < 50 && !state["game"].hasTile(dirTile("feet")):
			print("Killed Manually")
			death()
func checkDeath():
	if !get_viewport_rect().has_point(state["position"]): death()
	for i in range(0, 5): if dirTouch(state["directions"][i]): checkDeathDirs(killTiles(state["directions"][i]))
func death():
	state["game"].roundEnd(false, true)
func idxKill(idx, dir):
	return state["game"].getTileKill(idx, dirFind(dir))
func dirKill(dir):
	return idxKill(dirTile(dir), dir)
func killTiles(dir):
	var i = 0 if posIdxDis(checkTiles(dir)[0])[0] < posIdxDis(checkTiles(dir)[1])[0] else 1
	var check = [dirKill(dir), checkTiles(dir)[i]]
	var dist = posIdxDis(check[1])
	if dist[(0 if v2A(dir2face(dir))[0] == 0 else 1)+1] < 50 && !state["game"].hasTile(dirTile(dir)):
		if dir == "head" && !isJumping(): check.pop_back()
		else:
			check[1] = idxKill(check[1], dir)
			dLog(check, dir, dist, true)
	else: check.pop_back()
	return check
func checkDeathDirs(checks):
	for check in checks:
		if check[1]:
			death()
func dLog(check, dir, dist, killing):
	if idxKill(check[1][2], dir)[1]: print(("~~~KILLING!!---@" if killing else ""),dir,"-",dirTouch(dir),": Distance: ",dist," | Check: ",check[1]," | Jumping: ",str(isJumping())," | NoDirTile: ",check[0][1])#," | Distance: ",dist," | Distance Check: ",distanceCheck," -> ",distanceCheck + distanceCheckPlus)
#HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func v2A(v):
	return [v.x, v.y]
func pos2Idx(pos):
	return state["game"].getIdxFromPos(pos)
func idx2Pos(pos):
	return Vector2(pos.x*60+30, pos.y*60+30)
func pos2Dis(posA, posB):
	return [sqrt(pow(posA.x-posB.x,2)+pow(posA.y-posB.y,2)),abs(posA.x-posB.x),abs(posA.y-posB.y)]
func pidx2Dis(posA, idxB):
	return dis2Pos(posA, idx2Pos(idxB))
func idx2Dis(idxA, idxB):
	return dis2Pos(idx2Pos(idxA), idx2Pos(idxB))
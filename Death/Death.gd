extends KinematicBody2D
#SETUP/Global/Constants
const GRAVITY = .2
const DAMPEN = 0.8
var state = {}
var preset
#ON INSTANCE RUN ----------------------------------------------------------------------------------------------
func _ready():
	state["game"] = get_parent()
	state["map0"] = state["game"].get("layer0")
	state["name"] = get_node("DeathName")
	state["name"].set_text(get_name())
	state["id"] = get_name()[get_name().length()-1]
	state["otherId"] = str(int(!(int(get_name()[get_name().length()-1])-1))+1)
	state["position"] = get_pos()
	state["index"] = idx()
	state["velocity"] = Vector2()
	state["action"] = "idle"
	state["facings"] = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, 0)]
	state["dirs"] = ["up", "right", "down", "left"]
	state["timers"] = ["move", "delay", "action"]
	state["moveReload"] = 0
	state["delayReload"] = 0
	state["actionReload"] = 0
	state["sprite"] = get_node("DeathSprite")
	state["sound"] = get_node("FX")
	state["moveReloadBar"] = get_node("MoveReloadBar")
	state["delayReloadBar"] = get_node("DelayReloadBar")
	state["actionReloadBar"] = get_node("ActionReloadBar")
	state["queues"] = []
	act("hide", ["moveReloadBar", "delayReloadBar", "actionReloadBar"])
	set_fixed_process(true)
	set_process_input(true)
#	state["directions"] = ["head", "right", "feet", "left", "core", "grounded", "core"]
#	state["grounded"] = false
#	state["fallThrough"] = false
#	state["body"] = get_node("SurvivorBody")
#	state["head"] = get_node("SurvivorTop")
#	state["right"] = get_node("SurvivorRight")
#	state["feet"] = get_node("SurvivorBottom")
#	state["left"] = get_node("SurvivorLeft")
#	state["core"] = get_node("SurvivorCore")
#	state["jump"] = get_node("SurvivorJump")
#	state["facingsRotation"] = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
#INITIALIZATION ----------------------------------------------------------------------------------------------
func init(name, set):
	set_name(name)
	preset = set
	set_pos(preset["position"])
	state["facing"] = preset["facing"]
	return self
#RUNS 60HZ ----------------------------------------------------------------------------------------------
func _fixed_process(DELTA):
	#STATUS UPDATES
	setFacing()
	state["position"] = get_pos()
	state["index"] = idx()
	for type in state["timers"]:
		if state[type+"Reload"] != 0:
			state[type+"ReloadBar"].set_value(int((float(preset[type+"ReloadMax"]-state[type+"Reload"])/preset[type+"ReloadMax"])*100))
			state[type+"Reload"] -= 1#preset[type+"ReloadStep"]
			if state[type+"Reload"] == 0:
				state[type+"ReloadBar"].set_value(100)
				state[type+"ReloadBar"].hide()
				state[type+"ReloadBar"].set_value(0)
				if type == "delay":
					call(preset["actionFunc"][0])
#					state["game"].call(preset["actionFunc"][1])
	for i in range(0, state["queues"].size()):
		state["queues"][i][0] = state["queues"][i][0] - 1
		if state["queues"][i][0] == 0:
			if state["queues"][i].size() > 2: call(state["queues"][i][1], state["queues"][i][2])
			else: call(state["queues"][i][1])
			state["queues"].remove(i)
	#ACTION & FRAME RESOLUTION HANDLING
	if state["action"] == "shoot" && isFrame("shoot1"): shootBolt()
	elif state["action"] == "gapClose" && isFrame("actionMain3"): closeGap()
	#PHYSICS HANDLING
	if !is_colliding(): state["velocity"].y += GRAVITY
	else: state["velocity"].y = 0
	state["velocity"] += state["velocity"]*DELTA
	state["velocity"].x *= DAMPEN
	move(state["velocity"])
	if is_colliding():
		var n = get_collision_normal()
		state["velocity"] = n.slide(state["velocity"])
		move(state["velocity"])
#HANDLE ALL INPUTS ----------------------------------------------------------------------------------------------
func _input(i):
	#UP AND DOWN DIRECTION CONTROLS
	if pressed(i, "up"):
		if preset["canTurnY"]:
			state["facing"].y = 1
		if state["action"] != "idle" && (!preset.has("canMultitask") || (preset.has("canMultitask") && !preset["canMultitask"])):
			pass
		else:
			if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
				if preset.has("moveReloadMax") && preset["upFunc"][0] != "na":
					state["moveReload"] = preset["moveReloadMax"]
					state["moveReloadBar"].show()
				call(preset["upFunc"][0])
#				state["game"].call(preset["upFunc"][1])
	elif pressed(i, "down"):
		if preset["canTurnY"]:
			state["facing"].y = -1
		if state["action"] != "idle" && (!preset.has("canMultitask") || (preset.has("canMultitask") && !preset["canMultitask"])):
			pass
		else:
			if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
				if preset.has("moveReloadMax") && preset["downFunc"][0] != "na":
					state["moveReload"] = preset["moveReloadMax"]
					state["moveReloadBar"].show()
				call(preset["downFunc"][0])
#				state["game"].call(preset["downFunc"][1])
	else:
		state["facing"].y = 0
	#LEFT AND RIGHT DIRECTION CONTROLS
	if pressed(i, "left"):
		if preset["canTurnX"]:
			state["facing"].x = -1
		if state["action"] != "idle" && (!preset.has("canMultitask") || (preset.has("canMultitask") && !preset["canMultitask"])):
			pass
		else:
			if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
				if preset.has("moveReloadMax") && preset["leftFunc"][0] != "na":
					state["moveReload"] = preset["moveReloadMax"]
					state["moveReloadBar"].show()
				call(preset["leftFunc"][0])
#				state["game"].call(preset["leftFunc"][1])
	elif pressed(i, "right"):
		if preset["canTurnX"]:
			state["facing"].x = 1
		if state["action"] != "idle" && (!preset.has("canMultitask") || (preset.has("canMultitask") && !preset["canMultitask"])):
			pass
		else:
			if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
				if preset.has("moveReloadMax") && preset["rightFunc"][0] != "na":
					state["moveReload"] = preset["moveReloadMax"]
					state["moveReloadBar"].show()
				call(preset["rightFunc"][0])
#				state["game"].call(preset["rightFunc"][1])
	elif state["action"] == "idle":
		anim("idle")
#	elif (i.is_action_released("left"+state["id"]) && state["action"] == "actionLeftRpt") || (i.is_action_released("right"+state["id"]) && state["action"] == "actionRightRpt"):
#		state["action"] = "idle"
	#ACTION DIRECTION CONTROLS
	if pressed(i, "action"):
#		if preset.has("delayReloadMax") && state["delayReload"] == 0 && preset["actionFunc"][0] != "na":
#			if preset.has("actionReloadMax") && state["actionReload"] != 0: pass
#			else: state["delayReload"] = preset["delayReloadMax"]
		if !preset.has("actionReloadMax") || (preset.has("actionReloadMax") && state["actionReload"] == 0):
			if state["action"] != "idle" && (!preset.has("canMultitask") || (preset.has("canMultitask") && !preset["canMultitask"])):
				pass
			else:
				if preset.has("actionReloadMax") && preset["actionFunc"][0] != "na":
					state["actionReload"] = preset["actionReloadMax"]
					state["actionReloadBar"].show()
				call(preset["actionFunc"][0])
#				state["game"].call(preset["actionFunc"][1])
#ALL POSSIBLE PRESET FUNCTIONS ----------------------------------------------------------------------------------------------
func shoot():
	state["action"] = "shoot"
	anim("shoot")
func teleportUp():
	teleport(idx(), state["facings"][0], preset["teleportRange"][1], preset["teleportRange"][2], preset["teleportRange"][3])
func teleportRight():
	teleport(idx(), state["facings"][1], preset["teleportRange"][0], preset["teleportRange"][2], preset["teleportRange"][3])
func teleportDown():
	teleport(idx(), state["facings"][2], preset["teleportRange"][1], preset["teleportRange"][2], preset["teleportRange"][3])
func teleportLeft():
	teleport(idx(), state["facings"][3], preset["teleportRange"][0], preset["teleportRange"][2], preset["teleportRange"][3])
func controlGapUp():
	controlGap("up")
func controlGapRight():
	controlGap("right")
func controlGapDown():
	controlGap("down")
func controlGapLeft():
	controlGap("left")
func controlGapShut():
	state["action"] = "gapClose"
	addQue(preset["delayReloadMax"], "openGap", preset["actionFunc"][1])
	anim("actionMain")
func controlSawUp():
	state["action"] = "actionUp"
	anim("actionUp")
func controlSawRight():
	if state["action"] != "actionUp":
		state["action"] = "actionRightRpt"
		anim("actionRightRpt")
func controlSawDown():
	pass
func controlSawLeft():
	if state["action"] != "actionUp":
		state["action"] = "actionLeftRpt"
		anim("actionLeftRpt")
func controlSawIdle():
	if state["action"] != "actionUp":
		state["action"] = "idle"
		anim("idle")
func removePlayerTile():
	addQue(preset["delayReloadMax"], "removeGround", state["game"].get_node("Player "+state["otherId"]).dirTile("feet"))
#ALL POSSIBLE PRESET FUNCTION RESOLUTIONS ----------------------------------------------------------------------------------------------
func controlGap(dir):
	if state["game"].canMoveGap(state["facings"][state["dirs"].find(dir)]):
		addQue(preset["animMoveDelay"], "gameCall", preset[dir+"Func"][1])
		state["action"] = "action"+dir.capitalize()
		anim("action"+dir.capitalize())
func closeGap():
	state["action"] = "gapOpen"
	gameCall(preset["actionFunc"][1])
func openGap(funct):
	gameCall(funct)
	state["action"] = "idle"
func shootBolt():
	var bolt = preload("res://Projectiles/Bolt/Bolt.tscn").instance()
	get_parent().add_child(bolt)
	bolt.fire(get_pos(), state["facing"], state["otherId"])
#	state["sound"].play("shoot")
	state["action"] = "idle"
func removeGround():
	var tilePos = state["game"].get_node("Player "+state["otherId"]).dirTile("feet")
	addQue(stps(2), "reAddGround", [tilePos, state["game"].getTile(tilePos)])
	state["game"].setTile(tilePos, -1)
func reAddGround(data):
	state["game"].setTile(data[0], data[1])
func teleport(pos, dir, dist, rpt, chck):
	var tilePos = pos+dir*(dist+1)
	if dist > 0 && get_viewport_rect().has_point(idx2Pos(tilePos)) && state["game"].getTile(tilePos+2*state["facings"][2]) == preset["deathPlatform"] && !state["game"].hasTile(tilePos) && !state["game"].hasTile(tilePos+state["facings"][2]) && !state["game"].getTileKill(tilePos+2*state["facings"][2], 2)[1] && !state["game"].getTileKill(tilePos+state["facings"][0], 0)[1] && (chck == "xxx" || chck != "xxx" && state["game"].hasTileName(tilePos+3*state["facings"][2], chck)):
		state["action"] = "teleOut"
		state["teleData"] = [idx2Pos(tilePos), dir]
		anim("teleOut")
		act("hide", ["name"])
	elif get_viewport_rect().has_point(idx2Pos(tilePos)) && rpt && dist > 0:
		teleport(tilePos, dir, dist, rpt, chck)
	else:
		state["moveReloadBar"].hide()
		state["moveReload"] = 0
#func controlSaw(dir):
#	state["game"].get_node("Player "+str(state["id"])+"'s Saw").call(dir)
#HELPERS ----------------------------------------------------------------------------------------------
func isFrame(string):
	return getSpriteFrame() == string
func getSpriteFrame():
	return state["sprite"].get_animation()+str(state["sprite"].get_frame())
func anim(s):
	if s == "actionRight":
		state["facing"].x = 1
		state["sprite"].play("actionLeft")
	else: state["sprite"].play(s)
func addQueue(time, fn):
	state["queues"].append([time, fn])
func addQue(time, fn, args):
	state["queues"].append([time, fn, args])
func act(funct, args):
	for arg in args:
		doAct(arg, funct)
func doAct(arg, funct):
	state[arg].call(funct)
func gameCall(funct):
	state["game"].call(funct)
func pressed(i, dir):
	return i.is_action_pressed(dir+state["id"])
func setFacing():
	state["sprite"].set_flip_h(bool(state["facing"].x+1))
func idx():
	return pos2Idx(state["position"])
func pos2Idx(pos):
	return state["game"].getIdxFromPos(pos)
func idx2Pos(pos):
	return state["game"].getPosFromIdxAlt(pos)
#	return state["game"].getPosFromIdx(pos)
func stps(sec):
	return state["game"].secToStep(sec)
func na():
	pass
func _on_DeathSprite_finished():
	if state["action"] == "teleIn":
		act("show", ["name"])
	if state["action"] == "teleOut":
		state["action"] = "teleIn"
		set_pos(Vector2(state["teleData"][0].x, state["teleData"][0].y+30))
		if preset["invertOnTele"] && state["teleData"][1].x != 0:
			state["facing"].x = -state["facing"].x
		anim("teleIn")
	elif state["action"].to_lower().find("rpt") > -1:
		pass
	else:
		anim("idle")#"idleUp" if state["facing"].y == 1 else "idle")
		state["action"] = "idle"
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
	state["timers"] = ["move", "delay", "action"]
	state["moveReload"] = 0
	state["delayReload"] = 0
	state["actionReload"] = 0
	state["sprite"] = get_node("DeathSprite")
	state["sound"] = get_node("FX")
	state["moveReloadBar"] = get_node("MoveReloadBar")
	state["delayReloadBar"] = get_node("DelayReloadBar")
	state["actionReloadBar"] = get_node("ActionReloadBar")
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
					if preset["actionFunc"][1] != "na":
						state["game"].call(preset["actionFunc"][1], state["delayData"])
	#ACTION & FRAME RESOLUTION HANDLING
	if state["action"] == "shoot" && isFrame("shoot1"):
		shootBolt()
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
		if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
			if preset.has("moveReloadMax") && preset["upFunc"][0] != "na":
				state["moveReload"] = preset["moveReloadMax"]
				state["moveReloadBar"].show()
			call(preset["upFunc"][0])
			state["game"].call(preset["upFunc"][1])
	elif pressed(i, "down"):
		if preset["canTurnY"]:
			state["facing"].y = -1
		if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
			if preset.has("moveReloadMax") && preset["downFunc"][0] != "na":
				state["moveReload"] = preset["moveReloadMax"]
				state["moveReloadBar"].show()
			call(preset["downFunc"][0])
			state["game"].call(preset["downFunc"][1])
	else:
		state["facing"].y = 0
	#LEFT AND RIGHT DIRECTION CONTROLS
	if pressed(i, "left"):
		if preset["canTurnX"]:
			state["facing"].x = -1
		if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
			if preset.has("moveReloadMax") && preset["leftFunc"][0] != "na":
				state["moveReload"] = preset["moveReloadMax"]
				state["moveReloadBar"].show()
			call(preset["leftFunc"][0])
			state["game"].call(preset["leftFunc"][1])
	elif pressed(i, "right"):
		if preset["canTurnX"]:
			state["facing"].x = 1
		if !preset.has("moveReloadMax") || (preset.has("moveReloadMax") && state["moveReload"] == 0):
			if preset.has("moveReloadMax") && preset["rightFunc"][0] != "na":
				state["moveReload"] = preset["moveReloadMax"]
				state["moveReloadBar"].show()
			call(preset["rightFunc"][0])
			state["game"].call(preset["rightFunc"][1])
	elif state["action"] == "idle":
		anim("idle")
	#ACTION DIRECTION CONTROLS
	if pressed(i, "action"):
		if preset.has("delayReloadMax") && state["delayReload"] == 0 && preset["actionFunc"][0] != "na":
			state["delayReload"] = preset["delayReloadMax"]
		elif !preset.has("actionReloadMax") || (preset.has("actionReloadMax") && state["actionReload"] == 0):
			if preset.has("actionReloadMax") && preset["actionFunc"][0] != "na":
				state["actionReload"] = preset["actionReloadMax"]
				state["actionReloadBar"].show()
			call(preset["actionFunc"][0])
			state["game"].call(preset["actionFunc"][1])
#ALL POSSIBLE PRESET FUNCTIONS ----------------------------------------------------------------------------------------------
func shoot():
	state["action"] = "shoot"
	anim("shoot")
func teleportUp():
	teleport(idx(), state["facings"][0], preset["teleportRange"][0], preset["teleportRange"][4], preset["teleportRange"][5])
func teleportRight():
	teleport(idx(), state["facings"][1], preset["teleportRange"][1], preset["teleportRange"][4], preset["teleportRange"][5])
func teleportDown():
	teleport(idx(), state["facings"][2], preset["teleportRange"][2], preset["teleportRange"][4], preset["teleportRange"][5])
func teleportLeft():
	teleport(idx(), state["facings"][3], preset["teleportRange"][3], preset["teleportRange"][4], preset["teleportRange"][5])
func controlGapUp():
	pass
func controlGapRight():
	pass
func controlGapDown():
	pass
func controlGapLeft():
	pass
func controlGapShut():
	pass
func controlSawUp():
	anim("actionUp")
func controlSawRight():
	state["action"] = "actionRight"
	anim("actionRight")
func controlSawDown():
	anim("actionDown")
func controlSawLeft():
	anim("actionLeft")
#ALL POSSIBLE PRESET FUNCTION RESOLUTIONS ----------------------------------------------------------------------------------------------
func shootBolt():
	var bolt = preload("res://Projectiles/Bolt/Bolt.tscn").instance()
	get_parent().add_child(bolt)
	bolt.fire(get_pos(), state["facing"], state["otherId"])
#	state["sound"].play("shoot")
	state["action"] = "idle"
func removeGround():
	var tilePos = state["game"].get_node("Player "+state["otherId"]).dirTile("feet")
	state["delayData"] = [tilePos, state["game"].getTile(tilePos)]
	state["map0"].set_cell(tilePos.x, tilePos.y, -1)
func teleport(pos, dir, rng, far, bat):
	var tilePos = pos+dir*(rng+1)
	if get_viewport_rect().has_point(idx2Pos(tilePos)) && state["game"].hasTile(tilePos+2*state["facings"][2]) && !state["game"].hasTile(tilePos) && !state["game"].hasTile(tilePos+state["facings"][2]) && !state["game"].getTileKill(tilePos+2*state["facings"][2], 2)[1] && !state["game"].getTileKill(tilePos+state["facings"][0], 0)[1] && (!bat || bat && state["game"].hasTileName(tilePos+3*state["facings"][2], "bat")):
		state["action"] = "tele"
		anim("teleport")
		set_pos(idx2Pos(tilePos))
	elif get_viewport_rect().has_point(idx2Pos(tilePos)) && far:
		teleport(tilePos, dir, rng, far, bat)
	else:
		state["moveReloadBar"].hide()
		state["moveReload"] = 0
func controlSaw(dir):
	state["game"].get_node("Player "+str(state["id"])+"'s Saw").call(dir)
#HELPERS ----------------------------------------------------------------------------------------------
func pressed(i, dir):
	return i.is_action_pressed(dir+state["id"])
func setFacing():
	state["sprite"].set_flip_h(bool(state["facing"].x+1))
func idx():
	return pos2Idx(state["position"])
func pos2Idx(pos):
	return state["game"].getIdxFromPos(pos)
func idx2Pos(pos):
	return state["game"].getPosFromIdx(pos)
func isFrame(string):
	return getSpriteFrame() == string
func anim(s):
	if s == "actionRight":
		state["facing"].x = 1
		state["sprite"].play("actionLeft")
	else: state["sprite"].play(s)
func getSpriteFrame():
	return state["sprite"].get_animation()+str(state["sprite"].get_frame())
func _on_DeathSprite_finished():
	if state["action"] == "actionRight":
		state["facing"].x = -1
		state["action"] = "idle"
	if state["action"] == "tele":
		state["action"] = "teleout"
	else:
		anim("idle")#"idleUp" if state["facing"].y == 1 else "idle")
		state["action"] = "idle"
func act(funct, args):
	for arg in args:
		state[arg].call(funct)
func na():#type):
#	state[type+"Reload"] = 0
#	state[type+"ReloadBar"].hide()
	pass
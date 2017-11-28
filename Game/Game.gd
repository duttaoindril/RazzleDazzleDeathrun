extends Node
#SETUP/Global/Constants
var state
var presets
#TODO
# - Make Teleport/Shoot Down Block Generation Code
# - CHANGE THIS TO PROPERLY HANDLE ANY AMOUNT OF INITS - ALLOW FOR INITS AT SETUP AND INITS AT SPAWN
#ON INSTANCE RUN ---------------------------------------------------------------------------------------------
func _ready():
	if OS.get_name() == "OSX":
		OS.set_borderless_window(false)
		OS.set_window_maximized(true)
	state = {"tree": get_tree(), 
	"facing": [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, 0)], 
	"preset": 0, 
	"round": 1, 
	"roundTotal": 1, 
	"playerScores": [0, 0, 0, 0], 
	"player2Death": true, 
	"survivorId": 1, 
	"deathId": 2, 
	"signal": "", 
	"startTime": int(OS.get_ticks_msec()), 
	"endpopup": get_node("endPopup"), 
	"endtext": .get_node("endPopup").get_node("endText"), 
	"goal": get_node("Goal"), 
	"splash": get_node("Splashscreen"), 
	"deathsplash": get_node("DeathSplashscreen"), 
	"survivorsplash": get_node("SurvivorSplashscreen"), 
	"deathwinsplash": get_node("DeathWinSplashscreen"), 
	"deathkillsplash": get_node("DeathKillSplashscreen"), 
	"survivorwinsplash": get_node("SurvivorWinSplashscreen"), 
	"switchsplash": get_node("SwitchSplashscreen"), 
	"roundscore": get_node("RoundScore"), 
	"roundtime": get_node("RoundTime"), 
	"score1": get_node("ScorePlayer1"), 
	"maxscore1": get_node("MaxRoundScorePlayer1"), 
	"score2": get_node("ScorePlayer2"), 
	"maxscore2": get_node("MaxRoundScorePlayer2"), 
	"tileSize": get_node("Layer0Map").get_cell_size()[0], 
	"width": get_viewport().get_rect().size[0], 
	"height": get_viewport().get_rect().size[1], 
	"mapWidth": get_viewport().get_rect().size[0]/get_node("Layer0Map").get_cell_size()[0], 
	"mapHeight": get_viewport().get_rect().size[1]/get_node("Layer0Map").get_cell_size()[1],
	"dims": ["mapWidth", "mapHeight"],
	"layer0": get_node("Layer0Map"), 
	"bg": get_node("BG"), 
	"music": get_node("BGMusic"), 
	"subg": get_node("SubBGMusic"), 
	"fx": get_node("FX"),
	"presetData": "",
	"edges": [[[2, 4, -1], [3, 4, -1], [4, 0, 6, -1], [1, 4, -1]],
			  [[2, 4, -1], [4], [4], [4]],
			  [[2, 4, -1], [-1], [0, 6], [1, 4, -1]]],
	"patterns": [[[[20, 20, 8, 16], 5, 1, 1, 4], [[4, 18, 1, 15], 4, .15]],
				 [[[0, 3, 9, 17], 4, 1], [[28, 31, 9, 17], 4, 1]],
				 [[[0, 3, 9, 17], 4, 1], [[1, 2, 10, 16], 7, 1], [[1, 2, 10, 10], 6, 1], [[28, 31, 9, 17], 4, 1], [[29, 30, 10, 16], 7, 1], [[29, 30, 10, 10], 6, 1], [[5, 26, 16, 16], 5, .2]]],
	"customs": ["((0, 0):4), ((0, 1):2), ((0, 10):0), ((0, 11):2), ((0, 12):-1), ((0, 13):-1), ((0, 14):-1), ((0, 15):-1), ((0, 16):0), ((0, 17):4), ((0, 2):-1), ((0, 3):-1), ((0, 4):-1), ((0, 5):-1), ((0, 6):0), ((0, 7):2), ((0, 8):-1), ((0, 9):-1), ((1, 0):4), ((1, 1):4), ((1, 10):0), ((1, 11):4), ((1, 12):4), ((1, 13):4), ((1, 14):4), ((1, 15):4), ((1, 16):4), ((1, 17):4), ((1, 2):4), ((1, 3):4), ((1, 4):4), ((1, 5):4), ((1, 6):4), ((1, 7):2), ((1, 8):-1), ((1, 9):-1), ((2, 0):4), ((2, 1):2), ((2, 10):0), ((2, 11):2), ((2, 12):-1), ((2, 13):-1), ((2, 14):-1), ((2, 15):-1), ((2, 16):0), ((2, 17):4), ((2, 2):-1), ((2, 3):-1), ((2, 4):-1), ((2, 5):-1), ((2, 6):0), ((2, 7):2), ((2, 8):-1), ((2, 9):-1)",
				"((0, 0):-1)"]}
	presets = [{ # Gap up and down preset
		"prstData": [22, 24, 6, 11],
		"timeLength": 60, 
		"survivorTimeoutWin": false, 
		"bgs": [0], 
		"bgMusic": [1, 2, 3],
		"map": {
			"edge": 0,
			"pattern": 0,
			"custom": 0,
			"customPos": [Vector2(22, 0)],
			"deathplatform": 4,
			"survivorplatform": 4,
			"winplatform": 4,
			"deadlyFloor": true
		}, 
		"survivor": {
			"position": getPosFromIdx(Vector2(2, 8)), 
			"facing": Vector2(-1, 0), 
			"wincondition": [26, 31, 13, 16],
		}, 
		"death": {
			"position": getPosFromIdx(Vector2(29, 3)),
			"facing": Vector2(-1, 0), 
			"canTurnX": false, 
			"canTurnY": false, 
			"static": true, 
			"upFunc": ["controlGapUp", "controlGapUp"],
			"rightFunc": ["na", "na"],
			"downFunc": ["controlGapDown", "controlGapDown"],
			"leftFunc": ["na", "na"],
			"actionFunc": ["na", "na"],
			"moveReloadMax": secToStep(1.5),
		}
	}, { # Gap move up and down and shuts preset
		"prstData": [22, 24, 6, 11],
		"timeLength": 60,
		"survivorTimeoutWin": false, 
		"bgs": [0], 
		"bgMusic": [1, 2, 3],
		"map": {
			"edge": 0,
			"pattern": 0,
			"custom": 0,
			"customPos": [Vector2(22, 0)],
			"deathplatform": 4,
			"survivorplatform": 5,
			"winplatform": 4,
			"deadlyFloor": true
		}, 
		"survivor": {
			"position": getPosFromIdx(Vector2(2, 8)), 
			"facing": Vector2(-1, 0), 
			"wincondition": [26, 31, 13, 16],
		}, 
		"death": {
			"position": getPosFromIdx(Vector2(29, 3)),
			"facing": Vector2(-1, 0), 
			"canTurnX": false, 
			"canTurnY": false, 
			"static": true,
			"upFunc": ["controlGapUp", "controlGapUp"],
			"rightFunc": ["na", "na"],
			"downFunc": ["controlGapDown", "controlGapDown"],
			"leftFunc": ["na", "na"],
			"actionFunc": ["controlGapShut", "na"],
			"moveReloadMax": secToStep(.5),
			"actionReloadMax": secToStep(3),
		}
	}, { # Gap at the bottom and shuts preset
		"prstData": [22, 24, 6, 11],
		"timeLength": 60, 
		"survivorTimeoutWin": false, 
		"bgs": [0], 
		"bgMusic": [1, 2, 3], 
		"map": {
			"edge": 0,
			"pattern": 0,
			"custom": 0,
			"customPos": [Vector2(22, 0)],
			"deathplatform": 4,
			"survivorplatform": 4,
			"winplatform": 4,
			"deadlyFloor": true
		}, 
		"survivor": {
			"position": getPosFromIdx(Vector2(2, 8)), 
			"facing": Vector2(-1, 0), 
			"wincondition": [26, 31, 13, 16],
		}, 
		"death": {
			"position": getPosFromIdx(Vector2(29, 3)),
			"facing": Vector2(-1, 0), 
			"canTurnX": false, 
			"canTurnY": false, 
			"static": true,
			"upFunc": ["controlGapUp", "controlGapUp"],
			"rightFunc": ["na", "na"],
			"downFunc": ["controlGapDown", "controlGapDown"],
			"leftFunc": ["na", "na"], 
			"actionFunc": ["controlGapShut", "na"],
			"moveReloadMax": secToStep(1.5), 
			"actionReloadMax": secToStep(3), 
		}
	}, { # Saw Level
		"prstData": "",
		"timeLength": 60, 
		"survivorTimeoutWin": false, 
		"bgs": [0],
		"bgMusic": [1, 2, 3], 
		"init": "addSaw",
		"map": {
			"edge": 1,
			"pattern": 1,
			"custom": 1,
			"customPos": [Vector2(25, 16), Vector2(26, 16), Vector2(27, 16), Vector2(31, 5)],
			"deathplatform": 4,
			"survivorplatform": 4,
			"winplatform": 4,
			"deadlyFloor": true
		}, 
		"survivor": {
			"position": getPosFromIdx(Vector2(2, 8)), 
			"facing": Vector2(-1, 0), 
			"wincondition": [28, 31, 6, 8],
		}, 
		"death": {
			"position": getPosFromIdx(Vector2(29, 3)),
			"facing": Vector2(-1, 0), 
			"canTurnX": false, 
			"canTurnY": false, 
			"static": true,
			"upFunc": ["controlSawUp", "na"], 
			"rightFunc": ["controlSawRight", "na"], 
			"downFunc": ["controlSawDown", "na"], 
			"leftFunc": ["controlSawLeft", "na"], 
			"actionFunc": ["na", "na"],
			"saw": {"position": getPosFromIdx(Vector2(26, 16))}
		}
	}, { # Deadlier Saw Level
		"prstData": "",
		"timeLength": 60, 
		"survivorTimeoutWin": false, 
		"bgs": [0],
		"bgMusic": [1, 2, 3], 
		"init": "addSaw",
		"map": {
			"edge": 2,
			"pattern": 2,
			"custom": 1,
			"customPos": [Vector2(25, 15), Vector2(26, 15), Vector2(27, 15), Vector2(31, 5)],
			"deathplatform": 4,
			"survivorplatform": 4,
			"winplatform": 4,
			"deadlyFloor": true
		}, 
		"survivor": {
			"position": getPosFromIdx(Vector2(2, 8)), 
			"facing": Vector2(-1, 0), 
			"wincondition": [28, 31, 6, 8],
		}, 
		"death": {
			"position": getPosFromIdx(Vector2(29, 3)),
			"facing": Vector2(-1, 0), 
			"canTurnX": false, 
			"canTurnY": false, 
			"static": true,
			"upFunc": ["controlSawUp", "na"], 
			"rightFunc": ["controlSawRight", "na"], 
			"downFunc": ["controlSawDown", "na"], 
			"leftFunc": ["controlSawLeft", "na"], 
			"actionFunc": ["na", "na"],
			"saw": {"position": getPosFromIdx(Vector2(26, 15))}
		}
	}] #"teleTiles": [[29, 29, 3, 15], [2, 2, 3, 15]],
	act("hide", ["deathwinsplash", "deathkillsplash", "survivorwinsplash", "endpopup", "goal"])
	act("show", ["splash", "survivorsplash", "deathsplash", "switchsplash"])
	state["subg"].play("start")
	state["music"].play("bg1")
	setUp()
	set_fixed_process(true)
	set_process_input(true)
#RUNS 60HZ ----------------------------------------------------------------------------------------------
func _fixed_process(delta):
	var seconds = state["startTime"]-int(OS.get_ticks_msec()/1000)
	state["roundtime"].set_text("%02d:%02d" % [int(seconds/60), int(seconds%60)])
	if seconds < 0:
		roundEnd(presets[state["preset"]]["survivorTimeoutWin"], false)
#HANDLE MISC KEY ACTIONS ----------------------------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("action"):
		if state["endpopup"].is_visible():
			handleSignal()
		elif state["splash"].is_visible():
			act("hide", ["splash"])
		elif state["survivorsplash"].is_visible():
			act("hide", ["survivorsplash"])
		elif state["deathsplash"].is_visible():
			act("hide", ["deathsplash"])
		elif state["survivorwinsplash"].is_visible():
			act("hide", ["survivorwinsplash"])
		elif state["deathwinsplash"].is_visible():
			act("hide", ["deathwinsplash"])
		elif state["deathkillsplash"].is_visible():
			act("hide", ["deathkillsplash"])
		elif state["switchsplash"].is_visible():
			startTimer()
			add_child(preload("res://Survivor/Survivor.tscn").instance().init("Player "+str(state["survivorId"]), presets[state["preset"]]["survivor"]))
			add_child(preload("res://Death/Death.tscn").instance().init("Player "+str(state["deathId"]), presets[state["preset"]]["death"]))
			#INIT HANDLING TODO
			if presets[state["preset"]].has("init"):
				call(presets[state["preset"]]["init"])
			act("hide", ["switchsplash"])
	elif event.is_action_pressed("toggleMaximize"):
		if OS.is_window_maximized():
			var screen = OS.get_current_screen()
			var screenSize = OS.get_screen_size(screen)
			OS.set_window_size(Vector2(state["width"], state["height"]))
			OS.set_window_position(Vector2((screenSize.x-state["width"])/2, (screenSize.y-state["height"])/2))
			OS.set_current_screen(screen)
		OS.set_borderless_window(!OS.get_borderless_window())
		OS.set_window_maximized(!OS.is_window_maximized())
	elif event.is_action_pressed("restart"):
		reset()
	elif event.is_action_pressed("reload"):
		giveSignal("reload_current_scene")
	elif event.is_action_pressed("quit"):
		giveSignal("quit")
	elif event.is_action_pressed("suicide"):
		roundEnd(false, true)
#INITIALIZATION OF ROUND ----------------------------------------------------------------------------------------------
func setUp():
	var lastPreset = state["preset"] #Store Last Preset
	state["preset"] = randI(0, presets.size()) #Get New Preset
	if flpCoin() && lastPreset == state["preset"]: state["preset"] = randI(0, presets.size()) #50% chance to reroll preset if last and new presets are the same
	state["bg"].set_frame(presets[state["preset"]]["bgs"][randI(0, presets[state["preset"]]["bgs"].size())])
	state["bg"].set_flip_h(flpCoin())
	act("hide", ["goal"])
#	print(copyRange([22, 24, 0, 17])) # - Use to get the mem for any drawn tiles
	state["presetData"] = presets[state["preset"]]["prstData"]
	generateMap(state["layer0"], presets[state["preset"]]["map"])
#HANDLE ROUND END ----------------------------------------------------------------------------------------------
func roundEnd(survivorWin, survivorKilled):
	#Begin Round Cleanup; Hide everything, Reset Time, Delete all temporary bodies
	clear()
	handleEndSplash(survivorWin, survivorKilled)
	stopTimer()
	#Get the current survivorId and deathId; Print Round Details; Move to Next Round; Add the High Score for the Last Round
	print("Round "+str(state["round"])+" Ended; Preset was "+str(state["preset"])+"; Survivor is Player "+str(state["survivorId"])+", Death is Player "+str(state["deathId"])+", Survivor Win: "+str(survivorWin)+", Survivor Killed: "+str(survivorKilled)+".")
	state["round"] += 1
	state["roundTotal"] += 1
	addHighScore(state["survivorId"], survivorKilled)
	if survivorWin: #The Survivor Won, add score to survivor, set up new round
		addPoint(state["survivorId"])
	else: #The Survivor died or ran outta time, add score to death, set up new round
		addPoint(state["deathId"])
	if survivorKilled: #The Survivor Died, add score to death, switch everything around, set up new round
		switchSplashSwitch()
		state["player2Death"] = !state["player2Death"]
		state["survivorId"] = 2-int(state["player2Death"])
		state["deathId"] = 1+int(state["player2Death"])
		state["round"] = 1
	state["roundscore"].set_text("Round "+str(state["round"])+" - Player "+str(state["deathId"])+" is Death")
	setUp()
	act("show", ["switchsplash"])
#ROUND ENDING HELPERS ----------------------------------------------------------------------------------------------
func clear():
	for child in get_children():
		if child.is_type("KinematicBody2D") || child.is_type("RigidBody2D"):
			child.set_name("A")
			child.queue_free()
func reset():
	stopTimer()
	clear()
	setUp()
	act("show", ["switchsplash"])
func addPoint(id):
	state["playerScores"][int(id)-1] += 1
	state["score"+str(id)].set_text("Player "+str(id)+" Score: "+str(state["playerScores"][int(id)-1]))
func addHighScore(id, sk):
	if state["round"] > 1 && !sk && state["round"]-1 > state["playerScores"][1+int(id)]:
		state["playerScores"][1+int(id)] = state["round"]-1
		state["maxscore"+str(id)].set_text("Max Rounds Survived: "+str(state["playerScores"][1+int(id)]))
func startTimer():
	state["startTime"] = int(OS.get_ticks_msec()/1000) + presets[state["preset"]]["timeLength"]
	state["subg"].play("ticking")
	state["music"].play("bg"+str(presets[state["preset"]]["bgMusic"][randI(0, presets[state["preset"]]["bgMusic"].size())]))
func stopTimer():
	state["startTime"] = int(OS.get_ticks_msec())
	state["subg"].stop_all()
#	state["music"].stop_all()
func handleEndSplash(sw, sk):
	if sw:
		state["survivorwinsplash"].set_flip_h(!bool(state["player2Death"]))
		act("show", ["survivorwinsplash"])
	elif sk:
		state["deathkillsplash"].set_flip_h(bool(state["player2Death"]))
		act("show", ["deathkillsplash"])
	else:
		state["deathwinsplash"].set_flip_h(bool(state["player2Death"]))
		act("show", ["deathwinsplash"])
func switchSplashSwitch():
	state["switchsplash"].set_flip_h(!state["switchsplash"].is_flipped_h())
	state["switchsplash"].get_node("VSA2").set_hidden(!state["switchsplash"].get_node("VSA2").is_hidden())
	state["switchsplash"].get_node("VSB2").set_hidden(!state["switchsplash"].get_node("VSB2").is_hidden())
#GAME END HANDLING FUNCTIONS ----------------------------------------------------------------------------------------------
func handleSignal():
	act(state["signal"], ["tree"])
func giveSignal(sgnl): #Handle Tie Scores
	clear()
	stopTimer()
	var wonPlayer = 1;
	var addOn = "WON against"
	if state["playerScores"][1] > state["playerScores"][0]:
		wonPlayer = 2;
	elif state["playerScores"][1] == state["playerScores"][0]:
		addOn = "Tied with"
	var lostPlayer = int(!bool(wonPlayer-1))+1;
	state["endtext"].set_text("You two played a total of "+str(state["roundTotal"]-1)+" Rounds! Player "+str(wonPlayer)+" with a score of "+str(state["playerScores"][wonPlayer-1])+", "+addOn+" Player "+str(lostPlayer)+"'s score of "+str(state["playerScores"][lostPlayer-1])+".");
	addOn = " Also... "
	if state["playerScores"][wonPlayer+1] < state["playerScores"][lostPlayer+1]:
		addOn = " HOWEVER! "
		wonPlayer = lostPlayer
	lostPlayer = int(!bool(wonPlayer-1))+1;
	state["endtext"].set_text(state["endtext"].get_text()+addOn+"Player "+str(wonPlayer)+" had a highscore of "+str(state["playerScores"][wonPlayer+1])+" rounds, while player "+str(lostPlayer)+" had a highscore of "+str(state["playerScores"][lostPlayer+1])+" rounds.")
	act("popup", ["endpopup"])
	act("show", ["endtext", "endpopup", "splash"])
	state["signal"] = sgnl;
#MAP GENERATION FUNCTIONS & HELPERS ----------------------------------------------------------------------------------------------
func generateMap(map, prst):
	map.clear()
	fillSides(state["edges"][prst["edge"]])
	if prst["deadlyFloor"] && detectTileName([0, 31, 17, 17], "block"):
		fillRangeProb([1, 30, 16, 16], 0, .25)
	fillRanges(state["patterns"][prst["pattern"]])
	handleSurvivor(getIdxFromPos(presets[state["preset"]]["survivor"]["position"]), prst)
	if(presets[state["preset"]]["death"].has("teleportRange")): handleDeathTeleport(getIdxFromPos(presets[state["preset"]]["death"]["position"]), getIdxFromPos(presets[state["preset"]]["death"]["teleportRange"]), prst)
	# Add Death Teleport handling
	else: handleDeath(getIdxFromPos(presets[state["preset"]]["death"]["position"]), prst)
	if presets[state["preset"]]["survivor"].has("wincondition"):
		handleGoal(presets[state["preset"]]["survivor"]["wincondition"], prst)
		setPosCenter("goal", getPosFromIdxAlt(getXCenterFromRange(presets[state["preset"]]["survivor"]["wincondition"])))
		act("show", ["goal"])
	if prst.has("customPos"):
		for c in prst["customPos"]:
			setRange(attributeMem(c, customToMem(state["customs"][prst["custom"]])))
func fillSides(edges):
	for i in [1, 3, 0, 2]: # 0 -1 | 0 1 0 0 | [0, 31, 0, 0] Up # 1  0 | 1 1 0 1 | [31, 31, 0, 17] Right # 0  1 | 0 1 1 1 | [0, 31, 17, 17] Down # -1  0 | 0 0 0 1 | [0, 0, 0, 17] Left
		fillRange([31 if state["facing"][i].x == 1 else 0, 0 if state["facing"][i].x == -1 else 31, 17 if state["facing"][i].y == 1 else 0, 0 if state["facing"][i].y == -1 else 17], edges[i][randI(0, edges[i].size())])
func handleSurvivor(pos, prst):
	fillRanges([[[pos.x, pos.x, pos.y+1, pos.y+1], prst["survivorplatform"]], 
				[[pos.x-1, pos.x+1, pos.y-2, pos.y], -1]])
func handleDeath(pos, prst):
	fillRanges([[[pos.x-2, pos.x+2, pos.y-3, pos.y+1], prst["deathplatform"]],
				[[pos.x-1, pos.x+1, pos.y-2, pos.y], -1]])
func handleDeathTeleport(pos, rnge, prst):
	pass
func handleGoal(rnge, prst):
	fillRanges([[rnge, -1],
				[[rnge[0], rnge[1], rnge[3]+1, rnge[3]+1], prst["winplatform"]]])
#TILE/MAP HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func getTile(pos):
	return state["layer0"].get_cell(pos.x, pos.y)
func setTile(pos, idx):
	state["layer0"].set_cell(pos.x, pos.y, idx)
func setCell(x, y, idx):
	setTile(Vector2(x, y), idx)
func hasTile(pos):
	return getTile(pos) != -1
func cutTile(pos):
	var mem = getTile(pos)
	setTile(pos, -1)
	return mem
func getTileName(pos):
	return state["layer0"].get_tileset().tile_get_name(getTile(pos)) if hasTile(pos) else ""
func hasTileName(pos, name):
	return getTileName(pos).to_lower().find(name) != -1
func attributeRange(newPos, rnge):
	return [rnge[0]+(newPos.x - rnge[0]), rnge[1]+(newPos.x - rnge[0]), rnge[2]+(newPos.y - rnge[2]), rnge[3]+(newPos.y - rnge[2])]
func attributeMem(newPos, mem):
	var newMem = {}
	for key in mem:
		newMem[Vector2(key.x+newPos.x, key.y+newPos.y)] = mem[key]
	return newMem
func customToMem(cstm):
	var tiles = cstm.substr(1, cstm.length()-2).split("), (", false)
	var mem = {}
	for tile in tiles:
		mem[Vector2(tile.split(", ", false)[0].right(1).to_int(), tile.split(", ", false)[1].split("):", false)[0].to_int())] = tile.split(", ", false)[1].split("):", false)[1].to_int()
	return mem
func getRange(rnge, remove): # Range Memory returned is always normalized to start at (0, 0)
	var memory = {}
	for x in range(rnge[0], rnge[1]+1):
		for y in range(rnge[2], rnge[3]+1):
			memory[Vector2(x-rnge[0], y-rnge[2])] = getTile(Vector2(x, y)) if !remove else cutTile(Vector2(x, y))
	return memory
func setRange(memory):
	for key in memory:
		setTile(key, memory[key])
func copyRange(rnge):
	return getRange(rnge, false)
func cutRange(rnge):
	return getRange(rnge, true)
func pasteRange(mem, newPos):
	setRange(attributeMem(newPos, mem))
func moveRange(rnge, newPos):
	pasteRange(cutRange(rnge), newPos)
func slideRange(rnge, dir, dist):
	moveRange(rnge, dirDistToVec2(Vector2(rnge[0], rnge[2]), dir, dist))
func canMove(rnge, check):
	return !detectTileName(rnge, check)
func fillRanges(rnges):
	for rnge in rnges:
		fillRangeProbSkip(rnge[0], rnge[1], 1 if rnge.size() < 3 else rnge[2], 1 if rnge.size() < 4 else rnge[3], 1 if rnge.size() < 5 else rnge[4])
func fillRangeProbSkip(rnge, idx, prob, xSkip, ySkip):
	for x in range(rnge[0], rnge[1]+1, xSkip):
		for y in range(rnge[2], rnge[3]+1, ySkip):
			if flp(prob): setCell(x, y, idx)
func fillRangeProb(rnge, idx, prob):
	fillRangeProbSkip(rnge, idx, prob, 1, 1)
func fillRange(rnge, idx):
	fillRangeProb(rnge, idx, 1)
func getSlideAreaToDestroy(rnge, dir, dist, newPos):
	return [rnge[0] if dir.x == 0 else (max(newPos.x+rnge[1]-rnge[0]-dist+1, newPos.x) if dir.x == 1 else newPos.x), rnge[1] if dir.x == 0 else (newPos.x+rnge[1]-rnge[0] if dir.x == 1 else min(newPos.x+dist-1, newPos.x+rnge[1]-rnge[0])), rnge[2] if dir.y == 0 else (max(newPos.y+rnge[3]-rnge[2]-dist+1, newPos.y) if dir.y == 1 else newPos.y), rnge[3] if dir.y == 0 else (newPos.y+rnge[3]-rnge[2] if dir.y == 1 else min(newPos.y+dist-1, newPos.y+rnge[3]-rnge[2]))]
func detectTileName(rnge, name): #Finds a specific tile
	for x in range(rnge[0], rnge[1]+1):
		for y in range(rnge[2], rnge[3]+1):
			if hasTileName(Vector2(x, y), name):
				return true
	return false
func detectTiles(rnge): #Finds if there are any tiles in the general vicinity
	return detectTileName(rnge, "0")
func slideTiles(rnge, dir, dist, check):
	var oldPos = Vector2(rnge[0], rnge[2])
	var newPos = dirDistToVec2(oldPos, dir, dist)
	var areaToDestroy = getSlideAreaToDestroy(rnge, dir, dist, newPos)
	if canMove(areaToDestroy, check):
		var areaDestroyMem = copyRange(areaToDestroy)
		slideRange(rnge, dir, dist)
		pasteRange(areaDestroyMem, Vector2(rnge[1]-dist+1 if dir.x == -1 else rnge[0], rnge[3]-dist+1 if dir.y == -1 else rnge[2]))
		return newPos
	return oldPos
func moveGap(dir):
	state["presetData"] = attributeRange(slideTiles(state["presetData"], dir, 1, "spike"), state["presetData"])
#TILEMAP DEATH DETECTION HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func getTileKill(pos, dir):
	if !hasTile(pos): return ["", false, pos, dir]#, [false, false, false]]
	var cellName = getTileName(pos)
	var temp = ""
	if state["layer0"].is_cell_transposed(pos.x, pos.y):
		cellName = cellName.substr(1, cellName.length()).insert(3, cellName[0])
	if state["layer0"].is_cell_x_flipped(pos.x, pos.y):
		temp = cellName[1]
		cellName[1] = cellName[3]
		cellName[3] = temp
	if state["layer0"].is_cell_y_flipped(pos.x, pos.y):
		temp = cellName[0]
		cellName[0] = cellName[2]
		cellName[2] = temp
	return [cellName, int(cellName[dir]) == 1, pos, dir]
#TILEMAP MATH HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func dirDistToVec2(pos, dir, dist):
	return Vector2(pos.x+dir.x*dist, pos.y+dir.y*dist)
func setPosCenter(node, pos):
	state[node].set_pos(Vector2(pos.x-(state[node].get_size().x*state[node].get_scale().x)/2, pos.y-(state[node].get_size().y*state[node].get_scale().y)/2))
func getXCenterFromRange(rnge):
	return Vector2(float(rnge[0]+rnge[1])/2, rnge[2])
func getYCenterFromRange(rnge):
	return Vector2(rnge[0], float(rnge[2]+rnge[3])/2)
func getCenterFromRange(rnge):
	return Vector2(float(rnge[0]+rnge[1])/2, float(rnge[2]+rnge[3])/2)
func getIdxFromPos(pos):
	return state["layer0"].world_to_map(pos)
func getPosFromIdxAlt(pos):
	return Vector2(pos.x*60+30, pos.y*60+30)
func getPosFromIdx(idx):
	return getPosFromIdxCenter(idx, true)
func getPosFromIdxCenter(idx, center):
	var add = Vector2(0, 0)
	if center:
		add = Vector2(state["tileSize"]/2, state["tileSize"]/2)
	return state["layer0"].map_to_world(idx) + add
#GENERAL/PRESET HELPER FUNCTIONS ----------------------------------------------------------------------------------------------
func addSaw():
	add_child(preload("res://Projectiles/Saw/Saw.tscn").instance().init("Player "+str(state["deathId"])+"'s Saw", presets[state["preset"]]["death"]["saw"], state["deathId"]))
func controlGapUp():
	moveGap(state["facing"][0])
func controlGapRight():
	moveGap(state["facing"][1])
func controlGapDown():
	moveGap(state["facing"][2])
func controlGapLeft():
	moveGap(state["facing"][3])
func flpCoin(): randomize(); return bool(randI(0, 2))
func flp(cutoff): randomize(); return randf(0, 1) <= cutoff
func randI(a, b): randomize(); return int(randF(a, b))
func randF(a, b): randomize(); return rand_range(a, b)
func secToStep(s): return int((s*1000)/14.5)
func fx(sound): state["fx"].play(sound)
func s(s): return state[s]
func act(funct, args): for arg in args: state[arg].call(funct)
func na(): pass
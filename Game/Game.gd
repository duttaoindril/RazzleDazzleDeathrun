
extends Node
#SETUP
var state
var presets
#TODO
# - Figure out when to play sounds
func _ready():
	if OS.get_name() == "OSX":
		OS.set_borderless_window(false)
		OS.set_window_maximized(true)
	state = {"tree": get_tree(),
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
	"layer0": get_node("Layer0Map"),
	"bg": get_node("BG"),
	"music": get_node("BGMusic"),
	"subg": get_node("SubBGMusic"),
	"fx": get_node("FX")}
	presets = {0: {
		"timeLength": 60,
		"survivorTimeoutWin": false,
		"bgs": [0],
		"bgMusic": [1, 2, 3],
		"survivor": {
			"tileposition": Vector2(7, 16),
			"worldposition": getPosFromIdx(Vector2(7, 16)),
			"wincondition": [],
			"facing": Vector2(1, 0)
		},
		"death": {
			"tileposition": Vector2(29, 2),
			"worldposition": getPosFromIdx(Vector2(29, 2)),
			"static": true,
			"facing": Vector2(-1, 0)
		}
	}, 1: {
		"timeLength": 60,
		"survivorTimeoutWin": true,
		"bgs": [0],
		"bgMusic": [1, 2, 3],
		"survivor": {
			"tileposition": Vector2(7, 16),
			"worldposition": getPosFromIdx(Vector2(7, 16)),
			"wincondition": [],
			"facing": Vector2(1, 0)
		},
		"death": {
			"tileposition": Vector2(29, 2),
			"worldposition": getPosFromIdx(Vector2(29, 2)),
			"static": true,
			"facing": Vector2(-1, 0)
		}
	}}
	act("hide", ["deathwinsplash", "deathkillsplash", "survivorwinsplash", "endpopup"])
	act("show", ["splash", "survivorsplash", "deathsplash", "switchsplash"])
	state["subg"].play("start")
	state["music"].play("bg1")
	setUp()
	set_fixed_process(true)
	set_process_input(true)

func setUp():
	randomize() #New Randomgeneration Seed
	var lastPreset = state["preset"] #Store Last Preset
	state["preset"] = int(rand_range(0, presets.size())) #Get New Preset
	if bool(int(rand_range(0, 2))) && lastPreset == state["preset"]: state["preset"] = int(rand_range(0, presets.size())) #50% chance to reroll preset if last and new presets are the same
	state["bg"].set_frame(presets[state["preset"]]["bgs"][int(rand_range(0, presets[state["preset"]]["bgs"].size()))])
	state["bg"].set_flip_h(bool(int(rand_range(0, 2))))

func _fixed_process(delta):
	var seconds = state["startTime"]-int(OS.get_ticks_msec()/1000)
	state["roundtime"].set_text("%02d:%02d" % [int(seconds/60), int(seconds%60)])
	if seconds < 0:
		roundEnd(presets[state["preset"]]["survivorTimeoutWin"], false)

func roundEnd(survivorWin, survivorKilled):
	#Begin Round Cleanup; Hide everything, Reset Time, Delete all temporary bodies
	handleEndSplash(survivorWin, survivorKilled)
	stopTimer()
	clear()
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

func clear():
	for child in get_children():
		if child.is_type("KinematicBody2D") || child.is_type("RigidBody2D"):
			child.set_name("A")
			child.queue_free()

func addPoint(id):
	state["playerScores"][int(id)-1] += 1
	state["score"+str(id)].set_text("Player "+str(id)+" Score: "+str(state["playerScores"][int(id)-1]))

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

func addHighScore(id, sk):
	if state["round"] > 1 && !sk && state["round"]-1 > state["playerScores"][1+int(id)]:
		state["playerScores"][1+int(id)] = state["round"]-1
		state["maxscore"+str(id)].set_text("Max Rounds Survived: "+str(state["playerScores"][1+int(id)]))

func switchSplashSwitch():
	state["switchsplash"].set_flip_h(!state["switchsplash"].is_flipped_h())
	state["switchsplash"].get_node("VSA2").set_hidden(!state["switchsplash"].get_node("VSA2").is_hidden())
	state["switchsplash"].get_node("VSB2").set_hidden(!state["switchsplash"].get_node("VSB2").is_hidden())

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

func startTimer():
	state["startTime"] = int(OS.get_ticks_msec()/1000) + presets[state["preset"]]["timeLength"]
	state["subg"].play("ticking")
	state["music"].play("bg"+str(presets[state["preset"]]["bgMusic"][int(rand_range(0, presets[state["preset"]]["bgMusic"].size()))]))

func stopTimer():
	state["startTime"] = int(OS.get_ticks_msec())
	state["subg"].stop_all()
#	state["music"].stop_all()

func handleSignal():
	act(state["signal"], ["tree"])

func hasTile(pos):
	return state["layer0"].get_cell(pos.x, pos.y) != -1

func getTile(pos, dir):
	var ts = state["layer0"].get_tileset()
	var cellId = state["layer0"].get_cell(pos.x, pos.y)
	var cellName = ts.tile_get_name(state["layer0"].get_cell(pos.x, pos.y))
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
	return [cellName, int(cellName[dir]) == 1]

func getPosFromIdxCenter(idx, center):
	var add = Vector2(0, 0)
	if center:
		add = Vector2(state["tileSize"]/2, state["tileSize"]/2)
	return state["layer0"].map_to_world(idx) + add

func getPosFromIdx(idx):
	return getPosFromIdxCenter(idx, true)

func getIdxFromPos(pos):
	return state["layer0"].world_to_map(pos)

func reset():
	stopTimer()
	clear()
	setUp()
	act("show", ["switchsplash"])

func get(s):
	return state[s]

func act(funct, args):
	for arg in args:
		state[arg].call(funct)
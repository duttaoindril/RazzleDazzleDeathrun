extends Node

var player = preload("res://Player/Player.tscn")
var state
var lost_id
var win_id

func _ready():
	randomize()
	state = {
		"tileSize": get_node("Layer0Map").get_cell_size()[0],
		"width": get_viewport().get_rect().size[0],
		"height": get_viewport().get_rect().size[1],
		"mapWidth": get_viewport().get_rect().size[0]/get_node("Layer0Map").get_cell_size()[0],
		"mapHeight": get_viewport().get_rect().size[1]/get_node("Layer0Map").get_cell_size()[1],
		"splash": get_node("Splashscreen"),
		"bg": get_node("BG"),
		"score1bg": get_node("Panel1"),
		"score2bg": get_node("Panel2"),
		"score1": get_node("ScorePlayer1"),
		"score2": get_node("ScorePlayer2"),
		"music": get_node("Music"),
		"fx": get_node("FX"),
		"playerStates": [0, 1],
		"playerScores": [0, 0],
		"layer0": get_node("Layer0Map")
	}
	state["splash"].play("intro")
	act("show", ["splash"])
	set_process_input(true)
  
func setUp():
#	for i in range(1, 3):
#		var playerI = player.instance()
#		playerI.set_name("Player "+str(i))
#		playerI.set_pos(Vector2(state["width"]/3*i, state["height"]-100))
#		add_child(playerI)
	var playerI = player.instance()
	playerI.set_name("Player 1")
	playerI.set_pos(Vector2(state["width"]/3, state["height"]-100))
	add_child(playerI)

func clear():
	for child in get_children():
		if child.is_type("KinematicBody2D") || child.is_type("RigidBody2D"):
			child.set_name("A")
			child.queue_free()

func playerBeat(id,otherid):
	clear()
	win_id =(state["score"+otherid])+ 1
	setUp()

func _input(event):
	if event.is_action_pressed("action") && !state["splash"].is_hidden():
		if state["splash"].get_animation() == "intro":
			state["splash"].set_animation("survivor")
		elif state["splash"].get_animation() == "survivor":
			state["splash"].set_animation("death")
		elif state["splash"].get_animation() == "death":
			act("hide", ["splash"])
			state["splash"].set_animation("default")
			setUp()
	elif event.is_action_pressed("borderless"):
		OS.set_borderless_window(!OS.get_borderless_window())
	elif event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("restart"):
		get_parent().reset()
	elif event.is_action_pressed("quit"):
		get_tree().quit()

func act(funct, args):
	for arg in args:
		state[arg].call(funct)
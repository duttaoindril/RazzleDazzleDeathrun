extends Node

var player = preload("res://Player/Player.tscn")
var state

func _ready():
	randomize()
	state = {
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
		"mapWidth": 1920/60,
		"mapHeight": 1080/60,
		"layer0": get_node("Layer0Map")
	}
	state["splash"].play("intro")
	act("show", ["splash"])
	setUp()
	set_process_input(true)

func setUp():
	for i in range(1, 3):
		var playerI = player.instance()
		playerI.set_name("Player "+str(i))
		playerI.set_pos(Vector2(640*i, 980))
		add_child(playerI)

func clear():
	for child in get_children():
		if child.is_type("KinematicBody2D") || child.is_type("RigidBody2D"):
			child.set_name("A")
			child.queue_free()

func _input(event):
	if event.is_action_pressed("action"):
		if state["splash"].is_hidden():
			pass
		elif state["splash"].get_animation() == "intro":
			state["splash"].set_animation("survivor")
		elif state["splash"].get_animation() == "survivor":
			state["splash"].set_animation("death")
		elif state["splash"].get_animation() == "death":
			act("hide", ["splash"])
			state["splash"].set_animation("default")
		elif !state["splash"].is_hidden():
			pass
	if event.is_action_pressed("borderless"):
		OS.set_borderless_window(!OS.get_borderless_window())

func act(funct, args):
	for arg in args:
		state[arg].call(funct)
#		actDict(state[arg], funct)

func actDict(node, action):
	if action == "show":
		node.show()
	elif action == "hide":
		node.hide()
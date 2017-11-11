extends Node

var playerState = [0, 1]
var playerScores = [0, 0]
var mwidth = 30
var mheight = 17
var map
var intro

func _ready():
	map = get_node("Tiles")
	intro = get_node("Intro")
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("action"):
		if intro.is_hidden():
			pass
		elif intro.get_animation() == "default":
			intro.set_animation("survivor")
		elif intro.get_animation() == "survivor":
			intro.set_animation("death")
		elif intro.get_animation() == "death":
			intro.hide()
			intro.set_animation("default")
		elif !intro.is_hidden():
			pass
	if event.is_action_pressed("borderless"):
		OS.set_borderless_window(!OS.get_borderless_window())
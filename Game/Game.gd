extends Node

var playerScores = [0, 0]
var mwidth = 30
var mheight = 17
var map
var intro

func _ready():
	map = get_node("Tiles")
	intro = get_node("Intro")
	intro.show()
	intro.set_animation("intro")
	pass

func _input(event):
	if event.is_action_pressed("action"):
		if intro.is_hidden():
			pass
		elif intro.get_animation() == "intro":
			intro.set_animation("instruction")
		elif intro.get_animation() == "instruction":
			intro.hide()
			intro.set_animation("intro")
		elif !intro.is_hidden():
			pass
	if event.is_action_pressed("borderless"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())
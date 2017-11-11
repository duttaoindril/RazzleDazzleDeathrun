extends Node

func _ready():
	map = get_node("Tiles")
	intro = get_node("Intro")
	intro.show()
	intro.set_animation("intro")
	pass

func _input(event):
	if event.is_action_pressed("restart"):
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
	if event.is_action_pressed("fullscreen"):
		OS.set_borderless_window(!OS.get_borderless_window())
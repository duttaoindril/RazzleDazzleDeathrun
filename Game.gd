extends Node

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
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
	if event.is_action_pressed("toggleFView"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())
	if event.is_action_pressed("toggleBView"):
		OS.set_borderless_window(!OS.get_borderless_window())
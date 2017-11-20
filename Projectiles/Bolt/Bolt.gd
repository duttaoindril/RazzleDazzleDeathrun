extends KinematicBody2D
#SETUP/Global/Constants
var PROJECTILE_SPEED = 800
var dir = Vector2()
var check = 1
#ON INSTANCE RUN ---------------------------------------------------------------------------------------------
func _ready():
	set_pos(Vector2(-100, -100))
#FIRE BULLET ---------------------------------------------------------------------------------------------
func fire(position, direction, anti):
	check = anti
	dir = direction.normalized()
	get_node("BoltSprite").set_flip_h(dir.x+1)
	set_pos(Vector2(position.x+dir.x*60, position.y))
	set_fixed_process(true)
#ON INSTANCE RUN ---------------------------------------------------------------------------------------------
func _fixed_process(delta):
	move(dir*PROJECTILE_SPEED*delta)
	if !get_viewport_rect().has_point(get_pos()):
		queue_free()
	for body in get_node("BoltBody").get_overlapping_bodies():
		if body.get_name() == "Player "+str(check):
			body.death()
			queue_free()
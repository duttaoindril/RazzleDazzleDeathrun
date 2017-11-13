extends KinematicBody2D

#PRE SETUP
var velocity = Vector2()
var speed = 1
var gravity = .2

func _ready():
    set_fixed_process(true)
    pass

func _fixed_process(delta):
    
    var force = get_global_pos()

#LEFT AND RIGHT CONTROLS
    if Input.is_action_pressed("ui_left"):
        velocity.x -= speed #* force.x
        pass
    elif Input.is_action_pressed("ui_right"):
        velocity.x += speed #* force.x
        pass
    else:
        pass

#JUMP CODE
    if Input.is_action_pressed("ui_accept"):
        #velocity.y -= gravity * 5
        velocity.y = gravity * -25
        if (is_colliding()) and test_move(Vector2(0,1)):
            velocity.y -= gravity * 5
        else:
            pass

#Collision Detection to stop gravity when landing
    if !(is_colliding()):
        velocity.y += gravity
    else:
        velocity.y = 0

    var dampen = 0.8

#USING DELTA TO GIVE NATURAL GRAVITY AND MAKING OBJECT MOVE AFTER USING VELOCITY.
    velocity += velocity * delta
    velocity.x *= dampen

    move(velocity)


#USING A TECHNIQUE CALLED "SLIDING" IT ALLOWS THE OBJECT TO MOVE ON SLOPES AND SLIDE ALONG WALLS.
#HOPEFULLY USEFUL TO PREVENT STICKING ON TILESETS.
    if (is_colliding()):
        var n = get_collision_normal()
        velocity = n.slide(velocity)
        move(velocity)
    else:
        pass

    if (is_colliding()):
        if get_collider().is_in_group("Arrow"):
            print("Damage!")
        else:
            pass
    else:
        pass

    pass
extends StaticBody2D

var body_type = Globals.BodyType.BOX

var number = 1
var speed = 10
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    number = int(rand_range(1, 9))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

#func _physics_process(delta):
#    t += delta
#    position.y -= speed * delta * cos(t/5.0)

func on_ball_collision():
    number -= 1
    if number < 1:
        queue_free()


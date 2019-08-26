extends RigidBody2D

var body_type = Globals.BodyType.BALL

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("body_entered", self, "on_body_entered")
    $LifeTimer.connect("timeout", self, "on_lifetimer_timeout")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func on_body_entered(body):
    print("collision : ", body.name)
    if body.body_type == Globals.BodyType.BOX:
        body.on_ball_collision()

func SetLifeTimer(t):
    $LifeTimer.wait_time = t
    $LifeTimer.start()

func on_lifetimer_timeout():
    queue_free()


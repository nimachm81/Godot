extends RigidBody2D

var body_type = Globals.BodyType.BALL
var body_color

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    connect("body_entered", self, "on_body_entered")
    $LifeTimer.connect("timeout", self, "on_lifetimer_timeout")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func MakeTestBall():
    body_type = Globals.BodyType.TESTBALL
    
func set_ball_color(color):
    body_color = color
    if color == Globals.COLORS.RED:
        $Sprite.texture = load("res://Ball/images/ball_red.png")
        set_collision_layer_bit(Globals.LayersBits["red_ball"], true)
        set_collision_mask_bit(Globals.LayersBits["green_box"], true)
        set_collision_mask_bit(Globals.LayersBits["blue_box"], true)
    elif color == Globals.COLORS.GREEN:
        $Sprite.texture = load("res://Ball/images/ball_green.png")
        set_collision_layer_bit(Globals.LayersBits["green_ball"], true)
        set_collision_mask_bit(Globals.LayersBits["red_box"], true)
        set_collision_mask_bit(Globals.LayersBits["blue_box"], true)
    elif color == Globals.COLORS.BLUE:
        $Sprite.texture = load("res://Ball/images/ball_blue.png")
        set_collision_layer_bit(Globals.LayersBits["blue_ball"], true)
        set_collision_mask_bit(Globals.LayersBits["green_box"], true)
        set_collision_mask_bit(Globals.LayersBits["red_box"], true)
    else:
        assert false

func on_body_entered(body):
    print("collision : ", body.name)
    if body.body_type == Globals.BodyType.BOX:
        body.on_ball_collision()

func SetLifeTimer(t):
    $LifeTimer.wait_time = t
    $LifeTimer.start()

func on_lifetimer_timeout():
    queue_free()

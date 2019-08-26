extends StaticBody2D

var body_type = Globals.BodyType.BOX

var number = 1
var speed = 10
var t = 0

var colors = [Globals.COLORS.RED, Globals.COLORS.GREEN, Globals.COLORS.BLUE]

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    number = int(rand_range(1, 9))
    
    set_box_color(colors[randi() % 3])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

#func _physics_process(delta):
#    t += delta
#    position.y -= speed * delta * cos(t/5.0)


func set_box_color(color):
    if color == Globals.COLORS.RED:
        $Sprite.texture = load("res://Box/images/redbox.png")
    elif color == Globals.COLORS.GREEN:
        $Sprite.texture = load("res://Box/images/greenbox.png")
    elif color == Globals.COLORS.BLUE:
        $Sprite.texture = load("res://Box/images/bluebox.png")
    else:
        assert false

func on_ball_collision():
    number -= 1
    if number < 1:
        queue_free()






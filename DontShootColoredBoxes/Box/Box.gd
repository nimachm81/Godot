extends StaticBody2D

var body_type = Globals.BodyType.BOX
var body_color

var number = 1
var speed = 10
var t = 0


# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    number = int(rand_range(1, 9))
    $Area2D.connect("body_entered", self, "area2d_on_body_entered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

#func _physics_process(delta):
#    t += delta
#    position.y -= speed * delta * cos(t/5.0)


func set_box_color(color):
    body_color = color
    if color == Globals.COLORS.RED:
        $Sprite.texture = load("res://Box/images/redbox.png")
        set_collision_layer_bit(Globals.LayersBits["red_box"], true)
        $Area2D.set_collision_mask_bit(Globals.LayersBits["red_ball"], true)
    elif color == Globals.COLORS.GREEN:
        $Sprite.texture = load("res://Box/images/greenbox.png")
        set_collision_layer_bit(Globals.LayersBits["green_box"], true)
        $Area2D.set_collision_mask_bit(Globals.LayersBits["green_ball"], true)
    elif color == Globals.COLORS.BLUE:
        $Sprite.texture = load("res://Box/images/bluebox.png")
        set_collision_layer_bit(Globals.LayersBits["blue_box"], true)
        $Area2D.set_collision_mask_bit(Globals.LayersBits["blue_ball"], true)
    else:
        assert false

func on_ball_collision():
    pass

func area2d_on_body_entered(body):
    print(self.name, ": entered by ", body.name)
    if body.body_type == Globals.BodyType.BALL:
        if body.body_color == body_color:
            queue_free()
    
    





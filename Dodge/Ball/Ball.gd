extends RigidBody2D

export var min_speed = 150  # Minimum speed range.
export var max_speed = 250  # Maximum speed range.
var mob_types = ["ball_red", "ball_blue", "ball_green"]

var rotation_speed = 10;

var objtype_id = 1
var ballColor

# Called when the node enters the scene tree for the first time.
func _ready():
    #set_continuous_collision_detection_mode(1)
    #contact_monitor = true
    #contacts_reported = 2
    #connect("body_entered", self, "_on_body_entered")
    ballColor = randi() % mob_types.size()
    $Sprite.texture = load("res://Ball/images/" + mob_types[ballColor] + ".png")
    $RotationTimer.connect("timeout", self, "on_rotation_timedout")
    rotation_speed = rand_range(0, 180)
    $RotationTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#    pass

func _on_Visibility_screen_exited():
    queue_free()

func _on_start_game():
    queue_free()

#func _on_body_entered():
#    print("Mob was hit!")
#    hide()
#    $CollisionShape2D.set_disabled(true)
#    queue_free()

func on_rotation_timedout():
    rotation_degrees = int(rotation_degrees + rotation_speed) % 360


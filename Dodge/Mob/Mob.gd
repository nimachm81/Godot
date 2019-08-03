extends RigidBody2D

export var min_speed = 150  # Minimum speed range.
export var max_speed = 250  # Maximum speed range.
var mob_types = ["walk", "swim", "fly"]

var objtype_id = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    #contact_monitor = true
    #contacts_reported = 2
    #connect("body_entered", self, "_on_body_entered")
    $AnimatedSprite.animation = mob_types[randi() % mob_types.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    $AnimatedSprite.play()

func _on_Visibility_screen_exited():
    queue_free()

func _on_start_game():
    queue_free()

func _on_body_entered():
    print("Mob was hit!")
    hide()
    $CollisionShape2D.set_disabled(true)
    queue_free()

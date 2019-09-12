extends RigidBody2D


enum {HAPPY, EXCITED, ANGRY}
var state = HAPPY

var is_rolling = false
var collision_timer_started = false
var n_collisions = 0
var height = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    $LifeTimer.connect("timeout", self, "on_life_timeout")
    connect("body_entered", self, "on_body_collision")
    $CollisionTimer.connect("timeout", self, "on_collision_timer_timeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func StartLifeTimer(t):
    $LifeTimer.start(t)

func on_life_timeout():
    queue_free()

func on_body_collision(body):
    #print("ball collision")
    if not is_rolling:
        n_collisions += 1
        $HitSound.volume_db -= 3
        if not collision_timer_started:
            height = position.y
            $HitSound.play()
            $CollisionTimer.start()
            collision_timer_started = true
        if n_collisions > 1:
            if abs(position.y - height) < 5:
                is_rolling = true
        
    if state != ANGRY:
        state = ANGRY
        $Sprite.texture = load("res://Ball/images/ball_angry.png")


func on_collision_timer_timeout():
    collision_timer_started = false
    n_collisions = 0
    
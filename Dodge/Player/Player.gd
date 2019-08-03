extends Area2D

signal hit

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var velocity = Vector2()  # The player's movement vector.
var target = Vector2() # Holds the clicked position

var objtype_id = 0
var hitState = false

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("body_entered", self, "_on_Player_body_entered")
    screen_size = get_viewport_rect().size
    hide()

# Change the target whenever a touch event happens.
func _input(event):
    if event is InputEventScreenTouch and event.pressed:
        target = event.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # Move towards the target and stop when close.
    if position.distance_to(target) > 10:
        velocity = (target - position).normalized() * speed
    else:
        velocity = Vector2()

#    if Input.is_action_pressed("ui_right"):
#        velocity.x += 1
#    if Input.is_action_pressed("ui_left"):
#        velocity.x -= 1
#    if Input.is_action_pressed("ui_down"):
#        velocity.y += 1
#    if Input.is_action_pressed("ui_up"):
#        velocity.y -= 1

    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
        $AnimatedSprite.play()
    else:
        $AnimatedSprite.stop()
    if velocity.x != 0:
        $AnimatedSprite.animation = "right"
        $AnimatedSprite.flip_v = false
        # See the note below about boolean assignment
        $AnimatedSprite.flip_h = velocity.x < 0
    elif velocity.y != 0:
        $AnimatedSprite.animation = "up"
        $AnimatedSprite.flip_v = velocity.y > 0
	
    position += velocity * delta
    position.x = clamp(position.x, 0, screen_size.x)
    position.y = clamp(position.y, 0, screen_size.y)


func _on_Player_body_entered(body):
    print("Player was hit by ", body.name)
    if body.objtype_id == 1:
        body.hide()
        body.queue_free()
    if !hitState:
        emit_signal("hit")
        hitState = true
        $hitSound.play()
        modulate.a = 0.5
        $hitTimer.start()
        yield($hitTimer, "timeout")
        modulate.a = 1.0
        hitState = false

func on_player_dead():
    hide()  # Player disappears after being hit.
    $CollisionShape2D.set_deferred("disabled", true)    

func start(pos):
    position = pos
    target = pos
    show()
    $CollisionShape2D.disabled = false
    hitState = false
	

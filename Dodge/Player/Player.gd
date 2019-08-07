extends Area2D

var BULLET = preload("res://Bullet/Bullet.tscn")

signal hit

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var velocity = Vector2()  # The player's movement vector.
var target = Vector2() # Holds the clicked position

var armed_mode = false
var bullet_speed = 800

var objtype_id = 0
var hitState = false

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("body_entered", self, "_on_Player_body_entered")
    connect("area_entered", self, "_on_Player_area_entered")
    $BulletTimer.connect("timeout", self, "on_bullet_timeout")
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
        rotation = atan2(velocity.y, velocity.x)
    else:
        $AnimatedSprite.stop()
    $AnimatedSprite.animation = "right"
    
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
        modulate.a = 0.3
        $hitTimer.start()
        yield($hitTimer, "timeout")
        modulate.a = 1.0
        hitState = false

func _on_Player_area_entered(area):
    print("Player was hit by ", area.name)
    if area.objtype_id == 4:    #ammo
        $BulletTimer.start()
        $AmmoSound.play()
        var oldColor = get_node("/root/Main/ColorRect").color
        get_node("/root/Main/ColorRect").color = Color(0.5, 0.5, 0.5, 1)
        yield(get_tree().create_timer(10), "timeout")
        $BulletTimer.stop()
        get_node("/root/Main/ColorRect").color = oldColor

func on_player_dead():
    hide()  # Player disappears after being hit.
    $CollisionShape2D.set_deferred("disabled", true)    
    $BulletTimer.stop()

func start(pos):
    position = pos
    target = pos
    show()
    $CollisionShape2D.disabled = false
    hitState = false

func SpawnBullets(pos, vel):
    var bullet = BULLET.instance()
    bullet.position = pos
    bullet.velocity = vel
    get_parent().add_child(bullet)

func on_bullet_timeout():
    #print("spawnin bullets - pos:", position)
    if velocity.length() > 0:
        SpawnBullets(position, velocity.normalized() * bullet_speed)
extends Node2D

var SHOOTER = preload("res://Shooter/Shooter.tscn")
var BOX = preload("res://Box/Box.tscn")
var BALL = preload("res://Ball/Ball.tscn")

var n_boxes
var screenSize

var boxZone
var boxGrid
var boxWidth

var shooterZone
var ballTargetZone

var shooter
var ballTarget
var ballSpeed = 1000
var trajectoryLifetime = 0.5

enum {TOUCH_PRESSED, TOUCH_RELEASED, TOUCH_DRAG}
var touchState = TOUCH_RELEASED

func _ready():
    screenSize = get_viewport_rect().size
    SetupBoxGrid()
    
    shooter = SHOOTER.instance()
    shooter.position = shooterZone.position + Vector2(rand_range(0, shooterZone.size.x), rand_range(0, shooterZone.size.y))
    add_child(shooter)
    
    $TrajectoryTimer.connect("timeout", self, "on_trajectory_timer_timeout")
    
    var box_original_size = BOX.instance().get_node("CollisionShape2D").shape.extents * 2
    for i in range(boxGrid.x):
        for j in range(boxGrid.y):
            var box = BOX.instance()
            box.position = boxZone.position + Vector2(i*boxWidth + boxWidth/2, j*boxWidth + boxWidth/2)
            var original_size = box_original_size #box.get_node("CollisionShape2D").shape.extents * 2
            print(original_size, " ", boxWidth)
            box.get_node("Sprite").scale = Vector2(boxWidth / original_size.x, boxWidth / original_size.y)
            box.get_node("CollisionShape2D").shape.extents = Vector2(boxWidth/2, boxWidth/2)
            add_child(box)


func _input(event):
    if event is InputEventScreenTouch:
        print("touch input: ", event.position)
        if event.pressed:
            touchState = TOUCH_PRESSED
            if shooterZone.has_point(event.position):
                shooter.position = event.position
            elif ballTargetZone.has_point(event.position):
                ballTarget = event.position
                $TrajectoryTimer.start()
        else:
            print("touch released")
            touchState = TOUCH_RELEASED
            if ballTargetZone.has_point(event.position):
                $TrajectoryTimer.stop()
                ShootTheBall()
    if touchState == TOUCH_PRESSED and event is InputEventMouseMotion:
        print("Mouse drag motion: ", event.position)
        if ballTargetZone.has_point(event.position):
            ballTarget = event.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func SetupBoxGrid():
    var n_col = 12
    var box_width = int(screenSize.x / n_col)
    boxWidth = box_width
    
    var n_top = 3
    var n_bot = 3
    var n_row = int(screenSize.y/box_width) - (n_top + n_bot)
    
    var x_0 = int((screenSize.x - n_col * box_width) / 2)
    var y_0 = n_top * box_width
    
    boxZone = Rect2(Vector2(x_0, y_0), Vector2(n_col*box_width, n_row*box_width))
    boxGrid = Vector2(n_col, n_row)

    shooterZone = Rect2(Vector2(0, screenSize.y - (n_bot - 1)*box_width), Vector2(screenSize.x, (n_bot - 1)*box_width))
    ballTargetZone = Rect2(Vector2(0, y_0), Vector2(screenSize.x, shooterZone.position.y - y_0 - 1))
    

func ShootTheBall():
    var ball = BALL.instance()
    ball.contact_monitor = true
    ball.contacts_reported = 3
    ball.set_continuous_collision_detection_mode(RigidBody2D.CCD_MODE_CAST_SHAPE)
    ball.position = shooter.position
    ball.linear_velocity = (ballTarget - shooter.position).normalized() * ballSpeed
    ball.SetLifeTimer(5)
    add_child(ball)

func ShootTrajectory():
    var ball = BALL.instance()
    ball.position = shooter.position
    ball.linear_velocity = (ballTarget - shooter.position).normalized() * ballSpeed
    ball.SetLifeTimer(trajectoryLifetime)
    ball.get_node("Sprite").scale *= 0.3
    add_child(ball)
    
func on_trajectory_timer_timeout():
    ShootTrajectory()


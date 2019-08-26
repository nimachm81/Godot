extends Node2D

var SHOOTER = preload("res://Shooter/Shooter.tscn")
var BOX = preload("res://Box/Box.tscn")
var BALL = preload("res://Ball/Ball.tscn")

var n_boxes = 20
var screenSize
var boxArea
var shooterArea
var ballTargetArea

var shooter
var ballTarget
var ballSpeed = 1000
var trajectoryLifetime = 0.5

enum {TOUCH_PRESSED, TOUCH_RELEASED, TOUCH_DRAG}
var touchState = TOUCH_RELEASED

func _ready():
    screenSize = get_viewport_rect().size
    boxArea = Rect2(Vector2(0, 0.2*screenSize.y), Vector2(screenSize.x, 0.5*screenSize.y))
    ballTargetArea = Rect2(Vector2(0, 0.2*screenSize.y), Vector2(screenSize.x, 0.6*screenSize.y))
    shooterArea = Rect2(Vector2(0, 0.8*screenSize.y), Vector2(screenSize.x, 0.2*screenSize.y))
    
    shooter = SHOOTER.instance()
    shooter.position = shooterArea.position + Vector2(rand_range(0, shooterArea.size.x), rand_range(0, shooterArea.size.y))
    add_child(shooter)
    
    $TrajectoryTimer.connect("timeout", self, "on_trajectory_timer_timeout")
    
    for i in range(n_boxes):
        var box = BOX.instance()
        box.position = boxArea.position + Vector2(rand_range(0, boxArea.size.x), rand_range(0, boxArea.size.y));
        add_child(box)


func _input(event):
    if event is InputEventScreenTouch:
        print("touch input: ", event.position)
        if event.pressed:
            touchState = TOUCH_PRESSED
            if shooterArea.has_point(event.position):
                shooter.position = event.position
            elif ballTargetArea.has_point(event.position):
                ballTarget = event.position
                $TrajectoryTimer.start()
        else:
            print("touch released")
            touchState = TOUCH_RELEASED
            if ballTargetArea.has_point(event.position):
                $TrajectoryTimer.stop()
                ShootTheBall()
    if touchState == TOUCH_PRESSED and event is InputEventMouseMotion:
        print("Mouse drag motion: ", event.position)
        if ballTargetArea.has_point(event.position):
            ballTarget = event.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func ShootTheBall():
    var ball = BALL.instance()
    ball.contact_monitor = true
    ball.contacts_reported = 3
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


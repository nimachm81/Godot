extends Node2D

var BALL = preload("res://Ball/Ball.tscn")
var BASKET = preload("res://Basket/Basket.tscn")
var PLATFORM = preload("res://Platform/Platform.tscn")
var BODY = preload("res://Body/Body.tscn")

var ball
var ball_position
var basket
var platform
var player

enum {TOUCH_PRESSED, TOUCH_RELEASED, TOUCH_DRAG}
var touchState = TOUCH_RELEASED

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    InstantiateElements()
    AdjustSizez()
    $NextBallTimer.connect("timeout", self, "on_nexballtimer_timeout")
    PrepareNewBall()
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func InstantiateElements():
    platform = PLATFORM.instance()
    add_child(platform)
    player = BODY.instance()
    add_child(player)
    PrepareNewBasket()

func AdjustSizez():
    AdjustBackgrooud()
    AdjustPlatform()
    setup_background_mountain()
    setup_background_tree()
    AdjustBasket()
    AdjustPlayer()

func AdjustBackgrooud():
    var texture_size = $Background.texture.get_size()
    var screen_size = Globals.screen_size
    
    $Background.position = screen_size / 2
    $Background.scale = Vector2(screen_size.x/texture_size.x, screen_size.y/texture_size.y)
    
func AdjustPlatform():
    var texture_size = platform.get_node("Sprite").texture.get_size()
    var screen_size = Globals.screen_size
    
    print("texture_size : ", texture_size, " " , platform.position)
    
    var r0 = Vector2(0, 0.9*screen_size.y)
    var r1 = screen_size
    var rec_size = r1 - r0
    
    platform.position = (r0 + r1)/2
    platform.get_node("Sprite").scale = Vector2(rec_size.x/texture_size.x, rec_size.y/texture_size.y)
    platform.get_node("CollisionShape2D").shape.extents = rec_size/2
    

func AdjustPlayer():
    #player.mode = RigidBody2D.MODE_STATIC
    var screen_size = Globals.screen_size
    var platform_top = platform.position.y - platform.get_node("CollisionShape2D").shape.extents.y
    player.position = Vector2(0.2*screen_size.x, platform_top - Globals.player_base_to_center_distance)
    
func AdjustBasket():
    var screen_size = Globals.screen_size
    var platform_top = platform.position.y - platform.get_node("CollisionShape2D").shape.extents.y
    var bv_sprite_pos = basket.get_node("BaseVSprite").position
    var bv_size = basket.get_node("BaseVSprite").texture.get_size()
    var bv_y0 = -10    #local coordinates
    var bv_y1 = platform_top - basket.position.y    #local coordinates
    basket.get_node("BaseVSprite").position.y = (bv_y0 + bv_y1)/2
    basket.get_node("BaseVSprite").scale.y = (bv_y1 - bv_y0)/bv_size.y

func PrepareNewBall():
    ball = BALL.instance()
    SetInitialBallPosition()
    SetBallPosition(ball_position)
    ball.bounce = 0.5
    ball.mode = RigidBody2D.MODE_STATIC
    print("mode static")
    add_child(ball)
    ball.connect("input_event", self, "on_ball_input_event")
    ball.input_pickable = true
    

func PrepareNewBasket():
    var basket_position = Vector2(600, 200)
    basket = BASKET.instance()
    basket.position = basket_position
    add_child(basket)    

func on_ball_input_event(viewport, event, shape_idx):
    #print("ball input event")
    if event is InputEventScreenTouch:
        if event.pressed:
            print("touch pressed")
            touchState = TOUCH_PRESSED
            ball.get_node("Sprite").texture = load("res://Ball/images/ball_excited.png")
        else:
            print("touch released")
            touchState = TOUCH_RELEASED
            ball.input_pickable = false
            ball.set_mode(RigidBody2D.MODE_RIGID)
            print("mode rigid")
            var velocity = 10*(ball_position - ball.position)
            print("v : ", velocity)
            ball.linear_velocity = velocity
            ball.contact_monitor = true
            ball.contacts_reported = 1
            ball.StartLifeTimer(9)
            $NextBallTimer.start(10)
            player.MoveHandTowardsInitialPosition()
    if touchState == TOUCH_PRESSED and event is InputEventMouseMotion:
        #print("Mouse drag motion: ", event.position)
        SetBallPosition(event.position)

func SetBallPosition(pos):
    ball.position = pos
    var hand_position = pos + Vector2(0, ball.get_node("Sprite").get_rect().size.y/2 * ball.get_node("Sprite").scale.y)
    var hand_pos_local = hand_position - player.position 
    player.SetHandPosition(hand_pos_local)

func SetInitialBallPosition():
    ball_position = player.position + player.neck_position - \
        Vector2(0, ball.get_node("Sprite").get_rect().size.y/2 * ball.get_node("Sprite").scale.y)

func on_nexballtimer_timeout():
    PrepareNewBall()

func setup_background_mountain():
    var screen_size = Globals.screen_size
    var platform_top = platform.position.y - platform.get_node("CollisionShape2D").shape.extents.y
    var mount_scale = Vector2(2.0, 1.6)

    var mount_sprite = Sprite.new()
    var mount_ind = int(rand_range(0, len(Globals.mount_names))) % len(Globals.mount_names)
    mount_sprite.texture = load(Globals.mount_names[mount_ind])
    mount_sprite.position.y = platform_top - mount_sprite.get_rect().size.y/2 * mount_scale.y
    mount_sprite.position.x = screen_size.x * 6 / 7
    mount_sprite.scale = mount_scale
    add_child_below_node(platform, mount_sprite)

func setup_background_tree():
    var screen_size = Globals.screen_size
    var platform_top = platform.position.y - platform.get_node("CollisionShape2D").shape.extents.y
    var tree_scale = Vector2(1.0, 1.0)

    var tree_sprite = Sprite.new()
    var tree_ind = int(rand_range(0, len(Globals.tree_names))) % len(Globals.tree_names)
    tree_sprite.texture = load(Globals.tree_names[tree_ind])
    tree_sprite.position.y = platform_top - tree_sprite.get_rect().size.y/2 * tree_scale.y
    tree_sprite.position.x = screen_size.x * 1 / 20
    tree_sprite.scale = tree_scale
    add_child_below_node(platform, tree_sprite)

extends RigidBody2D

var neck_position
var arm_size_0

# Called when the node enters the scene tree for the first time.
func _ready():
    GetInitialArmSize()
    SetNeckPosition()
    SetHandPosition(neck_position + Vector2(100, 50))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func GetInitialArmSize():
    arm_size_0 = $ArmSprite.get_rect().size

func SetNeckPosition():
    var torso_pos = $TorsoSprite.position
    neck_position = torso_pos + Vector2(0, -$TorsoSprite.get_rect().size.y/2 - $HandSprite.get_rect().size.y/2)
    print("neck_position: ", neck_position)
    
func SetHandPosition(pos):
    $HandSprite.position = pos
    var arm_pos_0 = neck_position + Vector2(0, 5)
    var arm_pos_1 = pos + Vector2(0, 5)
    if arm_pos_0.x < arm_pos_1.x:
        arm_pos_0.x -= 5
    var arm_size = arm_pos_1 - arm_pos_0
    var arm_pos = (arm_pos_0 + arm_pos_1)/2.0
    var rot = atan2(arm_size.y, arm_size.x)
    var arm_scale = Vector2(-(arm_size.length()/arm_size_0.x), 1)
    if abs(arm_scale.x) < 0.1:
        arm_scale.y *= abs(arm_scale.x)
    #print("Arm pos: ", arm_pos, " scale: ", arm_scale, " rot: ", rot)
    $ArmSprite.position = arm_pos
    $ArmSprite.scale = arm_scale
    $ArmSprite.rotation = rot
    
func MoveHandTowardsInitialPosition():
    var direction = (neck_position - $HandSprite.position).normalized()
    while $HandSprite.position != neck_position:
        SetHandPosition($HandSprite.position + 5*direction)
        if ($HandSprite.position - neck_position).length() < 7:
            SetHandPosition(neck_position)


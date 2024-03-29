extends Node2D

var f_max_body = 200
var f_max_head = 50
var f_max_leg = 300
var f_max_arm = 200

var torque_scale = 20
var tau_max_body = 200
var tau_max_head = 100
var tau_max_leg = 400
var tau_max_arm = 200

var headPosition = Vector2()

var numOfBodyparts = 12
var maxNumOfTiles = 20
var numOfInputs = 3*numOfBodyparts + 2*maxNumOfTiles + 2 + 1        ## 3:position(2), angular velocity(1), 2: body's linear velocity, 1: bias
var numOfOutputs = numOfBodyparts                             ## torque for each body part

var neuralNet = null
var gravity_scale = 2

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    SetGravityScale(gravity_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    #moveRandomly()
    #PrintHeadPosition()
    yield(get_tree().create_timer(0.1), "timeout")
    ApplyNeuralNetOutputs()

func SetGravityScale(scale):
    $Body.gravity_scale = scale
    $Head.gravity_scale = scale
    $ArmR.gravity_scale = scale
    $ArmL.gravity_scale = scale 
    $ElbowR.gravity_scale = scale
    $ElbowL.gravity_scale = scale
    $LegR.gravity_scale = scale
    $LegL.gravity_scale = scale
    $LegR2.gravity_scale = scale
    $LegL2.gravity_scale = scale 
    $FootR.gravity_scale = scale
    $FootL.gravity_scale = scale

func applyRandomForce(bodyPart, f_max, tau_max, torque_only=true):
    if not torque_only:
        var f_x = rand_range(-f_max, f_max)
        var f_y = rand_range(-f_max, f_max)
        bodyPart.apply_central_impulse(Vector2(f_x, f_y))
    var tau = rand_range(-tau_max, tau_max) * torque_scale
    bodyPart.apply_torque_impulse(tau)
    
func moveRandomly():
    applyRandomForce($Body, f_max_head, tau_max_head)
    applyRandomForce($Head, f_max_head, tau_max_head)
    applyRandomForce($LegR, f_max_leg, tau_max_leg)
    applyRandomForce($LegR2, f_max_leg, tau_max_leg)
    applyRandomForce($LegL, f_max_leg, tau_max_leg)
    applyRandomForce($LegL2, f_max_leg, tau_max_leg)
    applyRandomForce($ArmR, f_max_arm, tau_max_arm)
    applyRandomForce($ElbowR, f_max_arm, tau_max_arm)
    applyRandomForce($ArmL, f_max_arm, tau_max_arm)
    applyRandomForce($ElbowL, f_max_arm, tau_max_arm)
    
func PrintHeadPosition():
    var pos = $Head.position
    if (pos - headPosition).length() > 20:
        print("Head position: ", pos, " , Robot position: ", position)
        headPosition = pos
        
        #print(GetBodyPartsLinearVelocityInArray())
    
func GetTilePositionsRelativeToBody():
    var pos = position + $Body.position
    return get_parent().GetTileCellsAroundPoint(pos, Vector2(10, 10))
        
func GetBodyPartsPositionsInArray():
    return [$Body.position, $Head.position, $ArmR.position, $ArmL.position, 
            $ElbowR.position, $ElbowL.position, $LegR.position, $LegL.position,
            $LegR2.position, $LegL2.position, $FootR.position, $FootL.position]
    
func GetBodyPartsLinearVelocityInArray():
    return [$Body.linear_velocity]
    
func GetBodyPartsAngularVelocityInArray():
    return [$Body.angular_velocity, $Head.angular_velocity, $ArmR.angular_velocity, $ArmL.angular_velocity,
            $ElbowR.angular_velocity, $ElbowL.angular_velocity, $LegR.angular_velocity, $LegL.angular_velocity,
            $LegR2.angular_velocity, $LegL2.angular_velocity, $FootR.angular_velocity, $FootL.angular_velocity]
    
func ApplyNeuralNetOutputs():
    var bodyPartsPositions = GetBodyPartsPositionsInArray()
    var bodyPartsLinVelocities = GetBodyPartsLinearVelocityInArray()
    var bodyPartsAngVelocities = GetBodyPartsAngularVelocityInArray()
    var tilesRelativePositions = GetTilePositionsRelativeToBody()
    
    assert len(bodyPartsPositions) == numOfBodyparts
    assert len(bodyPartsLinVelocities) == 1
    assert len(bodyPartsAngVelocities) == numOfBodyparts
    
    var inputs = Array()
    inputs.resize(numOfInputs)
    inputs[0] = -1
    var ind_last = 1
    for i in range(numOfBodyparts):
        var pos = bodyPartsPositions[i]
        inputs[ind_last] = pos.x
        inputs[ind_last + 1] = pos.y
        ind_last += 2
    for i in range(1):
        var vel = bodyPartsLinVelocities[i]
        inputs[ind_last] = vel.x
        inputs[ind_last + 1] = vel.y
        ind_last += 2
    for i in range(numOfBodyparts):
        inputs[ind_last] = bodyPartsAngVelocities[i]
        ind_last += 1
    var n_tiles = len(tilesRelativePositions)
    for i in range(maxNumOfTiles):
        if i < n_tiles:
            var pos = tilesRelativePositions[i]
            inputs[ind_last] = pos.x
            inputs[ind_last + 1] = pos.y
            ind_last += 2
        else:
            inputs[ind_last] = 10000
            inputs[ind_last + 1] = 10000
            ind_last += 2
            
    assert ind_last == numOfInputs
    
    var torque_max = 2000*gravity_scale

    var outputs = neuralNet.GetOutput(inputs) 
    #print(outputs)
    
    $Body.apply_torque_impulse(outputs[0]*torque_max)
    $Head.apply_torque_impulse(outputs[1]*torque_max)
    $LegR.apply_torque_impulse(outputs[2]*torque_max)
    $LegR2.apply_torque_impulse(outputs[3]*torque_max)
    $LegL.apply_torque_impulse(outputs[4]*torque_max)
    $LegL2.apply_torque_impulse(outputs[5]*torque_max)
    $FootR.apply_torque_impulse(outputs[2]*torque_max)
    $FootL.apply_torque_impulse(outputs[2]*torque_max)
    $ArmR.apply_torque_impulse(outputs[6]*torque_max)
    $ElbowR.apply_torque_impulse(outputs[7]*torque_max)
    $ArmL.apply_torque_impulse(outputs[8]*torque_max)
    $ElbowL.apply_torque_impulse(outputs[9]*torque_max)
    
    
    
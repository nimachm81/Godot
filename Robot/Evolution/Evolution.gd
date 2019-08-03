extends Node2D

var ROBOT = preload("res://Robot/Robot.gd")
var GAME = preload("res://Game/Game.tscn")
var NEURALNET = preload("res://NeuralNetwork/NeuralNetwork.gd")

var numOfGenerations = 20
var populationSize = 20
var populaation = []

var neuNetumOfInputs
var neuNetNumOfOutputs

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    SetNeuralNetNumofInOuts()
    var game = GAME.instance()
    add_child(game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func SetNeuralNetNumofInOuts():
    var robot = ROBOT.new()
    neuNetumOfInputs = robot.numOfInputs
    neuNetNumOfOutputs = robot.numOfOutputs
    robot.queue_free()

    print("neuNetumOfInputs: ", neuNetumOfInputs)
    print("neuNetNumOfOutputs: ", neuNetNumOfOutputs)

func SetupInitialPopulation():
    populaation.resize(populationSize)
    for i in range(populationSize):
        var neuNet = NEURALNET.new()
        var n_in = neuNetumOfInputs
        var n_out = neuNetNumOfOutputs
        neuNet.numOfNodesInLayers = [n_in, int((n_in + n_out)/2), n_out]
        neuNet.SetupNodeIndices()
        neuNet.SetupRandomTopology()
        populaation[i] = neuNet
        



extends Node2D

var ROBOT = preload("res://Robot/Robot.gd")
var GAME = preload("res://Game/Game.tscn")
#var NEURALNET = preload("res://NeuralNetwork/NeuralNetwork.gd")

var numOfGenerations = 10
var populationSize = 10
var population = []
var fitnessValues = []
var mutationRate = 0.05
var bestGene = null
var bestFitness = null

var neuNetNumOfInputs
var neuNetNumOfOutputs

var evolutionHistoty

var loadFromFile = true
var saveToFile = true

signal fitnessesAllSet

var numOfFitnessesCalculated
var roboPosition = Vector2(500, 420)
var roboRotation = 80

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    SetNeuralNetNumofInOuts()
    var loadFileName = null
    var load_game = File.new()
    if loadFromFile and load_game.file_exists("user://evolution_hist.data"):
        loadFileName = "evolution_hist.data"
    EvolvePopulation(loadFileName)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func CopyNeuralNet(neuNet):
    var nn = NeuralNetwork.new()
    nn.topology = neuNet.topology.duplicate(true)
    nn.numOfNodesInLayers = neuNet.numOfNodesInLayers.duplicate(true)
    nn.nodesInd = neuNet.nodesInd.duplicate(true)
    nn.nodesVal = neuNet.nodesVal.duplicate(true)
    nn.nodesLayer = neuNet.nodesLayer.duplicate(true)
    nn.finalLayerIndStart = neuNet.finalLayerIndStart
    nn.numOfOutputs = neuNet.numOfOutputs
    return nn


func SetNeuralNetNumofInOuts():
    var robot = ROBOT.new()
    neuNetNumOfInputs = robot.numOfInputs
    neuNetNumOfOutputs = robot.numOfOutputs
    robot.queue_free()

    print("neuNetNumOfInputs: ", neuNetNumOfInputs)
    print("neuNetNumOfOutputs: ", neuNetNumOfOutputs)

func SetupInitialPopulation():
    population.resize(populationSize)
    fitnessValues.resize(populationSize)
    for i in range(populationSize):
        var neuNet = NeuralNetwork.new()
        var n_in = neuNetNumOfInputs
        var n_out = neuNetNumOfOutputs
        neuNet.numOfNodesInLayers = [n_in, int((n_in + n_out)/2), n_out]
        neuNet.SetupNodeIndices()
        neuNet.SetupRandomTopology()
        population[i] = neuNet
        
func SetupFitnessValues():
    for i in range(populationSize):
        var game = GAME.instance()
        game.get_node("Robot").neuralNet = population[i]
        game.get_node("Robot").rotation = roboRotation
        game.get_node("Robot").position = roboPosition
        add_child(game)
        yield(game, "gameFinished")
        fitnessValues[i] = game.roboStandFitness
        print("fitness = ", fitnessValues[i])
        game.queue_free()
    print("fitnessValues: ", fitnessValues)
    emit_signal("fitnessesAllSet")
    
func SetupFitnessValuesAllAtOnce():
    numOfFitnessesCalculated = 0
    var screenSize = get_viewport_rect().size
    for i in range(populationSize):
        RunGameAndGetFitness(i, Vector2(0, i*screenSize.y))

func RunGameAndGetFitness(i, pos):
    var game = GAME.instance()
    game.get_node("Robot").neuralNet = population[i]
    game.get_node("Robot").rotation = roboRotation
    game.get_node("Robot").position = roboPosition
    game.position = pos
    add_child(game)
    yield(game, "gameFinished")
    fitnessValues[i] = game.roboStandFitness
    game.queue_free()
    numOfFitnessesCalculated += 1
    if numOfFitnessesCalculated == populationSize:
        print("fitnessValues: ", fitnessValues)
        emit_signal("fitnessesAllSet")
        

func EvolvePopulation(loadFileName = null, oneByOne = true):
    if loadFileName == null:
        evolutionHistoty = []
        SetupInitialPopulation()
    else:
        evolutionHistoty = LoadInitialPopulationFromFile(loadFileName)
    for i in range(numOfGenerations):
        print("generation: ", i, "/",  numOfGenerations)
        if oneByOne:
            SetupFitnessValues()
        else:
            SetupFitnessValuesAllAtOnce()
        yield(self, "fitnessesAllSet")
        evolutionHistoty.append(GetLastGenerationData())
        SelectNextGeneration()
    if saveToFile:
        SaveEvolutionHistory("evolution_hist.data")

func GetLastGenerationData():
    var populationData = []
    for i in range(populationSize):
        populationData.append(population[i].GetDataInDic())
        
    var data = {
        "fitnessValues": fitnessValues,
        "population": populationData
    }
    return data
            
func SelectNextGeneration():
    var fitnessSorted = fitnessValues.duplicate()
    fitnessSorted.sort()
    var fitnessThresh = fitnessSorted[int(populationSize*3/4)]
    
    var ind_best = 0
    var fitnessMax = fitnessValues[0]
    for i in range(populationSize):
        if fitnessMax < fitnessValues[i]:
            fitnessMax = fitnessValues[i]
            ind_best = i

    if bestFitness == null:
        bestFitness = fitnessMax
        bestGene = CopyNeuralNet(population[ind_best])
    else:
        if fitnessMax > bestFitness:
            bestFitness = fitnessMax
            bestGene = CopyNeuralNet(population[ind_best])

    var survivors = []
    for i in range(populationSize):
        if fitnessValues[i] >= fitnessThresh:
            survivors.append(population[i])
    print("bestFitness: ", bestFitness, "  Threashold fitness : ", fitnessThresh, "  n_survive: ", len(survivors) )

    var nextGeneration = [CopyNeuralNet(bestGene)]
    while(len(nextGeneration) < populationSize):
        for i in range(len(survivors)):
            nextGeneration.append(CopyNeuralNet(survivors[i]))
            if len(nextGeneration) == populationSize:
                break
    assert len(nextGeneration) == populationSize
    for i in range(populationSize):
        nextGeneration[i].MutateWeights(mutationRate)
    population = nextGeneration
    
func GetDataInDic():
    var saveData = {
        "numOfGenerations": numOfGenerations,
        "populationSize": populationSize,
        "mutationRate": mutationRate,
        "bestGene": bestGene.GetDataInDic(),
        "bestFitness": bestFitness,
        "neuNetNumOfInputs": neuNetNumOfInputs,
        "neuNetNumOfOutputs": neuNetNumOfOutputs,
        "evolutionHistoty": evolutionHistoty      
    }
    return saveData
    
func GetNeuralNetFromDataDic(neuNetDic):
    var neuNet = NeuralNetwork.new()
    neuNet.nodesInd = neuNetDic["nodesInd"]
    neuNet.nodesVal = neuNetDic["nodesVal"]
    neuNet.nodesLayer = neuNetDic["nodesLayer"]
    neuNet.finalLayerIndStart = neuNetDic["finalLayerIndStart"]
    neuNet.numOfOutputs = neuNetDic["numOfOutputs"]
    neuNet.numOfNodesInLayers = neuNetDic["numOfNodesInLayers"]
    neuNet.topology = neuNetDic["topology"]
    return neuNet
    
func SaveEvolutionHistory(filename):
    var genFile = File.new()
    genFile.open("user://" + filename, File.WRITE)
    var saveData = GetDataInDic()
    genFile.store_line(to_json(saveData))
    genFile.close()
    
func LoadInitialPopulationFromFile(filename):
    var genFile = File.new()
    assert genFile.file_exists("user://" + filename)
    genFile.open("user://" + filename, File.READ)
    var savedData = parse_json(genFile.get_line())
    #while not genFile.eof_reached():
    #    savedData = parse_json(genFile.get_line())
    assert savedData != null
    assert neuNetNumOfInputs == savedData["neuNetNumOfInputs"]
    assert neuNetNumOfOutputs == savedData["neuNetNumOfOutputs"]
    assert populationSize == savedData["populationSize"]
    bestGene = GetNeuralNetFromDataDic(savedData["bestGene"])
    bestFitness = savedData["bestFitness"]
    
    evolutionHistoty = savedData["evolutionHistoty"]
    
    var lastGenData = evolutionHistoty[-1]
    population = []
    population.resize(populationSize)
    fitnessValues = lastGenData["fitnessValues"]
    var popData = lastGenData["population"]
    assert len(popData) == populationSize
    for i in range(populationSize):
        population[i] = GetNeuralNetFromDataDic(popData[i])
    genFile.close()
    
    return evolutionHistoty
    
extends Node2D

class_name NeuralNetwork

var topology
var numOfNodesInLayers = [5, 3, 2]

var nodesInd
var nodesVal
var nodesLayer
var finalLayerIndStart
var numOfOutputs    

func SetupNodeIndices():
    nodesInd = []
    nodesVal = []
    nodesLayer = []

    var ind_last = 0
    for i in range(len(numOfNodesInLayers)):
        var numNode_lay_i = numOfNodesInLayers[i]
        for j in range(numNode_lay_i):
            nodesInd.append(ind_last)
            nodesVal.append(rand_range(-1, 1))
            nodesLayer.append(i)
            ind_last += 1
        
    numOfOutputs = numOfNodesInLayers[-1]
    finalLayerIndStart = 0
    for i in range(len(numOfNodesInLayers) - 1):
        finalLayerIndStart += numOfNodesInLayers[i]
        
func SetupRandomTopology():
    randomize()
    topology = []
    for i in range(len(nodesInd)):
        for j in range(len(nodesInd)):
            if nodesLayer[i] < nodesLayer[j]:
                topology.append([nodesInd[i], nodesInd[j], rand_range(-1, 1), true]) 
            

func GetOutput(input):
    assert len(input) == numOfNodesInLayers[0]
    var inputsToEachLayer = [null]
    var outputs = []
    outputs.resize(len(nodesInd))
    for i in range(len(input)):
        outputs[i] = input[i]    ## assuming input nodes were laid out first in nodesInd
        
    for i in range(1, len(numOfNodesInLayers)):
        inputsToEachLayer.append([])
        var inputs_i = {}
        for elem in topology:
            var e_0 = elem[0] 
            var e_1 = elem[1] 
            var w = elem[2]
            var active = elem[3]
            if active:
                if nodesLayer[e_1] == i:
                    if e_1 in inputs_i:
                        inputs_i[e_1] += w * outputs[e_0]
                    else:
                        inputs_i[e_1] = w * outputs[e_0]
        for ind in inputs_i:
            outputs[ind] = nodesVal[ind]*Sigmmoid(inputs_i[ind])
    
    var last_layer_outputs = []
    last_layer_outputs.resize(numOfOutputs)
    for i in range(numOfOutputs):
        last_layer_outputs[i] = outputs[finalLayerIndStart + i]
    
    return last_layer_outputs
                    
func Sigmmoid(x):
    return 1.0/(1 + exp(-x/10.0))


func MutateWeights(muRate):
    for elem in topology:
        if elem[3]:
            if rand_range(0, 1) < muRate:
                elem[2] += rand_range(-1, 1)*elem[2]
    for i in range(len(nodesVal)):
        if rand_range(0, 1) < muRate:
            nodesVal[i] += rand_range(-1, 1)*nodesVal[i]
        
        
func GetDataInDic():
    var saveData = {
        "nodesInd": nodesInd,
        "nodesVal": nodesVal,
        "nodesLayer": nodesLayer,
        "finalLayerIndStart": finalLayerIndStart,
        "numOfOutputs": numOfOutputs,
        "numOfNodesInLayers": numOfNodesInLayers,
        "topology": topology
    }
    return saveData
        
    
    
    
    
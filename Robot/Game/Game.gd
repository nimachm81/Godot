extends Node2D


var NEURALNET = preload("res://NeuralNetwork/NeuralNetwork.gd")

var tileMapCellOrigin
var tileMapCellSize
var tileIds
var tileSizes
var tileNumOfCells
var tileArr
var tileArrById

var bodyInForbidenArea = false
var headInForbidenArea = false
var roboStandFitness = 100

signal gameFinished

# Called when the node enters the scene tree for the first time.
func _ready():
    getTileMapParams()
    #PrintTileMapDetails()
    $Robot.position = Vector2(500, 100)
    
    #var tiles_relative_to_pos = GetTileCellsAroundPoint(Vector2(800, 500), Vector2(2, 3))
    #print("tiles_relative_to_pos: ", tiles_relative_to_pos)
    
    $ForbidenBodyArea.connect("body_entered", self, "on_forbiden_area_body_entered")
    $ForbidenBodyArea.connect("body_exited", self, "on_forbiden_area_body_exited")
    $ScoreTimer.connect("timeout", self, "on_score_timeout")
    $GameTimer.connect("timeout", self, "on_game_timeout")
    $HeadInFATimer.connect("timeout", self, "on_head_in_FA_timeout")
    $BodyInFATimer.connect("timeout", self, "on_body_in_FA_timeout")
    
    $GameTimer.start()
    $ScoreLabel.text = str(roboStandFitness)
    $ScoreTimer.start()
    
    SetupRandomNeuralNet()
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func SetupRandomNeuralNet():
    var neuNet = NEURALNET.new()
    var n_in = $Robot.numOfInputs
    var n_out = $Robot.numOfOutputs
    neuNet.numOfNodesInLayers = [n_in, int((n_in + n_out)/2), n_out]
    neuNet.SetupNodeIndices()
    neuNet.SetupRandomTopology()
    $Robot.neuralNet = neuNet

func PrintTileMapDetails():
    print("cell size: ", $TileMap.cell_size)
    print("origin: ", $TileMap.cell_tile_origin)
    print("used cells :", $TileMap.get_used_cells())
    print("used rect :", $TileMap.get_used_rect())
    print("world to map(100, 100) :", $TileMap.world_to_map(Vector2(100, 100)))
    print("tile ids : ", $TileMap.tile_set.get_tiles_ids())
    print("get cell (2,2): ", $TileMap.get_cell(2, 2))
    print("get cell (3,7): ", $TileMap.get_cell(3, 7))
    print("get cell (2,7): ", $TileMap.get_cell(2, 7))
    print("tile regions:")
    for id in $TileMap.tile_set.get_tiles_ids():
        print("id: ", id, "  range: ", $TileMap.tile_set.tile_get_region(id))

func getTileMapParams():
    tileMapCellOrigin = $TileMap.cell_tile_origin
    tileMapCellSize = $TileMap.cell_size
    tileIds = $TileMap.tile_set.get_tiles_ids()
    tileArr = $TileMap.get_used_cells()
    tileSizes = {}
    tileNumOfCells = {}
    tileArrById = {}
    for id in tileIds:
        var tile_size = $TileMap.tile_set.tile_get_region(id).size
        tileSizes[id] = tile_size
        tileNumOfCells[id] = Vector2(floor(tile_size.x / tileMapCellSize.x), floor(tile_size.y / tileMapCellSize.y))
        assert tileNumOfCells[id] * tileMapCellSize == tile_size
        tileArrById[id] = $TileMap.get_used_cells_by_id(id)
    """
    print("tileMapCellOrigin: ", tileMapCellOrigin)
    print("tileMapCellSize: ", tileMapCellSize)
    print("tileIds: ", tileIds)
    print("tileSizes: ", tileSizes)
    print("tileNumOfCells: ", tileNumOfCells)
    print("tileArr: ", tileArr)
    print("tileArrById: ", tileArrById)
    """
       
func GetTileCellsAroundPoint(pos, num_of_cells_to_cover):
    var pos_map = $TileMap.world_to_map(pos)
    var tiles_relative_to_pos = Array()
    for id in tileIds:
        var tile_nCells = tileNumOfCells[id]
        var tile_arr = tileArrById[id]
        for tile in tile_arr:
            var tile_pos_rel_0 = tile - pos_map
            var tile_pos_rel_1 = tile_pos_rel_0 + tile_nCells - Vector2(1, 1)
            var is_in_0_all = tile_pos_rel_0.abs() < num_of_cells_to_cover    ## both x and y components are inside
            var is_in_1_all = tile_pos_rel_1.abs() < num_of_cells_to_cover
            if is_in_0_all or is_in_1_all:    ## one of the corners is inside
                for i in range(tile_nCells.x):
                    for j in range(tile_nCells.y):
                        tiles_relative_to_pos.append(tile_pos_rel_0 + Vector2(i, j))
    return tiles_relative_to_pos
    
func on_forbiden_area_body_entered(body):
    if body.name.find("Body") >= 0:
        bodyInForbidenArea = true
        $BodyInFATimer.start()
    if body.name.find("Head") >= 0:
        headInForbidenArea = true
        $HeadInFATimer.start()
        

func on_forbiden_area_body_exited(body):
    if body.name.find("Body") >= 0:
        bodyInForbidenArea = false
        $BodyInFATimer.stop()
    if body.name.find("Head") >= 0:
        headInForbidenArea = false
        $HeadInFATimer.stop()
    
func on_head_in_FA_timeout():
    if headInForbidenArea:
        roboStandFitness -= 1
        #print("roboStandFitness: (head in) ", roboStandFitness)
    
func on_body_in_FA_timeout():
    if bodyInForbidenArea:
        roboStandFitness -= 1
        #print("roboStandFitness (body in): ", roboStandFitness)
    
func on_score_timeout():
    $ScoreLabel.text = str(roboStandFitness)
    
func on_game_timeout():
    print("game finished")
    emit_signal("gameFinished")
    
    
    
    
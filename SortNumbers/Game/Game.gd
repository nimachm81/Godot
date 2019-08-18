extends Node2D

var CELL = preload("res://Cell/Cell.tscn")
var POPUPDIALOG = preload("res://PopupDialog/PopupDialog.tscn")
var STARTUPDIALOG = preload("res://StartDialog/StartupScreen.tscn")

var n_x = 10
var n_y = 10
var ind_max = n_x * n_y - 1
var butSize = 30
var x0
var y0

var cells = {}
var cellIndices = {}

var screenSize

var gameStarted = false
signal playerWon
var numberOfMoves = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    screenSize = get_viewport_rect().size
    InitializeCells($SizeSlider.value, $SizeSlider.value)
    SetProgress()
    $ShuffleButton.connect("button_up", self, "on_shuffle_pressed")
    $SizeSlider.connect("value_changed", self, "on_size_slider_changed")
    $ShuffleConfirmationDialog.connect("confirmed", self, "Shuffle")
    $ResizeCheckButton.connect("toggled", self, "on_resize_onoff_toggled") 
    connect("playerWon", self, "on_player_won")
    
    var shufDial_x0 = screenSize.x/2 - $ShuffleConfirmationDialog.rect_size.x/2
    var shufDial_y0 = screenSize.y/2 - $ShuffleConfirmationDialog.rect_size.y/2
    $ShuffleConfirmationDialog.rect_position = Vector2(shufDial_x0, shufDial_y0)

    show_start_dialog()
 
func AdjustSize():
    x0 = 30
    butSize = int((screenSize.x - 2*x0) / n_x)
    y0 = int(screenSize.y / 2 + n_y * butSize / 2 - butSize)
    
    $TextureProgress.rect_scale.x = (screenSize.x - 2*x0) / $TextureProgress.rect_size.x
    #$TextureProgress.rect_scale.y = 0.5
    var pBar_x0 = x0 #screenSize.x/2 - $TextureProgress.rect_size.x/2
    var pBar_y0 = y0 -  (n_y - 1) * butSize - $TextureProgress.rect_size.y - 20
    $TextureProgress.rect_position = Vector2(pBar_x0, pBar_y0)
    
    #var slider_x0 = screenSize.x/2 - $SizeSlider.rect_size.x/2
    #var slider_y0 = y0 + butSize + 10
    #$SizeSlider.rect_position = Vector2(slider_x0, slider_y0)
        

func InitializeCells(n_x_, n_y_):
    DeleteAllCells()

    n_x = n_x_
    n_y = n_y_
    ind_max = n_x * n_y - 1
    
    AdjustSize()
    
    for i in range(1, n_x + 1):
        for j in range(1, n_y + 1):
            var but = CELL.instance()
            but.rect_size = Vector2(butSize, butSize)
            SetCellPosition(but, i, j)
                        
            var cell_number = GetInitialInd(i, j)
            but.SetCellNumber(cell_number)
            but.SetRightCell(GetInitialInd(i + 1, j))
            but.SetLeftCell(GetInitialInd(i - 1, j))
            but.SetDownCell(GetInitialInd(i, j - 1))
            but.SetUpCell(GetInitialInd(i, j + 1))  
            
            add_child(but)
            cells[[i, j]] = but
            cellIndices[cell_number] = [i, j]
            
            but.add_color_override("font_color_pressed", Color(1.0, 0.0, 0.0))
            
            if i == n_x and j == n_y:
                but.visible = false
            else:
                but.connect("cell_wants_to_move", self, "on_cell_ready_to_move")
                
func DeleteAllCells():
    for ind in cells:
        var but = cells[ind]
        but.queue_free()
    cells.clear()
    cellIndices.clear()
    
func GetInitialInd(i, j):
    if i >= 1 and i <= n_x and j >= 1 and j <= n_y:
        if i == n_x and j == n_y:
            return 0
        else:
            return i + (j - 1)*n_x
    else:
        return -1

func SetCellPosition(but, i, j):
    but.rect_position = Vector2(x0 + (i - 1)*butSize, y0 - (j - 1)*butSize)

func on_cell_ready_to_move(cell_number):
    print("moving cell: ", cell_number)
    
    var cell_ind = cellIndices[cell_number]
    var but = cells[cell_ind]
    var i = cell_ind[0]
    var j = cell_ind[1]
    if but.cell_right == 0:
        assert cells[[i + 1, j]].cell_number == 0
        SwapCells(cell_number, 0)
    elif but.cell_left == 0:
        assert cells[[i - 1, j]].cell_number == 0
        SwapCells(cell_number, 0)
    elif but.cell_up == 0:
        assert cells[[i, j + 1]].cell_number == 0
        SwapCells(cell_number, 0)
    elif but.cell_down == 0:
        assert cells[[i, j - 1]].cell_number == 0
        SwapCells(cell_number, 0)
        
    SetProgress()
    numberOfMoves += 1
    $ChipSound.play()
    

func SwapCells(num_1, num_2):
    var but_1 = cells[cellIndices[num_1]]
    var but_2 = cells[cellIndices[num_2]]
    
    var i1 = cellIndices[num_1][0]
    var j1 = cellIndices[num_1][1]
    var i2 = cellIndices[num_2][0]
    var j2 = cellIndices[num_2][1]
        
    var b1_l = but_1.cell_left
    var b1_r = but_1.cell_right
    var b1_d = but_1.cell_down
    var b1_u = but_1.cell_up
    
    var b2_l = but_2.cell_left
    var b2_r = but_2.cell_right
    var b2_d = but_2.cell_down
    var b2_u = but_2.cell_up

    if b2_l != num_1:
        but_1.cell_left  = b2_l
    else:
        but_1.cell_left  = num_2        
    if b2_r != num_1:
        but_1.cell_right = b2_r
    else:
        but_1.cell_right = num_2        
    if b2_d != num_1:
        but_1.cell_down  = b2_d
    else:
        but_1.cell_down  = num_2        
    if b2_u != num_1:
        but_1.cell_up    = b2_u
    else:
        but_1.cell_up    = num_2        

    if b1_l != num_2:
        but_2.cell_left  = b1_l
    else:
        but_2.cell_left  = num_1
    if b1_r != num_2:
        but_2.cell_right = b1_r
    else:
        but_2.cell_right = num_1
    if b1_d != num_2:
        but_2.cell_down  = b1_d
    else:
        but_2.cell_down  = num_1
    if b1_u != num_2:
        but_2.cell_up    = b1_u
    else:
        but_2.cell_up    = num_1

    if b1_l >= 0 and b1_l != num_2:
        cells[cellIndices[b1_l]].cell_right = num_2
    if b1_r >= 0 and b1_r != num_2:
        cells[cellIndices[b1_r]].cell_left  = num_2
    if b1_d >= 0 and b1_d != num_2:
        cells[cellIndices[b1_d]].cell_up    = num_2
    if b1_u >= 0 and b1_u != num_2:
        cells[cellIndices[b1_u]].cell_down  = num_2

    if b2_l >= 0 and b2_l != num_1:
        cells[cellIndices[b2_l]].cell_right = num_1
    if b2_r >= 0 and b2_r != num_1:
        cells[cellIndices[b2_r]].cell_left  = num_1
    if b2_d >= 0 and b2_d != num_1:
        cells[cellIndices[b2_d]].cell_up    = num_1
    if b2_u >= 0 and b2_u != num_1:
        cells[cellIndices[b2_u]].cell_down  = num_1

    cells[cellIndices[num_1]] = but_2
    cells[cellIndices[num_2]] = but_1
    cellIndices[num_1] = [i2, j2]
    cellIndices[num_2] = [i1, j1]
    SetCellPosition(but_1, i2, j2)
    SetCellPosition(but_2, i1, j1)
    


func Shuffle():
    var but_0 = cells[cellIndices[0]]
    
    var i = 0
    while $TextureProgress.value > 10 and i < 20000:
        var dir = randi()%4
        #print(dir)
        if dir == 0 and but_0.cell_left > 0:
            SwapCells(0, but_0.cell_left)
        elif dir == 1 and but_0.cell_right > 0:
            SwapCells(0, but_0.cell_right)
        elif dir == 2 and but_0.cell_down > 0:
            SwapCells(0, but_0.cell_down)
        elif dir == 3 and but_0.cell_up > 0:
            SwapCells(0, but_0.cell_up)
        SetProgress(false)
        i += 1

    gameStarted = true
    numberOfMoves = 0    
        

func SetProgress(emit_victory = true):
    var progress = 0
    for ind in cellIndices:
        var i = cellIndices[ind][0]
        var j = cellIndices[ind][1]
        if GetInitialInd(i, j) == ind:
            progress += 1
    
    $TextureProgress.value = progress * 100 / (ind_max + 1)
    if emit_victory and $TextureProgress.value == 100:
        emit_signal("playerWon")

func on_shuffle_pressed():
    print("shuffle pressed")
    $ShuffleConfirmationDialog.show_modal(true)
    
func on_size_slider_changed(value):
    print("size slider changed: ", value)
    if $ResizeCheckButton.pressed:
        InitializeCells(value, value)
        gameStarted = false
        SetProgress(false)
    
func on_resize_onoff_toggled(pressed):
    print("resize toggled")
    $SizeSlider.editable = pressed

func on_player_won():
    print("player won!")
    if gameStarted:
        var dialog = POPUPDIALOG.instance()
        dialog.dialog_text = "Awsome job! \nNumber of moves: " + str(numberOfMoves) + "\n"
        dialog.window_title = "Game Complete"

        var dial_x0 = screenSize.x/2 - dialog.rect_size.x/2
        var dial_y0 = screenSize.y/2 - dialog.rect_size.y/2
        dialog.rect_position = Vector2(dial_x0, dial_y0)

        add_child(dialog)
        dialog.show_modal(true)
        yield(get_tree().create_timer(10), "timeout")
        dialog.queue_free()
        gameStarted = false

func show_start_dialog__():
    var dialog = STARTUPDIALOG.instance()
    add_child(dialog)
    dialog.show()
    yield(get_tree().create_timer(5), "timeout")
    dialog.queue_free()

func show_start_dialog():
    var dialog = POPUPDIALOG.instance()
    dialog.dialog_text = "Slide the cells in the empty spot \nto sort them out!\n"
    dialog.window_title = "instructions"

    var dial_x0 = screenSize.x/2 - dialog.rect_size.x/2
    var dial_y0 = screenSize.y/2 - dialog.rect_size.y/2
    dialog.rect_position = Vector2(dial_x0, dial_y0)
    
    add_child(dialog)
    dialog.show_modal(true)
    yield(get_tree().create_timer(15), "timeout")
    dialog.queue_free()
    
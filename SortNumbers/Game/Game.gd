extends Node2D

var CELL = preload("res://Cell/Cell.tscn")
var POPUPDIALOG = preload("res://PopupDialog/PopupDialog.tscn")
var STARTUPDIALOG = preload("res://StartDialog/StartupScreen.tscn")
var MOVEHELPER = preload("res://MoveArrow/MoveArrow.tscn")

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

var coloredButtons = true
var settingsVisible = false

var trainingDone = false
var settingsPressed = false
var sliderPressed = false
var shufflePressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    screenSize = get_viewport_rect().size
    InitializeCells($SizeSlider.value, $SizeSlider.value)
    SetProgress()
    $SizeSlider.connect("value_changed", self, "on_size_slider_changed")
    $ShuffleArea2D.connect("input_event", self, "on_shuffle_area_input")
    $SettingsArea2D.connect("input_event", self, "on_settings_area_input")
    $HandTimer.connect("timeout", self, "on_hand_timer_timeout")
    connect("playerWon", self, "on_player_won")
    
    $SizeSlider.visible = false
    $ShuffleArea2D.visible = false 
    $TrophySprite.visible = false
    
    AdjustSize()

    $HandSprite.visible = false
    trainingDone = CheckTrainingCertificate()
    if not trainingDone:    
        $HandSprite.visible = true
        PointToSettings()
        

func AdjustSize():
    x0 = 30
    butSize = int((screenSize.x - 2*x0) / n_x)
    y0 = int(screenSize.y / 2 + n_y * butSize / 2 - butSize)
    
    $TextureProgress.rect_scale.x = (screenSize.x - 2*x0) / $TextureProgress.rect_size.x
    #$TextureProgress.rect_scale.y = 0.5
    var pBar_x0 = x0 #screenSize.x/2 - $TextureProgress.rect_size.x/2
    var pBar_y0 = y0 -  (n_y - 1) * butSize - $TextureProgress.rect_size.y - 20
    $TextureProgress.rect_position = Vector2(pBar_x0, pBar_y0)
    
    $SettingsArea2D.position.y = y0 + butSize + 25
    $SizeSlider.rect_position.y = $SettingsArea2D.position.y - $SizeSlider.rect_size.y/2
    $ShuffleArea2D.position.y = $SettingsArea2D.position.y

        
func InitializeCells(n_x_, n_y_):
    DeleteAllCells()

    n_x = n_x_
    n_y = n_y_
    ind_max = n_x * n_y - 1
    
    AdjustSize()
    
    var but_color = {}
    for j in range(1, n_y + 1):
        but_color[j] = Color(rand_range(0, 0.5), rand_range(0, 0.5), rand_range(0, 0.5), 1)
        
        if but_color[j][0] + but_color[j][1] + but_color[j][2] > 1.4:
            but_color[j][randi()%3] = rand_range(0, 0.3)

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
            
            if coloredButtons:
                var theme = Theme.new()
                theme.copy_default_theme()
                theme.set_stylebox("normal", "Button", StyleBoxFlat.new())
                theme.get_stylebox("normal", "Button").bg_color = but_color[j]
                theme.get_stylebox("normal", "Button").border_width_left = 1
                theme.get_stylebox("normal", "Button").border_width_right = 1
                theme.get_stylebox("normal", "Button").border_width_top = 1
                theme.get_stylebox("normal", "Button").border_width_bottom = 1
                theme.get_stylebox("normal", "Button").border_color = Color(0, 0, 0, 1)
                theme.set_stylebox("focus", "Button", StyleBoxFlat.new())
                theme.get_stylebox("focus", "Button").bg_color = but_color[j]
                
                if i == n_x and j == n_y:
                    theme.get_stylebox("normal", "Button").bg_color = Color(1, 1, 1, 1) 
                    theme.get_stylebox("focus", "Button").bg_color = Color(1, 1, 1, 1) 
                    theme.set_stylebox("hover", "Button", StyleBoxFlat.new())
                    theme.get_stylebox("hover", "Button").bg_color = Color(1, 1, 1, 1) 
                but.theme = theme
                        
            if i == n_x and j == n_y:
                #but.visible = false
                pass
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
    if gameStarted:
        IncreaseNumberOfMoves(1)
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
    
    SetProgress(false)
    
    var i = 0
    var min_iter = 100
    while i < 10000:
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
        
        if $TextureProgress.value < 10 and i > min_iter:
            break

    gameStarted = true
    SetNumberOfMoves(0)
    ShowMoveHelper()


func SetNumberOfMoves(num):
    numberOfMoves = num
    $TextureProgress/RichTextLabel.clear()
    $TextureProgress/RichTextLabel.push_align(RichTextLabel.ALIGN_CENTER)
    $TextureProgress/RichTextLabel.add_text(str(numberOfMoves))
    $TextureProgress/RichTextLabel.pop()
    
func IncreaseNumberOfMoves(n):
    numberOfMoves += n
    var color = Color(1, 1, 1, 1)
    if $TextureProgress.value > 50:
        color = Color(0, 0, 0, 1)
    $TextureProgress/RichTextLabel.clear()
    $TextureProgress/RichTextLabel.push_align(RichTextLabel.ALIGN_CENTER)
    $TextureProgress/RichTextLabel.push_color(color)
    $TextureProgress/RichTextLabel.add_text(str(numberOfMoves))
    $TextureProgress/RichTextLabel.pop()
    $TextureProgress/RichTextLabel.pop()

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
    
func on_size_slider_changed(value):
    print("size slider changed: ", value)
    InitializeCells(value, value)
    gameStarted = false
    SetProgress(false)
    $TextureProgress/RichTextLabel.clear()
    if not trainingDone and settingsPressed:
        sliderPressed = true
        PointToShuffle()


func on_player_won():
    print("player won!")
    if gameStarted:
        $WinSound.play()
        gameStarted = false

        """
        var dialog = POPUPDIALOG.instance()
        dialog.dialog_text = ""
        dialog.get_node("RichTextLabel").text = "Awsome job! \nNumber of moves: " + str(numberOfMoves) + "\n"
        dialog.window_title = "Game Complete"

        var dial_x0 = screenSize.x/2 - dialog.rect_size.x/2
        var dial_y0 = screenSize.y/2 - dialog.rect_size.y/2
        dialog.rect_position = Vector2(dial_x0, dial_y0)

        add_child(dialog)
        dialog.show_modal(true)
        yield(get_tree().create_timer(10), "timeout")
        dialog.queue_free()
        """
        
        ShowTrophy()
        
func show_start_dialog__():
    var dialog = STARTUPDIALOG.instance()
    add_child(dialog)
    dialog.show()
    yield(get_tree().create_timer(5), "timeout")
    dialog.queue_free()


func show_start_dialog():
    var dialog = POPUPDIALOG.instance()
    dialog.dialog_text = ""
    dialog.get_node("RichTextLabel").text = "Shuffle and sort again by sliding the cells around the empty white spot!\n"
    dialog.window_title = "instructions"

    var dial_x0 = screenSize.x/2 - dialog.rect_size.x/2
    var dial_y0 = screenSize.y/2 - dialog.rect_size.y/2
    dialog.rect_position = Vector2(dial_x0, dial_y0)
    
    add_child(dialog)
    dialog.show_modal(true)
    yield(get_tree().create_timer(15), "timeout")
    dialog.queue_free()
    
func on_shuffle_area_input(viewport, event, shape_idx):
    if event is InputEventScreenTouch:
        if event.pressed:
            Shuffle()
            if not trainingDone and settingsPressed and sliderPressed:
                shufflePressed = true
                $HandTimer.stop()
                $HandSprite.visible = false
                trainingDone = true
                RegisterTrainingCertificate()

    
func on_settings_area_input(viewport, event, shape_idx):
    if event is InputEventScreenTouch:
        if event.pressed:
            settingsVisible = not settingsVisible
            $SizeSlider.visible = settingsVisible
            $ShuffleArea2D.visible = settingsVisible
            if settingsVisible:
                $SettingsArea2D/Sprite.texture = load("res://Game/images/settings_green.png")
            else:
                $SettingsArea2D/Sprite.texture = load("res://Game/images/settings_black.png")
            
            if not trainingDone and not settingsPressed:
                settingsPressed = true
                PointToSliderbar()
  
func ShowTrophy(stars=3, time=4):
    $TrophySprite.visible = true
    yield(get_tree().create_timer(time), "timeout")
    $TrophySprite.visible = false


func PointToSettings():
    $HandSprite.position = $SettingsArea2D.position \
                           + Vector2(-$HandSprite.texture.get_size().x/2, $HandSprite.texture.get_size().y/2)
    $HandTimer.start()
    
func PointToShuffle():
    $HandSprite.position = $ShuffleArea2D.position \
                           + Vector2(-$HandSprite.texture.get_size().x/2, $HandSprite.texture.get_size().y/2)
    $HandTimer.start()

func PointToSliderbar():
    $HandSprite.position = $SizeSlider.rect_position \
                           + Vector2($SizeSlider.rect_size.x/2, $SizeSlider.rect_size.y/2) \
                           + Vector2(-$HandSprite.texture.get_size().x/2, $HandSprite.texture.get_size().y/2)
    $HandTimer.start()

func on_hand_timer_timeout():
    $HandSprite.visible = not $HandSprite.visible
    
func ShowMoveHelper():
    var but_0 = cells[cellIndices[0]]
        
    var b_l = but_0.cell_left
    var b_r = but_0.cell_right
    var b_d = but_0.cell_down
    var b_u = but_0.cell_up
    
    var bs = [b_d, b_l, b_u, b_r]
    
    for i in range(4):
        var b = bs[i]
        if b > 0:
            var but = cells[cellIndices[b]]
            print("setting left helper")
            var sprite = MOVEHELPER.instance()
            sprite.texture = load("res://Game/images/arrow.png")
            sprite.position = but.rect_position + but.rect_size/2;
            sprite.rotation_degrees = i * 90
            sprite.z_index = 1
            add_child(sprite)
    
func RegisterTrainingCertificate():
    var file = File.new()
    var filename = "user://onesim_numbersort.json"
    file.open(filename, file.WRITE_READ)
    if file.is_open():
        file.store_string('{"trained":"yes"}')
        file.close()
    else:
        print("error opening file")
    
func CheckTrainingCertificate():
    var file = File.new()
    var filename = "user://onesim_numbersort.json"
    if file.file_exists(filename):
        file.open(filename, file.READ)
        if file.is_open():
            var content = file.get_as_text()
            print("file : ", content)
            var json_res = JSON.parse(content)
            if json_res.error == OK:
                var cont_dic = json_res.result
                if cont_dic.has("trained"):
                    if cont_dic["trained"] == "yes":
                        return true
            else:
                print("json error")
        else:
            print("error opening file")
    return false

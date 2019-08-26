extends Button


var cell_number = -1
var cell_left = -1
var cell_right = -1
var cell_down = -1
var cell_up = -1

signal cell_wants_to_move(num)

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("button_down", self, "on_button_down")


func SetCellNumber(num):
    cell_number = num
    if cell_number != 0:
        text = str(num)

func SetRightCell(num):
    cell_right = num

func SetLeftCell(num):
    cell_left = num

func SetDownCell(num):
    cell_down = num

func SetUpCell(num):
    cell_up = num

func on_button_down():
    if cell_left == 0 or cell_right == 0 or cell_up == 0 or cell_down == 0:
        emit_signal("cell_wants_to_move", cell_number)

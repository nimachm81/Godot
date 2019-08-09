extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
    get_node("/root/Main/Player").connect("hit", $Health, "_on_Player_hit")
    $HBox/VBox_R/SizeSlider.max_value = Globals.maxSize
    $HBox/VBox_R/SizeSlider.value = Globals.maxSize*3.0/5
    #$HBox/VBox_R/SizeSlider.emit_signal("value_changed")
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_message(text):
    $MessageLabel.text = text
    $MessageLabel.show()
    $MessageTimer.start()

func AdjustBasedOnNewPort(gameSize, origin):
    $ScoreLabel.rect_position = origin
    $Health.position.x = origin.x + gameSize.x - $Health.get_node("background").rect_size.x - 10
    $Health.position.y = origin.y + 10

func show_game_over():
    show_message("Game Over")
    yield($MessageTimer, "timeout")
    $MessageLabel.text = "Dodge the\nBalls!"
    $MessageLabel.show()
    yield(get_tree().create_timer(1), 'timeout')
    ShowElementsAtGameOver()

func update_score(score):
    $ScoreLabel.text = str(score)

func _on_StartButton_pressed():
    HideElementsAtGameStart()
    emit_signal("start_game")

func HideElementsAtGameStart():
    $StartButton.hide()
    $HBox.hide()
    
func ShowElementsAtGameOver():
    $StartButton.show()
    $HBox.show()

func _on_MessageTimer_timeout():
    $MessageLabel.hide()

func reset_health():
    $Health.IncreaseHealth(110, false)

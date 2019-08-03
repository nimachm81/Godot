extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
    get_node("/root/Main/Player").connect("hit", $Health, "_on_Player_hit")
    pass
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_message(text):
    $MessageLabel.text = text
    $MessageLabel.show()
    $MessageTimer.start()


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
    $LevelLabel.hide()
    $MusicLabel.hide()
    $TrailLabel.hide()
    $MusicOnOffButton.hide()
    $DifficultySlider.hide()
    $TrailOnOffButton.hide()
    
func ShowElementsAtGameOver():
    $StartButton.show()
    $LevelLabel.show()
    $MusicLabel.show()
    $TrailLabel.show()
    $MusicOnOffButton.show()
    $DifficultySlider.show()    
    $TrailOnOffButton.show()

func _on_MessageTimer_timeout():
    $MessageLabel.hide()

func reset_health():
    $Health.IncreaseHealth(110)

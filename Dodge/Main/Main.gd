extends Node2D

export (PackedScene) var Mob
var score
var totalTime

var screen_size

var FOOD = preload("res://Food/Food.tscn")
var AMMO = preload("res://Ammo/Ammo.tscn")

var musicOn = true
var difficultyLevel = 0
var trailOn = true

var backgroundColor = Color(1, 0.75, 0.8, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    
    screen_size = get_viewport_rect().size
    
    on_difficulty_changed(difficultyLevel)
    
    $HUD.get_node("Health").connect("healthZero", self, "game_over")
    $HUD.get_node("Health").connect("healthZero", $Player, "on_player_dead")
    $HUD.get_node("MusicOnOffButton").connect("toggled", self, "on_music_toggled")
    $HUD.get_node("TrailOnOffButton").connect("toggled", self, "on_trail_toggled")
    $HUD.get_node("DifficultySlider").connect("value_changed", self, "on_difficulty_changed")
    
    $Music.set_stream(preload('res://art/music/William_Rosati_No_Work.ogg'))
    
    $FoodTimer.connect("timeout", self, "on_Food_timer_timeout")
    $AmmoTimer.connect("timeout", self, "on_Ammo_timer_timeout")
    $BallTimer.connect("timeout", self, "on_BallTimer_timeout")
    
    $ColorRect.color = backgroundColor

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func game_over():
    $ScoreTimer.stop()
    $BallTimer.stop()
    $FoodTimer.stop()
    $AmmoTimer.stop()
    $HUD.show_game_over()
    if musicOn:
        $Music.stop()
    $DeathSound.play()
    $ColorRect.color = backgroundColor

func new_game():
    score = 0
    totalTime = 0
    $Player.start($StartPosition.position)
    $StartTimer.start()
    $HUD.update_score(score)
    $HUD.show_message("Get Ready")
    $HUD.reset_health()
    if musicOn:
        $Music.play()

func _on_StartTimer_timeout():
    $BallTimer.start()
    $ScoreTimer.start()
    $FoodTimer.start()
    $AmmoTimer.start()

func _on_ScoreTimer_timeout():
    totalTime += 1

func on_BallTimer_timeout():
    # Choose a random location on Path2D.
    $BallPath/BallSpawnLocation.set_offset(randi())
    # Create a Mob instance and add it to the scene.
    var mob = Mob.instance()
    add_child(mob)
    # Set the mob's direction perpendicular to the path direction.
    var direction = $BallPath/BallSpawnLocation.rotation + PI / 2
    # Set the mob's position to a random location.
    mob.position = $BallPath/BallSpawnLocation.position
    # Add some randomness to the direction.
    direction += rand_range(-PI / 4, PI / 4)
    mob.rotation = direction
    # Set the velocity (speed & direction).
    mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
    mob.linear_velocity = mob.linear_velocity.rotated(direction)

    $HUD.connect("start_game", mob, "_on_start_game")

func on_Food_timer_timeout():
    var x = rand_range(10, screen_size.x - 10)
    var y = rand_range(10, screen_size.y - 10)
    
    var food = FOOD.instance();
    add_child(food)
    food.position = Vector2(x, y)
    
    $HUD.connect("start_game", food, "_on_start_game")

func on_Ammo_timer_timeout():
    var x = rand_range(10, screen_size.x - 10)
    var y = rand_range(10, screen_size.y - 10)
    
    var ammo = AMMO.instance();
    add_child(ammo)
    ammo.position = Vector2(x, y)
    
    $HUD.connect("start_game", ammo, "_on_start_game")

    
func on_music_toggled(button_pressed):
    print("MusicOnOff pressed. Button state : ", button_pressed)
    musicOn = !musicOn
    print("music : ", musicOn)

func on_trail_toggled(button_pressed):
    print("TrailOnOff pressed. Button state : ", button_pressed)
    trailOn = !trailOn
    print("trail : ", trailOn)
    $Player.get_node("Trail").visible = trailOn

    
func on_difficulty_changed(value):
    difficultyLevel = value
    print("Difficulty value: ", value)    
    assert difficultyLevel >= 0 and difficultyLevel <= 10
    $BallTimer.wait_time = 2.0/(1.0 + difficultyLevel)

func IncreaseScore(ds):
    score += ds
    $HUD.update_score(score)

extends Node2D

export (PackedScene) var Mob
var score

var screen_size

var FOOD = preload("res://Food/Food.tscn")

var musicOn = true
var difficultyLevel = 0
var trailOn = true

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func game_over():
    $ScoreTimer.stop()
    $MobTimer.stop()
    $FoodTimer.stop()
    $HUD.show_game_over()
    if musicOn:
        $Music.stop()
    $DeathSound.play()

func new_game():
    score = 0
    $Player.start($StartPosition.position)
    $StartTimer.start()
    $HUD.update_score(score)
    $HUD.show_message("Get Ready")
    $HUD.reset_health()
    if musicOn:
        $Music.play()

func _on_StartTimer_timeout():
    $MobTimer.start()
    $ScoreTimer.start()
    $FoodTimer.start()

func _on_ScoreTimer_timeout():
    score += 1
    $HUD.update_score(score)

func _on_MobTimer_timeout():
    # Choose a random location on Path2D.
    $MobPath/MobSpawnLocation.set_offset(randi())
    # Create a Mob instance and add it to the scene.
    var mob = Mob.instance()
    add_child(mob)
    # Set the mob's direction perpendicular to the path direction.
    var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
    # Set the mob's position to a random location.
    mob.position = $MobPath/MobSpawnLocation.position
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
    $MobTimer.wait_time = 2.0/(1.0 + difficultyLevel)

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

var showAds = true
var ad_isReal = false
var ad_isOnTop = true
var ad_BannerId = "ca-app-pub-3940256099942544/6300978111"
var admob

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    
    Globals.screen_size = get_viewport_rect().size
    screen_size = get_viewport_rect().size #OS.get_window_size() #get_viewport_rect().size
    SetGamePort(screen_size)
    print("screen_size: ", screen_size)
    
    on_difficulty_changed(difficultyLevel)
    
    $HUD.get_node("Health").connect("healthZero", self, "game_over")
    $HUD.get_node("Health").connect("healthZero", $Player, "on_player_dead")
    $HUD/HBox/VBox_R/MusicOnOffButton.connect("toggled", self, "on_music_toggled")
    $HUD/HBox/VBox_R/TrailOnOffButton.connect("toggled", self, "on_trail_toggled")
    $HUD/HBox/VBox_R/DifficultySlider.connect("value_changed", self, "on_difficulty_changed")
    $HUD/HBox/VBox_R/SizeSlider.connect("value_changed", self, "on_size_slider_changed")
    on_size_slider_changed($HUD/HBox/VBox_R/SizeSlider.value)
    
    get_tree().get_root().connect("size_changed", self, "on_screen_size_changed")
    
    $Music.set_stream(preload('res://art/music/William_Rosati_No_Work.ogg'))
    
    $FoodTimer.connect("timeout", self, "on_Food_timer_timeout")
    $AmmoTimer.connect("timeout", self, "on_Ammo_timer_timeout")
    $BallTimer.connect("timeout", self, "on_BallTimer_timeout")
    
    $ColorRect.color = backgroundColor
    
    if showAds and Engine.has_singleton("AdMob"):
        print("Will show ads")
        Show_Banner_Ads()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func Show_Banner_Ads():
    admob = Engine.get_singleton("AdMob")
    admob.init(ad_isReal, get_instance_id())
    if admob != null:
        admob.loadBanner(ad_BannerId, ad_isOnTop)
        admob.showBanner()

func _on_admob_ad_loaded():
    print("Ad Banner loaded")
    if admob != null:
        var banner_height = admob.getBannerHeight()
        var banner_width = admob.getBannerWidth()
        print("Banner height: ", banner_height)
        print("Banner width: ", banner_width)
        
        var device_size = OS.get_window_size()
        var ratio_x = screen_size.x / device_size.x
        var ratio_y = screen_size.y / device_size.y
        
        var banner_height_adjusted = banner_height * ratio_y
        var banner_width_adjusted = banner_width * ratio_x
        print("Banner height adjusted: ", banner_height_adjusted)
        print("Banner width adjusted: ", banner_width_adjusted)

        var screen_size_cut = Vector2(screen_size.x, screen_size.y - banner_height_adjusted)
        SetGamePort(screen_size_cut, Vector2(0, banner_height_adjusted))
        

func _on_admob_network_error():
    print("admob network error")
    pass
    
func _on_admob_banner_failed_to_load():
    print("admob banner failed to load")
    pass

func SetGamePort(gameSize, origin=Vector2()):
    var curve = Curve2D.new();
    curve.add_point(origin)
    curve.add_point(origin + Vector2(gameSize.x, 0))
    curve.add_point(origin + Vector2(gameSize.x, gameSize.y))
    curve.add_point(origin + Vector2(0, gameSize.y))
    curve.add_point(origin)
    $BallPath.curve = curve    
    
    $ColorRect.rect_size = gameSize
    $ColorRect.rect_position = origin
    
    $HUD.AdjustBasedOnNewPort(gameSize, origin)
    
    $Player.y_clipping_interval = Vector2(origin.y, origin.y + gameSize.y)

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
    var x = rand_range(0.1*screen_size.x, 0.9*screen_size.x)
    var y = rand_range(0.1*screen_size.y, 0.9*screen_size.y)
    if showAds:
        y = rand_range(0.2*screen_size.y, 0.9*screen_size.y)
    
    var food = FOOD.instance();
    add_child(food)
    food.position = Vector2(x, y)
    
    $HUD.connect("start_game", food, "_on_start_game")

func on_Ammo_timer_timeout():
    var x = rand_range(0.1*screen_size.x, 0.9*screen_size.x)
    var y = rand_range(0.1*screen_size.y, 0.9*screen_size.y)
    if showAds:
        y = rand_range(0.2*screen_size.y, 0.9*screen_size.y)
    
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

func on_size_slider_changed(value):
    Globals.gameScale = value/Globals.maxSize
    $Player.resizePlayer()

func IncreaseScore(ds):
    score += ds
    $HUD.update_score(score)

func on_screen_size_changed():
    #screen_size = OS.get_window_size()
    screen_size = get_viewport_rect().size
    $Player.screen_size = screen_size

    #var ratio_x = screen_size.x / Globals.screen_size.x
    #var ratio_y = screen_size.y / Globals.screen_size.y
    #Globals.gameScale_0 = min(ratio_x, ratio_y);
    #$Player.resizePlayer()

    SetGamePort(screen_size)
    $Player.resizePlayer()
    print("screen_size: ", screen_size)

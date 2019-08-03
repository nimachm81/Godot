extends Area2D

var objtype_id = 2

func _ready():
    connect("area_entered", self, "on_Food_area_entered")
    $Timer.connect("timeout", self, "on_Timer_timeout")    
    $Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func on_Food_area_entered(area):
    hide()
    queue_free()
    get_node("/root/Main/HUD/Health").IncreaseHealth(20)

func _on_start_game():
    queue_free()
    
func on_Timer_timeout():
    hide()
    queue_free()    


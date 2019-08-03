extends Node2D

export var health = 1 

signal healthZero

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func UpdateHealth():
    $redbar.rect_scale.x = health
        
func IncreaseHealth(h):
    health += h/100.0
    if health > 1:
        health = 1
    if health < 0.01:
        health = 0
        emit_signal("healthZero")  
    UpdateHealth()
    
func _on_Player_hit():
    print("Health: decreasing")
    IncreaseHealth(-20.0)
    
    
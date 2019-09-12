extends Sprite

var is_visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
    self.visible = is_visible
    $LifeTimer.connect("timeout", self, "on_life_timer_timeout")
    $BlinkTimer.connect("timeout", self, "on_blink_timer_timeout")
    $LifeTimer.start()
    $BlinkTimer.start()

func on_life_timer_timeout():
    queue_free()
    
func on_blink_timer_timeout():
    is_visible = not is_visible
    self.visible = is_visible

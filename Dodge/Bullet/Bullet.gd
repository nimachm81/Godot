extends Area2D

var objtype_id = 3

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
    $Visibility.connect("screen_exited", self, "_on_Visibility_screen_exited")
    connect("body_entered", self, "on_bullet_body_entered")
    $BulletSound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    position += velocity * delta


func _on_Visibility_screen_exited():
    queue_free()

func on_bullet_body_entered(body):
    print("Bullet hit: ", body.name)
    if body.objtype_id == 1:
        body.hide()
        body.queue_free()
        $BlastSound.play()
        get_node("/root/Main").IncreaseScore(int(body.ballColor + 1)*5)
    
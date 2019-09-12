extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    var plat_ind = int(rand_range(0, len(Globals.platform_names))) % len(Globals.platform_names)
    $Sprite.texture = load(Globals.platform_names[plat_ind])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

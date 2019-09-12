extends Node2D


var BODY = preload("res://Body/Body.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    Globals.screen_size = get_viewport_rect().size
    SetPlayerBaseToCenterDistance()
    get_tree().change_scene("res://Game1/Game1.tscn")
    

func SetPlayerBaseToCenterDistance():
    var player = BODY.instance()
    var leg_collisionshape_extent = player.get_node("LegCollisionShape2D").shape.extents
    var torso_collisionshape_extent = player.get_node("BodyCollisionShape2D").shape.extents
    Globals.player_base_to_center_distance = torso_collisionshape_extent.y + 2*leg_collisionshape_extent.y
    print(Globals.player_base_to_center_distance)

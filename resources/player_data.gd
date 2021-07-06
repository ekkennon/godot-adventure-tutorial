extends Node

# physics 2d
const GRAVITY = 4500.0
const FLOOR_DETECT_DISTANCE = 20.0
const FLOOR_NORMAL = Vector2.UP
const MAX_SLIDES = 4
const FLOOR_MAX_ANGLE = 0.9

# groups
const PLAYER_GROUP = "Player"
const ENEMY_GROUP = "Enemy"

# utils
func get_main_node():
	var root_node = get_tree().get_root()
	return root_node.get_child(root_node.get_child_count() - 1)

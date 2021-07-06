extends KinematicBody2D

export var speed = 400.0
export var jump_force = -2250.0
export var initial_health = 3
export var melee_damage = 1
export var launch_power = 1500.0
export var recovery_time = 2.0
export var follow_range = 1500.0
export var change_direction_ease = 1
export var direction_smooth = 1

onready var player : KinematicBody2D = PlayerData.get_main_node().get_node("player")

var velocity = Vector2()
var launch = 1
var is_recovering = false
var recovery_timer = 0
var is_following_player = false
var direction = 1
var player_in_attack_range = false
var player_distance : float
var current_health : int


func _ready():
	current_health = initial_health


func _physics_process(delta):
	if is_recovering:
		recovery_timer += delta
		velocity.x = launch
		launch += (0 - launch) * delta
		if recovery_timer >= recovery_time:
			recovery_timer = 0
			velocity.x = 0
			is_recovering = false
	else:
		player_distance = player.get_position().x - get_position().x
		direction_smooth += (direction - direction_smooth) * delta * change_direction_ease
		velocity.x = 1 * direction_smooth
		
		if velocity.x > .01:
			if $FlipHelper.get_scale().x == -1:
				$FlipHelper.set_scale(Vector2(1, 1))
		elif velocity.x < -.01:
			if $FlipHelper.get_scale().x == 1:
				$FlipHelper.set_scale(Vector2(-1, 1))
		
		if abs(player_distance) < follow_range:
			is_following_player = true
		else:
			is_following_player = false
		
		if is_following_player:
			if player_distance < 0:
				direction = -1
			else:
				direction = 1
		else:
			direction_smooth = direction
		
		if $DetectWallRight.is_colliding():
			var collision_object = $DetectWallRight.get_collider()
			if not collision_object.is_in_group(PlayerData.PLAYER_GROUP):
				if not is_following_player:
					direction = -1
				else:
					if not collision_object.is_in_group(PlayerData.ENEMY_GROUP):
						jump()
		
		if $DetectWallLeft.is_colliding():
			var collision_object = $DetectWallLeft.get_collider()
			if not collision_object.is_in_group(PlayerData.PLAYER_GROUP):
				if not is_following_player:
					direction = 1
				else :
					if not collision_object.is_in_group(PlayerData.ENEMY_GROUP):
						jump()
		
		if not is_following_player:
			if not $DetectFloorRight.is_colliding():
				direction = -1
		
		if not is_following_player:
			if not $DetectFloorLeft.is_colliding():
				direction = 1
		
		if player_in_attack_range:
			$AnimationPlayer.play("Attack")
		
		velocity.x *= speed
	
	velocity.y += PlayerData.GRAVITY * delta
	var snap_vector = Vector2.DOWN * PlayerData.FLOOR_DETECT_DISTANCE if velocity.y == 0.0 else Vector2.ZERO
	var is_on_platform = $platform_detect.is_colliding()
	
	velocity = move_and_slide_with_snap(
		velocity, snap_vector, PlayerData.FLOOR_NORMAL, not is_on_platform, PlayerData.MAX_SLIDES, PlayerData.FLOOR_MAX_ANGLE, false
	)


func jump():
	if is_on_floor():
		velocity.y = jump_force


func hit(damage, attack_dir):
	current_health -= damage
	velocity.y = -launch_power
	launch = launch_power * attack_dir
	recovery_timer = 0
	is_recovering = true
	
	if current_health <= 0:
		die()


func die():
	queue_free()


# Animation Functions
func _attack():
	if player_in_attack_range:
		player.hit(melee_damage, direction)


# Signal Functions
func _on_AttackArea_body_entered(body):
	if body.is_in_group(PlayerData.PLAYER_GROUP):
		player_in_attack_range = true


func _on_AttackArea_body_exited(body):
	if body.is_in_group(PlayerData.PLAYER_GROUP):
		player_in_attack_range = false

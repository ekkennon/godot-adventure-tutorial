extends KinematicBody2D

export var speed = 500.0
export var jump_force = -2250.0
export var initial_health = 5
export var launch_power = 1500
export var recovery_time = 1.8
export var melee_damage = 1
var velocity = Vector2()
var current_health : int
var launch = 1.0
var direction = 1
var is_recovering = false
var recovery_timer = 0
var enemies_in_range = {}

signal inital_health_changed
signal current_health_changed


func _ready():
	current_health = initial_health
	emit_signal("inital_health_changed", initial_health)
	emit_signal("current_health_changed", current_health)
	


func _physics_process(delta):
	velocity.y += PlayerData.GRAVITY * delta
	
	if is_recovering:
		recovery_timer += delta
		velocity.x = launch
		launch += (0 - launch) * delta
		if recovery_timer >= recovery_time:
			velocity.x = 0
			is_recovering = false
	else:
		var horizontal_throw = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		if horizontal_throw > .5:
			direction = 1
		elif horizontal_throw < -.5:
			direction = -1
		
		$FlipHelper.set_scale(Vector2(direction, 1))
		velocity.x = horizontal_throw * speed
		
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = jump_force
		
		if Input.is_action_just_pressed("attack"):
			$AnimationPlayer.play("attack")
	
	var snap_vector = Vector2.DOWN * PlayerData.FLOOR_DETECT_DISTANCE if velocity.y == 0.0 else Vector2.ZERO
	var is_on_platform = $platform_detect.is_colliding()
	
	velocity = move_and_slide_with_snap(
		velocity, snap_vector, PlayerData.FLOOR_NORMAL, not is_on_platform, PlayerData.MAX_SLIDES, PlayerData.FLOOR_MAX_ANGLE, false
	)


func hit(damage, attack_dir):
	current_health -= damage
	velocity.y = -launch_power
	launch = launch_power * attack_dir
	recovery_timer = 0
	is_recovering = true
	
	emit_signal("current_health_changed", current_health)
	
	if current_health <= 0:
		die()


func die():
	print("Player has died...")
	hide()

func new_function():
	pass

# Animation Functions
func _attack():
	for key in enemies_in_range:
		enemies_in_range[key].hit(melee_damage, direction)


# Signal Functions
func _on_AttackArea_body_entered(body):
	if body.is_in_group(PlayerData.ENEMY_GROUP):
		enemies_in_range[body.name] = body


func _on_AttackArea_body_exited(body):
	if body.is_in_group(PlayerData.ENEMY_GROUP):
		enemies_in_range.erase(body.name)

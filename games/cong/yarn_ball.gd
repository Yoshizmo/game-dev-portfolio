extends CharacterBody2D

@export var speed: float = 400.0
@export var speed_boost: float = 120.0
@export var max_speed: float = 700.0
@export var decay_time: float = 2.0
@export var english_strength: float = 0.9
@export var max_bounce_y: float = 0.85
@export var paddle_height: float = 100.0

@onready var GameScene = get_tree().get_root().get_node("GameScene")

var direction := Vector2.RIGHT
var current_speed := 0.0
var active := false

func stop() -> void:
	active = false
	current_speed = 0.0
	velocity = Vector2.ZERO

func launch_random() -> void:
	const MIN_ABS_X := 0.258819 # sin(15°)

	var dir := Vector2.ZERO
	while dir.length() < 0.001 or abs(dir.x) < MIN_ABS_X:
		dir = Vector2(randf_range(-1.0, 1.0), randf_range(-0.6, 0.6))

	direction = dir.normalized()
	current_speed = speed
	active = true
	velocity = direction * current_speed

func _physics_process(delta: float) -> void:
	if !active:
		return

	current_speed = move_toward(
		current_speed,
		speed,
		(max_speed - speed) / decay_time * delta
	)
	velocity = direction * current_speed

	var collision := move_and_collide(velocity * delta)
	if !collision:
		return

	var body := collision.get_collider() as Node
	if body == null:
		return

	if body.name == "LeftGoal" or body.name == "RightGoal":
		GameScene._add_score(2 if body.name == "LeftGoal" else 1)
		GameScene._check_game_end()
		GameScene._reset_game()
		return

	if body.name == "PaddleRight" or body.name == "PaddleLeft":
		var paddle := body as Node2D
		var hit_y := collision.get_position().y
		var half_h := paddle_height * 0.5

		var paddle_center_y := paddle.global_position.y + half_h
		var offset: float = clamp((hit_y - paddle_center_y) / half_h, -1.0, 1.0)

		direction.x = -sign(direction.x)
		direction.y = clamp(direction.y + offset * english_strength, -max_bounce_y, max_bounce_y)
		direction = direction.normalized()

		current_speed = min(current_speed + speed_boost, max_speed)
		velocity = direction * current_speed
		return

	direction = direction.bounce(collision.get_normal()).normalized()
	velocity = direction * current_speed

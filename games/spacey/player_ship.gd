extends CharacterBody2D

signal health_changed(new_health: int, max_health: int)

@export var thrust_power: float = 400.0
@export var rotation_speed: float = 4.0
@export var drag: float = 0.98  # Velocity multiplier per frame (0.98 = 2% decay)
@export var max_speed: float = 600.0
@export var fire_rate: float = 0.15  # Seconds between shots
@export var max_health: int = 100
@export var invincibility_time: float = 1.0  # Seconds of invincibility after hit

var bullet_scene: PackedScene = preload("res://bullet.tscn")
var time_since_shot: float = 0.0
var health: int
var invincible: bool = false

func _ready() -> void:
	health = max_health
	add_to_group("player")

func _physics_process(delta: float) -> void:
	time_since_shot += delta
	_handle_shooting()
	# Rotation
	var rotation_input := Input.get_axis("rotate_left", "rotate_right")
	rotation += rotation_input * rotation_speed * delta

	# Thrust
	if Input.is_action_pressed("thrust"):
		var thrust_direction := Vector2.UP.rotated(rotation)
		velocity += thrust_direction * thrust_power * delta

	# Clamp to max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Apply drag (velocity decay)
	velocity *= drag

	# Stop completely if very slow (prevents endless micro-drift)
	if velocity.length() < 1.0:
		velocity = Vector2.ZERO

	move_and_slide()

func _handle_shooting() -> void:
	if Input.is_action_pressed("shoot") and time_since_shot >= fire_rate:
		time_since_shot = 0.0
		var bullet := bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = Vector2.UP.rotated(rotation)
		bullet.rotation = rotation
		get_tree().current_scene.add_child(bullet)

func take_damage(amount: int) -> void:
	if invincible:
		return

	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)

	if health <= 0:
		_die()
	else:
		_start_invincibility()

func _start_invincibility() -> void:
	invincible = true
	# Flash effect
	var tween := create_tween()
	for i in range(5):
		tween.tween_property($Sprite2D, "modulate:a", 0.3, 0.1)
		tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.1)
	tween.tween_callback(func(): invincible = false)

func _die() -> void:
	# TODO: Game over screen
	print("Player died!")
	# For now, respawn with full health
	health = max_health
	health_changed.emit(health, max_health)
	position = Vector2(576, 324)
	velocity = Vector2.ZERO

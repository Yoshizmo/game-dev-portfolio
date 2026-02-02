extends CharacterBody2D

@export var speed: float = 400.0

func launch_random() -> void:
	var dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	if dir.length() < 0.001:
		dir = Vector2.RIGHT
	velocity = dir.normalized() * speed

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

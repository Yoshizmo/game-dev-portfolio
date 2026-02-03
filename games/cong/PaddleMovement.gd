extends CharacterBody2D

@export var speed: float = 400.0
@export var up_action: StringName
@export var down_action: StringName
@export var acceleration: float = 1000.0

var locked_x: float

func _ready() -> void:
	locked_x = global_position.x

func _physics_process(delta: float) -> void:
	var direction := 0.0
	if Input.is_action_pressed(up_action):
		direction -= 1
	if Input.is_action_pressed(down_action):
		direction += 1
	
	velocity.y = move_toward(velocity.y, direction * speed, acceleration * delta)

	global_position.y = clamp(global_position.y, 100, 880)
	global_position.x = locked_x
	
	move_and_slide()

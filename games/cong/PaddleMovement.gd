extends CharacterBody2D

@export var speed: float = 400.0
@export var up_action: StringName
@export var down_action: StringName
@export var acceleration: float = 1000.0

func _ready() -> void:
	print("paddle y=", global_position.y)
	print("viewport size=", get_viewport_rect().size)
	print("canvas_transform=", get_viewport().get_canvas_transform())

func _physics_process(delta: float) -> void:
	var direction := 0.0
	if Input.is_action_pressed(up_action):
		direction -= 1
	if Input.is_action_pressed(down_action):
		direction += 1
	
	velocity.y = move_toward(velocity.y, direction * speed, acceleration * delta)

	global_position.y = clamp(global_position.y, 100, 880)
	
	move_and_slide()

extends Area2D

@export var health: int = 1
@export var speed: float = 150.0

var path_function: Callable
var path_time: float = 0.0
var base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	path_time += delta
	if path_function.is_valid():
		position = base_position + path_function.call(path_time)

func set_path(base_pos: Vector2, path_func: Callable) -> void:
	base_position = base_pos
	path_function = path_func
	position = base_pos

func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		queue_free()

@export var collision_damage: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(collision_damage)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		take_damage(1)
		area.queue_free()

extends Area2D

@export var speed: float = 800.0
@export var lifetime: float = 2.0

var direction := Vector2.UP

func _ready() -> void:
	add_to_group("bullet")
	# Auto-destroy after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Will be used for enemy hits later
	queue_free()

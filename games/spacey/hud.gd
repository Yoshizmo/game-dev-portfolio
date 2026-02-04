extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	# Connect to player health changes
	var player := get_tree().current_scene.get_node("PlayerShip")
	if player:
		player.health_changed.connect(_on_health_changed)
		health_bar.max_value = player.max_health
		health_bar.value = player.health

func _on_health_changed(new_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = new_health

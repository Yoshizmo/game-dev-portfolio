extends Node2D

@export var star_count: int = 200
@export var area_size: Vector2 = Vector2(2000, 2000)
@export var min_brightness: float = 0.3
@export var max_brightness: float = 1.0
@export var min_size: float = 1.0
@export var max_size: float = 3.0

var stars: Array[Dictionary] = []

func _ready() -> void:
	_generate_stars()

func _generate_stars() -> void:
	stars.clear()
	for i in range(star_count):
		var star := {
			"position": Vector2(
				randf_range(-area_size.x / 2, area_size.x / 2),
				randf_range(-area_size.y / 2, area_size.y / 2)
			),
			"brightness": randf_range(min_brightness, max_brightness),
			"size": randf_range(min_size, max_size)
		}
		stars.append(star)
	queue_redraw()

func _draw() -> void:
	for star in stars:
		var color := Color(1.0, 1.0, 1.0, star.brightness)
		draw_circle(star.position, star.size, color)

extends Node2D

@export var chunk_size: float = 1024.0
@export var render_distance: int = 2  # Chunks in each direction
@export var stars_per_chunk: int = 50
@export var planet_chance: float = 0.3  # Chance per chunk to have a planet

@export var planet_textures: Array[Texture2D] = []

var active_chunks: Dictionary = {}  # Vector2i -> chunk data
var player: Node2D

func _ready() -> void:
	# Find the player
	player = get_tree().current_scene.get_node("PlayerShip")

func _process(_delta: float) -> void:
	if not player:
		return

	var player_chunk := Vector2i(
		floori(player.global_position.x / chunk_size),
		floori(player.global_position.y / chunk_size)
	)

	_update_chunks(player_chunk)

func _update_chunks(center: Vector2i) -> void:
	var needed_chunks: Dictionary = {}

	# Determine which chunks should exist
	for x in range(center.x - render_distance, center.x + render_distance + 1):
		for y in range(center.y - render_distance, center.y + render_distance + 1):
			needed_chunks[Vector2i(x, y)] = true

	# Remove chunks that are too far
	var to_remove: Array[Vector2i] = []
	for chunk_pos in active_chunks:
		if not needed_chunks.has(chunk_pos):
			to_remove.append(chunk_pos)

	for chunk_pos in to_remove:
		_remove_chunk(chunk_pos)

	# Add new chunks
	for chunk_pos in needed_chunks:
		if not active_chunks.has(chunk_pos):
			_create_chunk(chunk_pos)

func _create_chunk(chunk_pos: Vector2i) -> void:
	var chunk_node := Node2D.new()
	chunk_node.name = "Chunk_%d_%d" % [chunk_pos.x, chunk_pos.y]
	add_child(chunk_node)

	var chunk_origin := Vector2(chunk_pos.x * chunk_size, chunk_pos.y * chunk_size)

	# Use chunk position as seed for consistent generation
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(chunk_pos)

	# Generate stars
	var stars_node := Node2D.new()
	stars_node.name = "Stars"
	chunk_node.add_child(stars_node)

	var star_data: Array[Dictionary] = []
	for i in range(stars_per_chunk):
		star_data.append({
			"position": chunk_origin + Vector2(
				rng.randf() * chunk_size,
				rng.randf() * chunk_size
			),
			"brightness": rng.randf_range(0.3, 1.0),
			"size": rng.randf_range(1.0, 2.5)
		})

	stars_node.set_meta("star_data", star_data)
	stars_node.draw.connect(_draw_stars.bind(stars_node))
	stars_node.queue_redraw()

	# Maybe spawn a planet
	if planet_textures.size() > 0 and rng.randf() < planet_chance:
		var planet := Sprite2D.new()
		planet.texture = planet_textures[rng.randi() % planet_textures.size()]
		planet.position = chunk_origin + Vector2(
			rng.randf() * chunk_size,
			rng.randf() * chunk_size
		)
		planet.scale = Vector2.ONE * rng.randf_range(2.0, 6.0)
		planet.modulate = Color(0.6, 0.6, 0.6, 0.5)
		chunk_node.add_child(planet)

	active_chunks[chunk_pos] = chunk_node

func _draw_stars(stars_node: Node2D) -> void:
	var star_data: Array = stars_node.get_meta("star_data", [])
	for star in star_data:
		var color := Color(1.0, 1.0, 1.0, star.brightness)
		stars_node.draw_circle(star.position, star.size, color)

func _remove_chunk(chunk_pos: Vector2i) -> void:
	if active_chunks.has(chunk_pos):
		active_chunks[chunk_pos].queue_free()
		active_chunks.erase(chunk_pos)

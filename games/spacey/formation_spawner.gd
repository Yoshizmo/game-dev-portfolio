extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var spawn_distance: float = 800.0  # Distance from player to spawn

var player: Node2D
var time_since_spawn: float = 0.0

enum FormationType { WAVY_LINE, CIRCLE, V_FORMATION, SPIRAL }

func _ready() -> void:
	player = get_tree().current_scene.get_node("PlayerShip")
	# Spawn first wave quickly
	time_since_spawn = spawn_interval - 1.0

func _process(delta: float) -> void:
	if not player:
		return

	time_since_spawn += delta
	if time_since_spawn >= spawn_interval:
		time_since_spawn = 0.0
		_spawn_formation()

func _spawn_formation() -> void:
	var formation_type: FormationType = randi() % FormationType.size() as FormationType
	var spawn_angle := randf() * TAU
	var spawn_center := player.global_position + Vector2.from_angle(spawn_angle) * spawn_distance

	match formation_type:
		FormationType.WAVY_LINE:
			_spawn_wavy_line(spawn_center, spawn_angle)
		FormationType.CIRCLE:
			_spawn_circle(spawn_center, spawn_angle)
		FormationType.V_FORMATION:
			_spawn_v_formation(spawn_center, spawn_angle)
		FormationType.SPIRAL:
			_spawn_spiral(spawn_center, spawn_angle)

func _spawn_wavy_line(center: Vector2, angle: float) -> void:
	var count := randi_range(5, 8)
	var spacing := 60.0
	var perpendicular := Vector2.from_angle(angle + PI / 2)
	var move_dir := Vector2.from_angle(angle + PI)  # Move toward player

	for i in range(count):
		var offset := (i - count / 2.0) * spacing
		var start_pos := center + perpendicular * offset
		var enemy := _create_enemy()
		var phase := i * 0.5  # Offset wave phase per enemy

		enemy.set_path(start_pos, func(t: float) -> Vector2:
			var wave := sin(t * 3.0 + phase) * 50.0
			return move_dir * t * 150.0 + perpendicular * wave
		)

func _spawn_circle(center: Vector2, angle: float) -> void:
	var count := randi_range(6, 10)
	var radius := 100.0
	var move_dir := Vector2.from_angle(angle + PI)

	for i in range(count):
		var enemy := _create_enemy()
		var enemy_angle := (float(i) / count) * TAU

		enemy.set_path(center, func(t: float) -> Vector2:
			var rotating_angle := enemy_angle + t * 2.0
			var circle_pos := Vector2.from_angle(rotating_angle) * radius
			return move_dir * t * 100.0 + circle_pos
		)

func _spawn_v_formation(center: Vector2, angle: float) -> void:
	var count := 7
	var spacing := 50.0
	var move_dir := Vector2.from_angle(angle + PI)
	var perpendicular := Vector2.from_angle(angle + PI / 2)

	for i in range(count):
		var row := absi(i - count / 2)
		var side := 1 if i > count / 2 else -1
		if i == count / 2:
			side = 0
		var offset_x := side * row * spacing * 0.7
		var offset_y := row * spacing

		var start_pos := center + perpendicular * offset_x + move_dir.rotated(PI) * offset_y
		var enemy := _create_enemy()

		enemy.set_path(start_pos, func(t: float) -> Vector2:
			return move_dir * t * 120.0
		)

func _spawn_spiral(center: Vector2, angle: float) -> void:
	var count := randi_range(8, 12)
	var move_dir := Vector2.from_angle(angle + PI)

	for i in range(count):
		var enemy := _create_enemy()
		var start_angle := (float(i) / count) * TAU
		var start_radius := 20.0 + i * 15.0

		enemy.set_path(center, func(t: float) -> Vector2:
			var spiral_angle := start_angle + t * 1.5
			var spiral_radius := start_radius + t * 30.0
			var spiral_pos := Vector2.from_angle(spiral_angle) * spiral_radius
			return move_dir * t * 80.0 + spiral_pos
		)

func _create_enemy() -> Node2D:
	var enemy: Node2D = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	return enemy

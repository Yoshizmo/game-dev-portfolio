extends Node

@export var yarn_ball: CharacterBody2D
@export var countdown_container: Control
@export var countdown_label: Label
@export var player1_score_label: Label
@export var player2_score_label: Label

var player1score: int = 0
var player2score: int = 0
var spawn_position: Vector2

func _ready() -> void:
	spawn_position = Vector2(960, 540)
	randomize()

	yarn_ball.global_position = spawn_position
	yarn_ball.stop()

	await _do_countdown()
	yarn_ball.launch_random()

func _reset_game() -> void:
	yarn_ball.global_position = spawn_position
	yarn_ball.stop()

	await _do_countdown()
	yarn_ball.launch_random()

func _do_countdown() -> void:
	countdown_container.visible = true
	for i in range(3, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	countdown_container.visible = false

func _check_game_end() -> void:
	if player1score >= 5 or player2score >= 5:
		player1score = 0
		player2score = 0
		get_tree().quit()

func _add_score(player: int) -> void:
	if player == 1:
		player1score += 1
		player1_score_label.text = str(player1score)
	else:
		player2score += 1
		player2_score_label.text = str(player2score)

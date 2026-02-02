extends Node

@export var yarn_ball: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	#countdown from 3
	for i in range(3, 0, -1):
		print(i)
		await get_tree().create_timer(1.0).timeout
	print("Go!")

	#start game
	#add random velocity to yarn ball
	yarn_ball.launch_random()

	pass # Replace with function body.

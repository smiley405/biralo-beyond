extends Node


var scene_index: int = 5
var game_won: bool = false
var checkpoint: Vector2 = Vector2.ZERO


func reset():
	# Reset current level state
	game_won = false


func reset_all():
	reset()
	checkpoint = Vector2.ZERO
	scene_index = 1

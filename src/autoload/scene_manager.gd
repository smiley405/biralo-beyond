extends Node


var _scenes: Array[PackedScene] = [
	preload("res://src/scenes/level_1/level_1.tscn"),
	preload("res://src/scenes/level_2/level_2.tscn"),
	preload("res://src/scenes/level_3/level_3.tscn"),
	preload("res://src/scenes/level_4/level_4.tscn"),
	preload("res://src/scenes/level_5/level_5.tscn"),
	preload("res://src/scenes/level_6/level_6.tscn"),
]


func set_scene(scene_index: int) -> void:
	var scene: PackedScene = _scenes[scene_index]
	GameState.scene_index = scene_index
	# call_deferred() waits until it's safe to make changes
	get_tree().call_deferred("change_scene_to_packed", scene)


func reload_scene() -> void:
	set_scene(GameState.scene_index)
	GameState.reset()


func next_scene() -> void:
	GameState.scene_index += 1
	set_scene(GameState.scene_index)

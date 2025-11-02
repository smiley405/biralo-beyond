extends Node


var _scenes: Array[PackedScene] = [
	preload("res://src/scenes/level_1/level_1.tscn"),
	preload("res://src/scenes/level_2/level_2.tscn"),
	preload("res://src/scenes/level_3/level_3.tscn"),
	preload("res://src/scenes/level_4/level_4.tscn"),
	preload("res://src/scenes/level_5/level_5.tscn"),
	preload("res://src/scenes/level_6/level_6.tscn"),
	preload("res://src/scenes/level_7/level_7.tscn"),
	preload("res://src/scenes/level_8/level_8.tscn"),
	preload("res://src/scenes/level_9/level_9.tscn"),
	preload("res://src/scenes/level_10/level_10.tscn"),
]


func set_scene(scene_index: int) -> void:
	var scene: PackedScene = _scenes[scene_index]
	GameState.scene_index = scene_index
	_change_scene_deferred(scene)


func _change_scene_deferred(scene: PackedScene) -> void:
	# call_deferred() waits until it's safe to make changes
	call_deferred("_change_scene", scene)


func _change_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
	Events.emit_signal("scene_changed")


func reload_scene() -> void:
	set_scene(GameState.scene_index)
	GameState.reset()


func next_scene() -> void:
	GameState.scene_index += 1
	set_scene(GameState.scene_index)

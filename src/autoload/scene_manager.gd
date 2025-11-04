extends Node


func set_scene(scene_index: int) -> void:
	var scene: PackedScene = SceneManifest.SCENE_MAP[scene_index]
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

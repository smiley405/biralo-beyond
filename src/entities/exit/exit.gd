class_name Exit
extends Node2D


var _exited: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _exited or not body.is_in_group("player"):
		return

	_exited = true
	SceneManager.next_scene()

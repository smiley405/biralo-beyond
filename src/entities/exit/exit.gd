extends Node2D


var _exited: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _exited or not body.type == "player":
		return
	
	_exited = true
	SceneManager.next_scene()

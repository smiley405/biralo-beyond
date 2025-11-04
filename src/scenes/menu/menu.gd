extends Node2D


var _clicked: bool = false

@onready var _transition: Transition = $Transition


func _input(event) -> void:
	if _clicked:
		return

	if event is InputEventMouseButton and event.pressed:
		Events.emit_signal("camera_shake")
		_transition.fade_out(_on_clicked)


func _on_clicked() -> void:
	SceneManager.next_scene()

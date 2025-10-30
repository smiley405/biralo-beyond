class_name BossHealthBar
extends Node2D


@export var fps: int = 10

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.play("start")
	Events.update_boss_health_bar.connect(_on_update_boss_health_bar)


func _goto_and_stop(frame_index: int) -> void:
	var time: float = float(frame_index)/float(fps)
	_animation_player.play("update")
	_animation_player.stop()
	_animation_player.seek(time, true)

	if frame_index <= 0:
		_animation_player.play("end")


func _on_update_boss_health_bar(frame_index: int) -> void:
	_goto_and_stop(frame_index)

extends Node2D


@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.play("default")
	Events.game_finished.connect(_on_game_finished)


func _on_game_finished() -> void:
	_animation_player.play("end_credits")

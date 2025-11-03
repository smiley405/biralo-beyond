class_name Torch
extends Area2D


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	var total_frames = _animated_sprite.sprite_frames.get_frame_count("default")
	var rand_frame_index: int = randi() % total_frames
	_animated_sprite.play("default")
	_animated_sprite.set_frame_and_progress(rand_frame_index, true)

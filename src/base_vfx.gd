class_name BaseVfx
extends Node2D


var type: String = ""

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.stop()
	_animated_sprite.connect("animation_finished", _on_animation_finished)


func play() -> void:
	if _animated_sprite.is_playing():
		return
	visible = true
	_animated_sprite.play("default")


func get_animated_sprite_size() -> Vector2:
	var texture = _animated_sprite.sprite_frames.get_frame_texture(_animated_sprite.animation, _animated_sprite.frame)
	return texture.get_size() * _animated_sprite.scale


func _on_animation_finished() -> void:
	visible = false

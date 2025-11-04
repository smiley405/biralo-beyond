class_name Transition
extends CanvasLayer


var _on_fade_out_callback: Callable
var _on_fade_in_callback: Callable

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.play("default")
	_animation_player.connect("animation_finished", _on_animation_finished)


func fade_out(callback: Callable) -> void:
	_animation_player.play("fade_out")
	_on_fade_out_callback = callback


func fade_in(callback: Callable) -> void:
	_animation_player.play("fade_in")
	_on_fade_in_callback = callback


func _on_animation_finished(anim_name: String) -> void:
	if _on_fade_out_callback.is_valid():
		_on_fade_out_callback.call()

	if _on_fade_in_callback.is_valid():
		_on_fade_in_callback.call()

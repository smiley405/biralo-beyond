class_name Alice
extends Node2D


var _loved_cat: bool = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.play("wave")


func _do_fall() -> void:
	_animated_sprite.play("fall")
	var _tween = create_tween()
	var target_y = position.y + 96.0
	_tween.tween_property(self, "position:y", target_y, 1.0).set_delay(0.2)


## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(from: Node2D, trigger: Node2D) -> void:
	if from.is_in_group("player"):
		_do_fall()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _loved_cat or not body.is_in_group("player"):
		return

	var player: Player = body as Player
	player.do_love()

	_loved_cat = true
	_animated_sprite.play("love")
	GameState.game_won = true

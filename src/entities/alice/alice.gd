class_name Alice
extends Area2D


@export var flip_h: bool = false

var type: String = "Alice"
var _loved_cat: bool = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.play("wave")
	_animated_sprite.flip_h = flip_h


func _do_fall() -> void:
	_animated_sprite.play("fall")
	var _tween: Tween = create_tween()
	var target_y: float = position.y + 96.0
	_tween.tween_property(self, "position:y", target_y, 1.0).set_delay(0.2)


func run_and_vanish() -> void:
	var _tween: Tween = create_tween()
	var target_x: float = 100.0
	_animated_sprite.play("run")

	_tween.tween_property(self, "position:x", target_x, 3.0).set_delay(0.1)
	_tween.finished.connect(_on_tween_run_finished)


## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(from: Node2D, trigger: Node2D) -> void:
	if from.is_in_group("player"):
		_do_fall()


func _on_tween_run_finished() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _loved_cat or not body.is_in_group("player"):
		return

	var player: Player = body as Player
	player.do_love()

	_loved_cat = true
	_animated_sprite.play("love")
	GameState.game_won = true

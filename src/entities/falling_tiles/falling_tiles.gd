class_name FallingTiles
extends Area2D


var _collapsed: bool = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.stop()


func _collapse() -> void:
	_collapsed = true
	_animated_sprite.play("fall")
	Events.camera_shake.emit()


## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(from: Node2D, trigger: Node2D) -> void:
	if from.is_in_group("player"):
		_collapse()


# Detects player > body:collisionShape2d, to detect area2d use area-entered or leeave
# The signal detector node should have the mask pointing to palyer, not the other way round
func _on_body_entered(body: Node2D) -> void:
	if _collapsed or not body.is_in_group("player"):
		return
	_collapse()

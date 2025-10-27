class_name FallingTiles
extends Area2D


var _collapsed: bool = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.stop()
	_animated_sprite.connect("animation_finished", _on_animated_sprite_complete)


func collapse() -> void:
	_collapsed = true
	_animated_sprite.play("fall")
	Events.camera_shake.emit()


## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(from: Node2D, trigger: Node2D) -> void:
	if from.is_in_group("player"):
		collapse()
	if from.is_in_group("boulders"):
		collapse()
	if from.is_in_group("alice"):
		collapse()


# Detects player > body:collisionShape2d, to detect area2d use area-entered or leeave
# The signal detector node should have the mask pointing to palyer, not the other way round
func _on_body_entered(body: Node2D) -> void:
	if _collapsed or not body.is_in_group("player"):
		return
	collapse()


func _on_animated_sprite_complete() -> void:
	queue_free()

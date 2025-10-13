extends Area2D


var _collapsed: bool = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.stop()

# Detects player > body:collisionShape2d, to detect area2d use area-entered or leeave
# The signal detector node should have the mask pointing to palyer, not the other way round
func _on_body_entered(body: Node2D) -> void:
	if _collapsed:
		return
	
	_collapsed = true
	_animated_sprite.play("fall")

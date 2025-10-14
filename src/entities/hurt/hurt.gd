class_name Hurt
extends Node2D


var _hurt: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _hurt or not body.is_in_group("player"):
		return

	_hurt = true

	var player: Player = body as Player
	player.receive_damage(1, self)

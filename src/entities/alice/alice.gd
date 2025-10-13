extends Node


var _loved_cat: bool = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_animated_sprite.play("wave")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _loved_cat or not body.type == "player":
		return
	
	var player: Player = body as Player
	player.do_love()
	
	_loved_cat = true
	_animated_sprite.play("love")

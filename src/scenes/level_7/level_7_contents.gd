extends Node2D


@onready var _falling_tiles_ground: CollisionShape2D = $StaticBody2D/FallingTilesGround


func disable_ground_falling_tiles() -> void:
	_falling_tiles_ground.call_deferred("set_disabled", true)

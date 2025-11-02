extends BaseLevel


@onready var _player: Player = $Player


func _init_after_ready() -> void:
	super._init_after_ready()
	_player.jump_enabled = false
	_player.attack_enabled = false

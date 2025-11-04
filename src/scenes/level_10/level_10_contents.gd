extends Node2D


@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.play("default")
	Events.game_finished.connect(_on_game_finished)


func _process(delta: float) -> void:
	if GameState.game_won:
		if Input.is_action_just_pressed("attack"):
			GameState.reset_all()
			SceneManager.set_scene(1)


func _on_game_finished() -> void:
	_animation_player.play("end_credits")

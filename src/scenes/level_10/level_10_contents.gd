extends Node2D


@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.play("default")
	Events.game_finished.connect(_on_game_finished)


func _process(delta: float) -> void:
	if GameState.game_won:
		if Input.is_action_just_pressed("attack"):
			SceneManager.set_scene(0)
			GameState.reset_all()


func _on_game_finished() -> void:
	_animation_player.play("end_credits")

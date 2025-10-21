extends Camera2D


@export var shake_duration: float = 0.2
@export var shake_strength: Vector2 = Vector2(0, 1)

@onready var _shake_timer: Timer = $ShakeTimer


func _ready() -> void:
	Events.camera_shake.connect(_on_shake)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	update_shake()


func update_shake():
	var delta: float = _shake_timer.time_left
	if delta:
		self.set_offset(Vector2(
			randf_range(-1.0, 1.0) * shake_strength.x,
			randf_range(-1.0, 1.0) * shake_strength.y
		))


func _on_shake(strength: Vector2 = shake_strength, duration: float = shake_duration) -> void:
	if strength:
		shake_strength = strength
	if duration:
		shake_duration = duration
	_shake_timer.start(shake_duration)

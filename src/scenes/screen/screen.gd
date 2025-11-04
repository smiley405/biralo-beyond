extends CanvasLayer


@export var touch_controls_enabled: bool = true

@onready var _touch_controls: CanvasLayer = $TouchControls


func _ready() -> void:
	_touch_controls.visible = touch_controls_enabled

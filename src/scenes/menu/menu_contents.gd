extends Node2D


@onready var _version_label: Label = $Instructions/VersionLabel


func _ready() -> void:
	_version_label.text = Utils.GAME_VERSION

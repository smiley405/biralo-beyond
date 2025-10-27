@tool
class_name LabelBox
extends Node2D


@export var color: Color
@export var activated_color: Color

var activated: bool = false

@onready var text_container: Node2D = $Text
@onready var label: Label = $Text/Label
@onready var color_rect: ColorRect = $Rect/ColorRect


func _ready() -> void:
	reset()


func activate() -> void:
	activated = true


func reset() -> void:
	activated = false


func set_box_color(box_color: Color) -> void:
	if not activated:
		color_rect.color = box_color


func update_display(text: String) -> void:
	if color_rect and text_container:
		color_rect.color = color if not activated else activated_color
		label.text = text
		text_container.global_scale = Vector2.ONE

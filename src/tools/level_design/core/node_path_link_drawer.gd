@tool
class_name NodePathLinkDrawer
extends Node2D
# This tool draws a continuous line linking all targets.

@export var tool_name: String = ""
## Enables or disables the use of 'box_color'.
## When false, 'box_color' is ignored and no color is applied to the box.
@export var use_box_color: bool = false
## The color to apply to the box when 'use_box_color' is true.
## This value is ignored if 'use_box_color' is false.
@export var box_color: Color
@export var visible_in_game: bool = false
@export var targets: Array[NodePath] = []

var triggered_entity = null

@onready var label_box: LabelBox = $LabelBox


func _ready() -> void:
	if is_display_editor_hint():
		label_box.update_display(tool_name)
		if use_box_color:
			label_box.set_box_color(box_color)
	else:
		label_box.visible = false


func _process(delta: float) -> void:
	if is_display_editor_hint():
		label_box.update_display(tool_name)
		if use_box_color:
			label_box.set_box_color((box_color))
		queue_redraw()


func _draw() -> void:
	if is_display_editor_hint():
		update_editor_target_lines(targets)


func update_editor_target_lines(new_targets = []) -> void:
	for target in new_targets:
		if target:
			var node = get_node(target)
			if node:
				draw_line(to_local(global_position), to_local(node.global_position), Color.GRAY, 0.1)


func call_targets_func(fn_name: String, args = []) -> void:
	for target in targets:
		if target:
			var node = get_node(target)
			if node and node.has_method(fn_name):
				node.callv(fn_name, args)


func is_display_editor_hint() -> bool:
	return Engine.is_editor_hint() or (not Engine.is_editor_hint() and visible_in_game)

@tool
class_name Trigger
extends NodePathLinkDrawer
# This tool can be use for triggerer listener.
#
# To set the Targets:
# Set the required Size
# and select a node from the node tree as required
#
# To connect and use it from the entity's class/ target node's class: [br]
# ## [param entity] - is a node which trrigered it. i.e player, enemies [br]
# ## [param trigger] - is the node that's been triggered
# func triggred_by(entity, trigger):
# 	do_something(entity.x, entity.y)
#


var _is_reactive: bool = true
var _triggered: bool = false


func set_reactive(reactive: bool):
	_is_reactive = reactive


func _on_body_entered(body: Node2D) -> void:
	if _is_reactive and not _triggered:
		_triggered = true
		call_targets_func("triggered_by", [body, self])
		if is_display_editor_hint():
			label_box.activate()

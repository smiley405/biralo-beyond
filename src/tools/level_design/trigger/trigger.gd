@tool
class_name Trigger
extends NodePathLinkDrawer
## A utility node for listening to trigger events and forwarding them to configured targets.
##
## This tool is designed to act as a listener for trigger events, such as interactions from players,
## enemies, or other entities. When triggered, it can forward the event to one or more target nodes.
##
## Setup:
## - Add this node to your scene.
## - In the Inspector, configure the `Targets` array:
##   - Set the desired size.
##   - Assign each entry to a node from the scene tree.
##
## Usage:
## Call `triggered_by(entity, trigger)` from the entity or target node's script to activate the listener.
##
## Parameters:
## - `entity`: The node that initiated the trigger (e.g. player, enemy).
## - `trigger`: The node that was triggered.
##
## Example:
## func triggered_by(entity, trigger):
##     do_something(entity.x, entity.y)


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


func _on_area_entered(area: Area2D) -> void:
	_on_body_entered(area)

@tool
class_name Delay
extends NodePathLinkDrawer
# This tool is use to set a delay trigger call to the target nodes
#
# To use it:
# First have this tool in the scene
# And connect this node to a trigger_tool > targets path
#
# In the Inspector > Targets
# Set the required Size
# - Select a node from the node tree as required
# - Set the Delay value
#
# To connect and use it from the entity's class/ target node's class: [br]
# ## [param entity] - is a node which trrigered it. i.e player, enemies [br]
# ## [param trigger] - is the node that's been triggered
# func triggered_by(entity, trigger):
#	# Example
# 	if is_instance_of(entity, Player):
# 		do_something()
#


@export var delay: float = 1.0

@onready var delay_timer: Timer = $DelayTimer

## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(entity, trigger) -> void:
	triggered_entity = entity
	delay_timer.start(delay)


## Once the delay timeout is completed,
## it calls the triggered_entity > triggered_by(..)
func _on_DelayTimer_timeout():
	call_targets_func("triggered_by", [triggered_entity, self])

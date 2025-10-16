@tool
class_name Stop
extends NodePathLinkDrawer
# This tool is use to stop the target nodes
#
# To use it:
# First have this tool in the scene and the trigger_tool aswell
#
# Select the trigger_tool
# From the trigger_tool > Inspector:
# To set the Targets:
# Set the required Size
# and select this tool from the node tree
#
# To connect and use it from the entity's class/ target node's class:
# ## @param: entity - is a node which trrigered it. i.e player, enemies
# ## @param: trigger - is the node that's been triggered
# func triggered_by(from, trigger):
# 	# Example
# 	if is_instance_of(trigger, Stop):
# 		do_something()
#

func triggered_by(entity, tirgger) -> void:
	# This function is called internally by the trigger_tool
	call_targets_func("triggered_by", [entity, self])

@tool
class_name Delay
extends NodePathLinkDrawer
## A utility node for triggering target nodes with a delay.
##
## This tool allows you to configure delayed method calls to specific target nodes.
## It is designed to be used in conjunction with a trigger system, such as a player
## or enemy interaction, and can be set up entirely through the editor.
##
## Setup:
## 1. Add this node to your scene.
## 2. Connect it to a trigger tool via the `targets` path.
##
## Configuration (via Inspector):
## - Expand the `Targets` array.
## - Set the desired size (number of targets).
## - For each entry:
##   - Assign a node from the scene tree.
##   - Set the delay (in seconds) before the method is triggered.
##
## Usage:
## Call `triggered_by(entity, trigger)` from the entity or target node's script.
##
## Parameters:
## - `entity`: The node that initiated the trigger (e.g. player, enemy).
## - `trigger`: The node that was triggered.
##
## Example:
## func triggered_by(entity, trigger):
##     if entity.is_in_group("player"):
##         do_something()


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

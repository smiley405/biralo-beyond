@tool
class_name MethodRouter
extends NodePathLinkDrawer
## A utility node for dynamically invoking methods on its parent node.
##
## This class allows you to configure a single method name and its arguments via the editor,
## and trigger that method at runtime. It is designed for 1-to-1 connections, where a specific
## action (e.g., player interaction or event) should call a specific method on the parent node.
##
## Usage:
## - Assign the method name to `method_name`.
## - Optionally provide arguments in `method_args`.
## - Call `trigger()` to invoke the method on the parent node.
##
## Example:
##   method_name = "open_door"
##   method_args = [true]
##   trigger() → calls get_parent().open_door(true)
##
## Notes:
## - The method must exist on the parent node.
## - Arguments are passed using `callv()` for flexibility.
## - This node is intended for tight, editor-configurable logic—not for broadcasting or multi-listener setups.


@export var method_to_call: String
@export var args_for_method: Array[String] = []


## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(entity, trigger) -> void:
	call_targets_func(method_to_call, args_for_method)

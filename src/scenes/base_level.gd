extends Node2D


var vfx_pool: VfxPool


func _ready() -> void:
	vfx_pool = preload("res://src/pools/vfx_pool.gd").new()
	add_child(vfx_pool)
	
	# Inject vfx_pool to the only node that has group > vfx_targets
	for node in get_tree().get_nodes_in_group("vfx_targets"):
		node.vfx_pool = vfx_pool

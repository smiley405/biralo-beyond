class_name BaseLevel
extends Node2D


var vfx_pool: VfxPool
var projectile_pool: ProjectilePool


func _ready() -> void:
	call_deferred("_init_after_ready")


func _init_after_ready() -> void:
	vfx_pool = preload("res://src/pools/vfx_pool.gd").new()
	projectile_pool = preload("res://src/pools/projectile_pool.gd").new()
	add_child(vfx_pool)
	add_child(projectile_pool)

	# Inject vfx_pool to the only node that has group > vfx_targets
	for node in get_tree().get_nodes_in_group("vfx_targets"):
		node.vfx_pool = vfx_pool

	# Inject projectile_pool to the only node that has group > vfx_targets
	for node in get_tree().get_nodes_in_group("projectile_targets"):
		node.projectile_pool = projectile_pool

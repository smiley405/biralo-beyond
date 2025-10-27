class_name VfxPool
extends Node


var _vfx_scenes: Dictionary[String, Dictionary] = {
	"love": {
		"total": 1,
		"scene": preload("res://src/vfx/love/love_vfx.tscn")
	},
	"impact_dusts": {
		"total": 3,
		"scene": preload("res://src/vfx/impact_dusts/imapct_dusts.tscn")
	},
	"fire_ball_impact": {
		"total": 10,
		"scene": preload("res://src/vfx/fire_ball_impact/fire_ball_impact.tscn")
	},
	"blast": {
		"total": 8,
		"scene": preload("res://src/vfx/blast/blast.tscn")
	},
	"walk_dusts_1": {
		"total": 3,
		"scene": preload("res://src/vfx/walk_dusts_1/walk_dusts_1.tscn")
	},
	"walk_dusts_2": {
		"total": 3,
		"scene": preload("res://src/vfx/walk_dusts_2/walk_dusts_2.tscn")
	},
	"beehive_shoot_trails": {
		"total": 10,
		"scene": preload("res://src/vfx/beehive_shoot_trails/beehive_shoot_trails.tscn")
	},
}

## Dictionary[String, Array[PackedScene]]
var _pool: Dictionary[String, Array] = {}


func _ready() -> void:
	for key in _vfx_scenes:
		_pool[key] = []
		var data: Dictionary = _vfx_scenes[key] as Dictionary
		var total: int = data.total as int
		var scene: PackedScene = data.scene as PackedScene

		for i in range(data.total):
			var vfx: BaseVfx = scene.instantiate() as BaseVfx
			vfx.type = key
			add_child(vfx)
			# after adding child
			vfx.deactivate()
			_pool[key].append(vfx)


func get_vfx(type: String) -> BaseVfx:
	for vfx in _pool[type]:
		var _vfx: BaseVfx = vfx as BaseVfx
		if not vfx.visible:
			return vfx
	return null

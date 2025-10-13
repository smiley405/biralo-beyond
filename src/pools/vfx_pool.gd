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
	}
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
			vfx.visible = false
			add_child(vfx)
			_pool[key].append(vfx)


func get_vfx(type: String) -> BaseVfx:
	for vfx in _pool[type]:
		var _vfx: BaseVfx = vfx as BaseVfx
		if not vfx.visible:
			return vfx
	return null

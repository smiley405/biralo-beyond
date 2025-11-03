class_name VfxPool
extends Node


## Dictionary[String, Array[PackedScene]]
var _pool: Dictionary[String, Array] = {}


func _ready() -> void:
	var entries: Dictionary[String, Dictionary] = VFXManifest.VFX_MAP
	for key in entries:
		_pool[key] = []
		var data: Dictionary = entries[key] as Dictionary
		var total: int = data.total as int
		var scene: PackedScene = data.scene as PackedScene

		for i in range(data.total):
			var vfx: BaseVfx = scene.instantiate() as BaseVfx
			vfx.type = key
			add_child(vfx)
			# after adding child
			vfx.deactivate()
			_pool[key].append(vfx)


## Example: get_vfx(VFXManifest.VFX_MAP.BLAST) - this is for type safety
func get_vfx(vfx_data: Dictionary) -> BaseVfx:
	var vfx_name: String = Utils.get_object_key(vfx_data, VFXManifest.VFX_MAP)
	for vfx in _pool[vfx_name]:
		var _vfx: BaseVfx = vfx as BaseVfx
		if not vfx.visible:
			return vfx
	return null

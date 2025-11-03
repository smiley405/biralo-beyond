class_name ProjectilePool
extends Node


## Dictionary[String, Array[PackedScene]]
var _pool: Dictionary[String, Array] = {}


func _ready() -> void:
	var entries:  Dictionary[String, Dictionary] = ProjectileManifest.PROJECTILE_MAP

	for key in entries:
		_pool[key] = []
		var data: Dictionary = entries[key] as Dictionary
		var total: int = data.total as int
		var scene: PackedScene = data.scene as PackedScene

		for i in range(data.total):
			var projectile: BaseProjectile = scene.instantiate() as BaseProjectile
			projectile.type = key
			add_child(projectile)
			# after adding child
			projectile.deactivate()
			_pool[key].append(projectile)


## Example: get_projectile(ProjectileManifest.PROJECTILE_MAP.FIREBALL) - this is for type safety
func get_projectile(projectile_data: Dictionary) -> BaseProjectile:
	var projectile_name: String = Utils.get_object_key(projectile_data, ProjectileManifest.PROJECTILE_MAP)
	for projectile in _pool[projectile_name]:
		var _projectile: BaseProjectile = projectile as BaseProjectile
		if not _projectile.visible:
			return _projectile
	return null

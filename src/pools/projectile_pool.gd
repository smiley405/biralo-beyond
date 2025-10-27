class_name ProjectilePool
extends Node


var _projectile_scenes: Dictionary[String, Dictionary] = {
	"fire_ball": {
		"total": 10,
		"scene": preload("res://src/projectiles/fire_ball/fire_ball.tscn")
	},
	"bee": {
		"total": 10,
		"scene": preload("res://src/projectiles/bee/bee.tscn")
	}
}

## Dictionary[String, Array[PackedScene]]
var _pool: Dictionary[String, Array] = {}


func _ready() -> void:
	for key in _projectile_scenes:
		_pool[key] = []
		var data: Dictionary = _projectile_scenes[key] as Dictionary
		var total: int = data.total as int
		var scene: PackedScene = data.scene as PackedScene

		for i in range(data.total):
			var projectile: BaseProjectile = scene.instantiate() as BaseProjectile
			projectile.type = key
			add_child(projectile)
			# after adding child
			projectile.deactivate()
			_pool[key].append(projectile)


func get_projectile(type: String) -> BaseProjectile:
	for projectile in _pool[type]:
		var _projectile: BaseProjectile = projectile as BaseProjectile
		if not _projectile.visible:
			return _projectile
	return null

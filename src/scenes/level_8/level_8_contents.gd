extends Node2D


# Will be set from root level
var projectile_pool: ProjectilePool

@onready var _wall_explosion_particles: GPUParticles2D = $WallExplosionParticles
@onready var _brick_wall_layer: TileMapLayer = $BrickWallLayer
@onready var _brick_wall_hitbox: CollisionShape2D = $StaticBody2D/BrickWallHitbox
@onready var _beehives: Node2D = $Beehives


func _ready() -> void:
	add_to_group("projectile_targets")
	Events.boss_defeated.connect(_on_boss_defeated)
	Events.beehives_summon_started.connect(_on_beehives_summon_started)
	Events.beehives_summon_finished.connect(_on_beehives_summon_finished)


func _add_falling_beehive_projectile(pos: Vector2) -> void:
	var projectile = projectile_pool.get_projectile(ProjectileManifest.PROJECTILE_MAP.FALLING_BEEHIVE)
	var projectile_speed: float = 55.0
	if projectile and not projectile.visible:
		var start_position: Vector2 = Vector2(pos.x, pos.y)
		var shoot_direction = Vector2.DOWN
		projectile.speed = Vector2(0, projectile_speed)
		projectile.activate(start_position, shoot_direction)


func _blast_wall() -> void:
	_wall_explosion_particles.emitting = true
	_brick_wall_layer.visible = false
	_brick_wall_hitbox.set_deferred("disabled", true)
	AudioManager.play_sfx(AudioManifest.SFX.EXPLODE_2)


func _rain_beenhives() -> void:
	var delays: Array[float] = [0.2, 0]
	var i: int = 0
	AudioManager.play_sfx(AudioManifest.SFX.EXPLODE_2)

	for beehive: Beehive in _beehives.get_children():
		var global_pos = beehive.global_position
		var delay: float = delays[0] if i % 2 == 0 else delays[1]
		i += 1
		await Utils.delay(delay)
		beehive.visible = false

		# Set opacity to 0, so that you can tween later
		if _beehives.get_children().size() == i:
			_beehives.modulate.a = 0

		_add_falling_beehive_projectile(global_pos)


func _show_beehives() -> void:
	var _tween: Tween = create_tween()
	_tween.tween_property(_beehives, "modulate:a", 1, 0.5)

	for beehive: Beehive in _beehives.get_children():
		beehive.visible = true


func _on_beehives_summon_started() -> void:
	_rain_beenhives()


func _on_beehives_summon_finished() -> void:
	_show_beehives()


func _on_boss_defeated() -> void:
	_blast_wall()

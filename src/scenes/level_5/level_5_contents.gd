extends Node2D


@onready var _wall_explosion_particles: GPUParticles2D = $WallExplosionParticles
@onready var _brick_wall_layer: TileMapLayer = $BrickWallLayer
@onready var _brick_wall_hitbox: CollisionShape2D = $StaticBody2D/BrickWallHitbox


func _ready() -> void:
	Events.boss_defeated.connect(_on_boss_defeated)


func _start() -> void:
	_wall_explosion_particles.emitting = true
	_brick_wall_layer.visible = false
	_brick_wall_hitbox.set_deferred("disabled", true)


func _on_boss_defeated() -> void:
	_start()

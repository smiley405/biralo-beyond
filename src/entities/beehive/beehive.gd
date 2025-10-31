class_name Beehive
extends Area2D


@export var flip_h: bool = false
@export var is_idle: bool = false
@export var start_frame_index: int = 0
@export var animation_speed_scale: float = 1.0

var type: String = "Beehive"
# Will be set from root level
var vfx_pool: VfxPool
var projectile_pool: ProjectilePool

var _attacking: bool = false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _attack_timer: Timer = $AttackTimer
@onready var _hitbox: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_animated_sprite.play("idle")
	_animated_sprite.flip_h = flip_h
	_animated_sprite.set_frame_and_progress(start_frame_index, true)

	if animation_speed_scale:
		_animated_sprite.speed_scale = animation_speed_scale
	if not is_idle:
		attack()
	_animated_sprite.connect("animation_finished", _on_animated_sprite_finished)
	_animated_sprite.connect("frame_changed", _on_animated_sprite_frame_changed)


func attack() -> void:
	_attack_timer.start()


func _do_attack() -> void:
	if _attacking:
		return
	_attacking = true
	_animated_sprite.play("shoot")
	_reset_animation_speed_scale()


func add_projectile() -> void:
	var projectile = projectile_pool.get_projectile("bee")
	var projectile_speed: float = 40.0
	projectile.flip_h = flip_h

	if projectile and not projectile.visible:
		var start_position: Vector2 = Vector2(_hitbox.global_position.x, _hitbox.global_position.y + 2)
		var vfx_start_position: Vector2 = Vector2(_hitbox.global_position.x + 6, _hitbox.global_position.y + 1)

		if flip_h:
			start_position.x = _hitbox.global_position.x - 2
			vfx_start_position.x = _hitbox.global_position.x - 6

		var shoot_direction: Vector2 = Vector2.LEFT if flip_h else Vector2.RIGHT
		projectile.speed = Vector2(projectile_speed, 0)
		projectile.activate(start_position, shoot_direction)

		add_vfx("beehive_shoot_trails", vfx_start_position)


func add_vfx(vfx_type: String, vfx_position: Vector2) -> void:
	var vfx = vfx_pool.get_vfx(vfx_type)

	if vfx and not vfx.visible:
		vfx.activate()
		vfx.set_flip_h(flip_h)
		vfx.position.x = vfx_position.x
		vfx.position.y = vfx_position.y


func _reset_animation_speed_scale() -> void:
	_animated_sprite.speed_scale = 1.0


func _on_animated_sprite_frame_changed() -> void:
	if _animated_sprite.animation == "shoot" and _animated_sprite.frame == 2:
		add_projectile()


func _on_animated_sprite_finished() -> void:
	_attacking = false
	_animated_sprite.play("idle")


func _on_attack_timer_timeout() -> void:
	_do_attack()


func _on_area_entered(area: Area2D) -> void:
	add_vfx("blast", _hitbox.global_position)
	_attack_timer.stop()
	queue_free()

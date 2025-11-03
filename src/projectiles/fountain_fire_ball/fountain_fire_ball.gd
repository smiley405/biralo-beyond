class_name FountainFireBall
extends BaseProjectile


var gravity: float = 250
var velocity: Vector2 = Vector2.ZERO
var default_vertical_force: float = 160.0


func _ready() -> void:
	super()


func _physics_process(delta: float) -> void:
	if not visible:
		return

	# Apply gravity (acceleration)
	velocity.y += gravity * delta
	# Move the Area2D
	position += velocity * delta
	_animated_sprite.flip_h = flip_h


func kill() -> void:
	super.kill()
	add_vfx()


func add_vfx() -> void:
	var vfx = vfx_pool.get_vfx(VFXManifest.VFX_MAP.FIRE_BALL_IMPACT)

	if vfx and not vfx.visible:
		vfx.activate()
		vfx.position.x = _hitbox.global_position.x
		vfx.position.y = _hitbox.global_position.y
		vfx.set_flip_h(sign(direction.x) == -1)


func launch(horizontal_speed: float = 0.0, vertical_force = default_vertical_force) -> void:
	velocity.y = -vertical_force
	velocity.x = horizontal_speed

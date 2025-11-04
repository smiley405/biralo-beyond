class_name FireBall
extends BaseProjectile


func kill() -> void:
	super.kill()
	add_vfx()


func add_vfx() -> void:
	var vfx: BaseVfx = vfx_pool.get_vfx(VFXManifest.VFX_MAP.FIRE_BALL_IMPACT)

	if vfx and not vfx.visible:
		vfx.activate()
		vfx.position.x = _hitbox.global_position.x
		vfx.position.y = _hitbox.global_position.y
		vfx.set_flip_h(sign(direction.x) == -1)

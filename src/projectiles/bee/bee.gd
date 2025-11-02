class_name Bee
extends BaseProjectile


func kill() -> void:
	super.kill()
	add_vfx()


func add_vfx() -> void:
	var vfx = vfx_pool.get_vfx("fire_ball_impact")

	if vfx and not vfx.visible:
		vfx.activate()
		vfx.position.x = _hitbox.global_position.x
		vfx.position.y = _hitbox.global_position.y
		vfx.set_flip_h(sign(direction.x) == -1)


func activate(start_position: Vector2, shoot_direction: Vector2) -> void:
	super.activate(start_position, shoot_direction)
	AudioManager.play_sfx(AudioManifest.SFX.SHOOT_2)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		kill()
		AudioManager.play_sfx(AudioManifest.SFX.EXPLODE)

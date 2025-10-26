class_name Player
extends Actor


const PlayerState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"RUN": "RUN",
	"FALL": "FALL",
	"ATTACK": "ATTACK",
	"HURT": "HURT",
	"JUMP": "JUMP",
	"SWING": "SWING",
}

var _attack_area_offsets: Array[Vector2] = []
var _loved: bool = false
var _swinging: bool = false
var _swing_speed: Vector2 = Vector2(45, 0)
var _attack_locked: bool = false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _attack_aread_2d: Area2D = $AttackArea2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	type = "player"
	do_idle()
	_animation_player.play("default")

	_animation_player.connect("animation_finished", _on_animation_player_finished)
	_animated_sprite.connect("frame_changed", _on_animated_sprite_frame_changed)

	# Store area2d collisionShape - their initial offsets
	for shape in _attack_aread_2d.get_children():
		if shape is CollisionShape2D:
			_attack_area_offsets.append(Vector2(shape.position.x, shape.position.y))


func _physics_process(delta) -> void:
	moving = false

	if dead:
		return

	if _locked_movement():
		on_lock_movement()
		return

	update_inputs()

	super(delta)

	update_grounded_state()
	update_attacking_state()
	update_falling_state()


func update_velocity(delta: float) -> void:
	super.update_velocity(delta)
	if moving:
		velocity.x = lerp(velocity.x, get_direction() * speed.x, acceleration.x)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction.x)

	if _swinging:
		velocity.x = get_direction() * _swing_speed.x


func update_inputs() -> void:
	if Input.is_action_pressed("move_right"):
		flip_h = false
		moving = true
		if not attacking:
			change_state(PlayerState.RUN)
	elif Input.is_action_pressed("move_left"):
		flip_h = true
		moving = true
		if not attacking:
			change_state(PlayerState.RUN)
	else:
		if grounded and not attacking:
			change_state(PlayerState.IDLE)

	if Input.is_action_just_pressed("jump"):
		on_jump()

	if Input.is_action_just_pressed("attack"):
		on_attack()


func update_grounded_state() -> void:
	if grounded:
		jumping = false
		_swinging = false
		_attack_locked = false


func update_attacking_state() -> void:
	if attacking:
		_attack_locked = true
		reset_velocity()
		zero_gravity()


func update_falling_state() -> void:
	if falling and not attacking:
		change_state(PlayerState.FALL)


func update_animated_sprite() -> void:
	super.update_animated_sprite()
	update_attack_area_position()


func update_attack_area_position() -> void:
	# flip _attack_area_2d with respect to flip_h
	var i = 0
	for shape in _attack_aread_2d.get_children():
		if shape is CollisionShape2D:
			var offset_x = _attack_area_offsets[i].x
			shape.position.x = -offset_x if flip_h else offset_x
			i += 1


func control_camera() -> void:
	if is_on_floor():
		Events.emit_signal("camera_zoom_in")

	if moving:
		Events.emit_signal("camera_zoom_out")


func change_state(new_state: String) -> void:
	super.change_state(new_state)
	match new_state:
		PlayerState.IDLE:
			do_idle()
		PlayerState.RUN:
			do_run()
		PlayerState.JUMP:
			do_jump()
		PlayerState.FALL:
			do_fall()
		PlayerState.ATTACK:
			do_attack()
		PlayerState.SWING:
			do_swing()


func do_idle() -> void:
	moving = false
	reset_velocity_x()
	_animated_sprite.play("idle")


func do_run() -> void:
	if grounded and not falling:
		_animated_sprite.play("run")


func do_jump(force = jump_force) -> void:
	jumping = true
	grounded = false
	gravity = jump_gravity
	velocity.y -= force
	speed = jump_speed

	if not moving and not _swinging:
		_animated_sprite.play("jump")


func do_fall() -> void:
	_animated_sprite.play("fall")


func do_attack() -> void:
	attacking = true
	_animation_player.play("attack_logic")


func do_love() -> void:
	if _loved:
		return
	_loved = true
	GameState.game_won = true

	var love_vfx = vfx_pool.get_vfx("love")
	if love_vfx and not love_vfx.visible:
		love_vfx.activate()
		love_vfx.position.x = _hitbox.global_position.x
		love_vfx.position.y = _hitbox.global_position.y - _hitbox.shape.get_rect().size.y - 4


func do_swing() -> void:
	if _swinging:
		return
	await Utils.delay(0.2)
	reset_attack_state()
	_swinging = true
	do_jump(118.0)


func reset() -> void:
	super.reset()
	_loved = false
	_swinging = false


func kill() -> void:
	super.kill()
	# sound > blast
	visible = false
	add_vfx("blast")
	await Utils.delay(1.0)
	on_kill()


func reset_attack_state() -> void:
	attacking = false
	if jumping:
		gravity = jump_gravity
	else:
		reset_gravity()


func _locked_movement() -> bool:
	return _loved


func _add_run_dusts() -> void:
	if flip_h:
		add_vfx("walk_dusts_1", _hitbox.global_position.x + 2, _hitbox.global_position.y - 1, flip_h)
	else:
		add_vfx("walk_dusts_2", _hitbox.global_position.x - 2, _hitbox.global_position.y - 1, flip_h)


func can_attack() -> bool:
	if dead or _attack_locked:
		return false
	# Prevent attack if character is airborne and not jumping
	if not grounded and not jumping:
		return false
	return true


func on_lock_movement() -> void:
	reset_velocity()
	zero_gravity()
	do_idle()


func on_landed() -> void:
	if dead:
		return
	reset_speed()
	add_vfx("impact_dusts", 0.0, _hitbox.global_position.y - _hitbox.shape.get_rect().size.y + 1)
	# sounds
	# player logics here


func on_jump() -> void:
	if jumping:
		return

	if grounded and not attacking:
		change_state(PlayerState.JUMP)


func on_attack() -> void:
	if not can_attack():
		return
	change_state(PlayerState.ATTACK)


func on_kill() -> void:
	detach()
	SceneManager.reload_scene()


func _on_animation_player_finished(anim_name: String) -> void:
	if anim_name == "attack_logic":
		_animation_player.play("default")
		reset_attack_state()


func _on_animated_sprite_frame_changed() -> void:
	if _animated_sprite.animation == "run":
		if _animated_sprite.frame == 2:
			_add_run_dusts()


func _on_KillTimer_timeout():
	on_kill()


func _on_attack_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("boss") and body.is_weak():
		body.receive_damage(1, self)
	if body.is_in_group("enemies"):
		body.receive_damage(1, self)


func _on_swing_timer_timeout() -> void:
	_swinging = false


func _on_attack_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("torch"):
		change_state(PlayerState.SWING)

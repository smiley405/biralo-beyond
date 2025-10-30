class_name Frog
extends Actor


const FrogState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"TIRED": "TIRED",
	"ATTACK": "ATTACK",
	"FLY": "FLY",
	"JUMP": "JUMP",
}

const fsm: Array[String] = [
	FrogState.IDLE,
	FrogState.ATTACK,
	FrogState.IDLE,
	# Repeats [JUMP-TIRED] until it hits wall
	FrogState.JUMP,
	# After it hits wall
	FrogState.IDLE,
	FrogState.ATTACK,
	FrogState.IDLE,
	# Flies up and to the side till it hits wall then falls down
	FrogState.FLY,
]

var _fsm_index: int = -1
var _flying_up: bool = false
var _flying_side: bool = false

@onready var _fsm_timer: Timer = $FSMTimer
@onready var _tired_timer: Timer = $TiredTimer
@onready var _take_off_fly_timer: Timer = $TakeOffFlyTimer
@onready var _projectile_attack_timer: Timer = $ProjectileAttackTimer
@onready var _left_ray_cast: RayCast2D = $LeftRayCast2D
@onready var _right_ray_cast: RayCast2D = $RightRayCast2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	type = "frog"
	health = 10
	speed.y = 30.0
	jump_force = 130.0
	_animation_player.play("default")
	update_fsm()


func _physics_process(delta) -> void:
	if dead:
		return
	super(delta)
	update_grounded_state()


func update_grounded_state() -> void:
	if not grounded:
		return

	if jumping:
		jumping = false
		change_state(FrogState.TIRED)

	if _left_ray_cast.is_colliding():
		flip_h = false
	if _right_ray_cast.is_colliding():
		flip_h = true

	if _flying_side:
		_flying_side = false
		update_fsm()

	reset_velocity()
	reset_gravity()


func update_velocity(delta: float) -> void:
	super.update_velocity(delta)

	if jumping or _flying_side:
		velocity.x = lerp(velocity.x, get_direction() * speed.x, acceleration.x)

	if _flying_up:
		velocity.x = 0

	if _flying_side:
		if is_facing_left_colliding() or is_facing_right_colliding():
			reset_gravity()
			velocity.y = speed.y


func change_state(new_state: String) -> void:
	super.change_state(new_state)
	attacking = false
	match new_state:
		FrogState.IDLE:
			do_idle()
		FrogState.TIRED:
			do_tired()
		FrogState.ATTACK:
			do_attack()
		FrogState.JUMP:
			do_jump()
		FrogState.FLY:
			do_fly()


func update_fsm() -> void:
	_fsm_timer.stop()
	_projectile_attack_timer.stop()
	_flying_up = false
	_flying_side = false
	_fsm_index += 1

	if _fsm_index > fsm.size() - 1:
		_fsm_index = 0

	var next_state: String = fsm[_fsm_index]
	change_state(next_state)


func add_projectile(is_side: bool = true, is_down: bool = false) -> void:
	var projectile = projectile_pool.get_projectile("fire_ball")
	var projectile_speed: float = 60.0

	if projectile and not projectile.visible:
		var start_position: Vector2 = Vector2(_hitbox.global_position.x, _hitbox.global_position.y)
		var shoot_direction: Vector2 = Vector2.LEFT if flip_h else Vector2.RIGHT
		if is_down:
			shoot_direction = Vector2.DOWN
			projectile.speed = Vector2(0, projectile_speed)
		else:
			projectile.speed = Vector2(projectile_speed, 0)

		projectile.activate(start_position, shoot_direction)


func do_idle() -> void:
	_animated_sprite.play("idle")
	_fsm_timer.start(1.0)


func do_tired() -> void:
	if prev_state == FrogState.JUMP and not is_on_wall():
		_animated_sprite.play("tired")
		_tired_timer.start()
	else:
		do_idle()


func do_attack() -> void:
	attacking = true
	_fsm_index += 1
	_animated_sprite.play("attack")
	add_projectile()
	_fsm_timer.start(0.5)


func do_fly() -> void:
	_flying_up = true
	do_jump('fly', 0, speed.y)
	do_fly_attack()
	_take_off_fly_timer.start()


func do_fly_attack() -> void:
	_projectile_attack_timer.start(0.5)


func do_jump(anim_name: String = "jump", grav: float = jump_gravity, force: float = jump_force) -> void:
	jumping = true
	grounded = false
	gravity = grav
	velocity.y -= force
	_animated_sprite.play(anim_name)


func reset() -> void:
	super.reset()
	_flying_side = false
	_flying_up = false
	_fsm_index = -1


func kill() -> void:
	super.kill()
	kill_timers()
	# sound > blast
	visible = false
	add_vfx("blast")
	await Utils.delay(1)
	Events.boss_defeated.emit()


func kill_timers() -> void:
	_fsm_timer.stop()
	_projectile_attack_timer.stop()
	_take_off_fly_timer.stop()
	_tired_timer.stop()


func is_weak() -> bool:
	return visible and not attacking and gravity


func is_smash() -> bool:
	return visible and jumping and falling


func is_facing_right_colliding() -> bool:
	return not flip_h and _right_ray_cast.is_colliding() and is_on_wall()


func is_facing_left_colliding() -> bool:
	return flip_h and _left_ray_cast.is_colliding() and is_on_wall()


func on_landed() -> void:
	if dead:
		return
	add_vfx("impact_dusts", Vector2(0.0, _hitbox.global_position.y - _hitbox.shape.get_rect().size.y/8))
	# sounds
	# player logics here


func on_damage() -> void:
	if _animation_player.is_playing():
		return
	_animation_player.play("hurt")

	var frame_index: int = health
	Events.emit_signal("update_boss_health_bar", frame_index)


func _on_fsm_timer_timeout() -> void:
	update_fsm()


func _on_projectile_attack_timer_timeout() -> void:
	_animated_sprite.play("poop")
	add_projectile(false, true)


func _on_smash_area_2d_body_entered(body: Node2D) -> void:
	if not is_smash():
		return

	if body.is_in_group("player"):
		var player: Player = body as Player
		player.receive_damage(1, self)
		Events.camera_shake.emit()


func _on_tired_timer_timeout() -> void:
	change_state(FrogState.JUMP)
	_fsm_timer.start(1.0)


func _on_take_off_fly_timer_timeout() -> void:
	_flying_side = true
	_flying_up = false
	zero_gravity()
	reset_velocity()

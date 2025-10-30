class_name Frog
extends Actor


const FrogState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"TIRED": "TIRED",
	"SHOOT_ON_GROUND": "SHOOT_ON_GROUND",
	"FLY_UP_SHOOT": "FLY_UP_SHOOT",
	"FLY_DOWN": "FLY_DOWN",
	"FLY_RIGHT_SHOOT": "FLY_RIGHT_SHOOT",
	"JUMP": "JUMP",
}

## Finite State Machine list
const fsm: Array[String] = [
	FrogState.IDLE,
	FrogState.IDLE,
	FrogState.SHOOT_ON_GROUND,
	FrogState.IDLE,
	## Repeats [JUMP-TIRED] until it hits wall
	FrogState.JUMP,
	## After it hits wall
	FrogState.IDLE,
	FrogState.SHOOT_ON_GROUND,
	FrogState.IDLE,
	## Flies up and to the side till it hits wall than falls down
	FrogState.FLY_UP_SHOOT,
	FrogState.FLY_RIGHT_SHOOT,
	FrogState.FLY_DOWN,
]

var _fsm_index: int = -1
var _flying_up: bool = false
var _flying_down: bool = false
var _flying_right: bool = false

@onready var _fsm_timer: Timer = $FSMTimer
@onready var _tired_state_timer: Timer = $TiredStateTimer
@onready var _falling_projectile_trigger_timer: Timer = $FallingProjectileTriggerTimer
@onready var _left_ray_cast: RayCast2D = $LeftRayCast2D
@onready var _right_ray_cast: RayCast2D = $RightRayCast2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	type = "frog"
	health = 10
	speed.y = 90.0
	jump_force = 130.0
	_animation_player.play("default")
	advance_fsm()


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

	if is_facing_left_colliding():
		flip_h = false
	if is_facing_right_colliding():
		flip_h = true

	reset_velocity()
	reset_gravity()


func update_velocity(delta: float) -> void:
	super.update_velocity(delta)

	if jumping or _flying_right:
		velocity.x = lerp(velocity.x, get_direction() * speed.x, acceleration.x)

	if _flying_up:
		grounded = false
		zero_gravity()
		velocity.x = 0
		velocity.y = lerp(velocity.x, -1 * speed.y, acceleration.x)

	if _flying_down:
		velocity.y = speed.y/2
		if grounded:
			advance_fsm()

	if _flying_right:
		grounded = false
		velocity.y = 0
		if is_facing_right_colliding():
			flip_h = true
			advance_fsm()


func change_state(new_state: String) -> void:
	super.change_state(new_state)
	reset_flying_states()
	attacking = false
	match new_state:
		FrogState.IDLE:
			do_idle()
		FrogState.TIRED:
			do_tired()
		FrogState.SHOOT_ON_GROUND:
			do_shoot_on_ground()
		FrogState.JUMP:
			do_jump()
		FrogState.FLY_UP_SHOOT:
			do_fly_up_shoot()
		FrogState.FLY_DOWN:
			do_fly_down()
		FrogState.FLY_RIGHT_SHOOT:
			do_fly_right_shoot()


func advance_fsm() -> void:
	_fsm_timer.stop()
	_falling_projectile_trigger_timer.stop()
	_fsm_index += 1

	if _fsm_index > fsm.size() - 1:
		_fsm_index = 0

	var next_state: String = fsm[_fsm_index]
	change_state(next_state)


func add_ground_projectile() -> void:
	var projectile = projectile_pool.get_projectile("fire_ball")
	var projectile_speed: float = 60.0

	if projectile and not projectile.visible:
		var start_position: Vector2 = Vector2(_hitbox.global_position.x, _hitbox.global_position.y)
		var shoot_direction: Vector2 = Vector2.LEFT if flip_h else Vector2.RIGHT
		projectile.speed = Vector2(projectile_speed, 0)
		projectile.activate(start_position, shoot_direction)


func add_falling_projectile() -> void:
	var projectile = projectile_pool.get_projectile("fire_ball")
	var projectile_speed: float = 60.0

	if projectile and not projectile.visible:
		var start_position: Vector2 = Vector2(_hitbox.global_position.x, _hitbox.global_position.y)
		var shoot_direction: Vector2 = Vector2.LEFT if flip_h else Vector2.RIGHT
		shoot_direction = Vector2.DOWN
		projectile.speed = Vector2(0, projectile_speed)
		projectile.activate(start_position, shoot_direction)


func do_idle() -> void:
	_animated_sprite.play("idle")
	_fsm_timer.start(1.0)


func do_tired() -> void:
	if prev_state == FrogState.JUMP:
		if is_on_wall() and grounded:
			do_idle()
		else:
			_animated_sprite.play("tired")
			_tired_state_timer.start()


func do_shoot_on_ground() -> void:
	attacking = true
	_animated_sprite.play("attack")
	add_ground_projectile()
	_fsm_timer.start(0.5)


func do_shoot_on_fly() -> void:
	attacking = true
	_animated_sprite.play("poop")
	_falling_projectile_trigger_timer.start(0.4)


func do_fly_right_shoot() -> void:
	do_shoot_on_fly()
	_flying_right = true
	_animated_sprite.play("fly")


func do_fly_up_shoot() -> void:
	do_shoot_on_fly()
	_flying_up = true
	_animated_sprite.play("fly")
	_fsm_timer.start(1.5)


func do_fly_down() -> void:
	_flying_down = true
	_animated_sprite.play("fly")
	reset_gravity()


func do_jump() -> void:
	jumping = true
	grounded = false
	gravity = jump_gravity
	velocity.y -= jump_force
	_animated_sprite.play("jump")


func reset() -> void:
	super.reset()
	reset_flying_states()
	_fsm_index = -1


func reset_flying_states() -> void:
	_flying_right = false
	_flying_up = false
	_flying_down = false


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
	_falling_projectile_trigger_timer.stop()
	_tired_state_timer.stop()


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
	advance_fsm()


func _on_smash_area_2d_body_entered(body: Node2D) -> void:
	if not is_smash():
		return

	if body.is_in_group("player"):
		var player: Player = body as Player
		player.receive_damage(1, self)
		Events.camera_shake.emit()


func _on_tired_state_timer_timeout() -> void:
	change_state(FrogState.JUMP)
	_fsm_timer.start(1.0)


func _on_falling_projectile_trigger_timer_timeout() -> void:
	do_shoot_on_fly()
	add_falling_projectile()

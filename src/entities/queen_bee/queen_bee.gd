class_name QueenBee
extends Actor


const QueenBeeState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"FLYING_KISS": "FLYING_KISS",
	"FLY_UP": "FLY_UP",
	"FLY_DOWN": "FLY_DOWN",
	"FLY_LEFT": "FLY_LEFT",
	"FLY_LEFT_TO_END": "FLY_LEFT_TO_END",
	"FLY_RIGHT": "FLY_RIGHT",
	"FLY_RIGHT_TO_END": "FLY_RIGHT_TO_END",
	"BEEHIVES_SUMMONED": "BEEHIVES_SUMMONED",
	"SHOOT_BEE": "SHOOT_BEE",
}

## Finite State Machine list
const fsm: Array[String] = [
	QueenBeeState.IDLE,
	QueenBeeState.IDLE,
	QueenBeeState.FLYING_KISS,
	QueenBeeState.IDLE,
	QueenBeeState.IDLE,

	QueenBeeState.FLY_LEFT,
	QueenBeeState.IDLE,

	QueenBeeState.FLY_UP,
	QueenBeeState.IDLE,
	QueenBeeState.BEEHIVES_SUMMONED,
	QueenBeeState.IDLE,

	QueenBeeState.FLY_LEFT_TO_END,
	QueenBeeState.IDLE,
	QueenBeeState.FLY_DOWN,
	QueenBeeState.IDLE,

	QueenBeeState.SHOOT_BEE,
	QueenBeeState.IDLE,
	QueenBeeState.SHOOT_BEE,
	QueenBeeState.IDLE,

	QueenBeeState.FLY_RIGHT,
	QueenBeeState.IDLE,

	QueenBeeState.FLY_UP,
	QueenBeeState.IDLE,
	QueenBeeState.BEEHIVES_SUMMONED,
	QueenBeeState.IDLE,

	QueenBeeState.FLY_RIGHT_TO_END,
	QueenBeeState.IDLE,
	QueenBeeState.FLY_DOWN,
]

var _fsm_index: int = -1
var _flying_up: bool = false
var _flying_down: bool = false
var _flying_left: bool = false
var _flying_right: bool = false

@onready var _fsm_timer: Timer = $FSMTimer
@onready var _left_ray_cast: RayCast2D = $LeftRayCast2D
@onready var _right_ray_cast: RayCast2D = $RightRayCast2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	type = "queen_bee"
	health = 10
	speed = Vector2(40.0, 95.0)
	acceleration = Vector2(0.3, 0.3)
	jump_force = 130.0
	_animation_player.play("default")
	advance_fsm()
	_animated_sprite.connect("animation_finished", _on_animated_sprite_complete)
	_animated_sprite.connect("frame_changed", _on_animated_sprite_frame_changed)


func _physics_process(delta) -> void:
	if dead:
		return
	super(delta)
	update_grounded_state()


func update_grounded_state() -> void:
	if not grounded:
		return
	if _left_ray_cast.is_colliding():
		flip_h = false
	if _right_ray_cast.is_colliding():
		flip_h = true

	reset_velocity()
	reset_gravity()


func update_velocity(delta: float) -> void:
	super.update_velocity(delta)

	if _flying_left or _flying_right:
		grounded = false
		zero_gravity()
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

	if _flying_left and current_state == QueenBeeState.FLY_LEFT_TO_END:
		if is_facing_left_colliding():
			flip_h = false
			advance_fsm()

	if _flying_right and current_state == QueenBeeState.FLY_RIGHT_TO_END:
		if is_facing_right_colliding():
			flip_h = true
			advance_fsm()


func change_state(new_state: String) -> void:
	super.change_state(new_state)
	reset_flying_states()
	attacking = false

	match new_state:
		QueenBeeState.IDLE:
			do_idle()
		QueenBeeState.FLYING_KISS:
			do_flying_kiss()
		QueenBeeState.FLY_LEFT:
			do_fly_left()
		QueenBeeState.FLY_LEFT_TO_END:
			do_fly_left(false)
		QueenBeeState.FLY_RIGHT:
			do_fly_right()
		QueenBeeState.FLY_RIGHT_TO_END:
			do_fly_right(false)
		QueenBeeState.FLY_UP:
			do_fly_up()
		QueenBeeState.FLY_DOWN:
			do_fly_down()
		QueenBeeState.SHOOT_BEE:
			do_shoot_bee()
		QueenBeeState.BEEHIVES_SUMMONED:
			do_summon_beehives()


func advance_fsm() -> void:
	_fsm_timer.stop()
	_fsm_index += 1

	if _fsm_index > fsm.size() - 1:
		_fsm_index = 0

	var next_state: String = fsm[_fsm_index]
	change_state(next_state)


func add_queens_love_projectile() -> void:
	var directions: Array[Vector2] = [Vector2(1, -1), Vector2(1, 1), Vector2(1, 1)]
	var speeds: Array[Vector2] = [Vector2(40, 12), Vector2(40, 3), Vector2(40, 10)]
	var i: int = 0

	for dir in directions:
		var projectile = projectile_pool.get_projectile("queens_love")
		if projectile and not projectile.visible:
			var start_position: Vector2 = Vector2(_hitbox.global_position.x, _hitbox.global_position.y - 6)
			var shoot_direction: Vector2 = dir
			shoot_direction.x = get_direction()
			projectile.speed =  speeds[i]
			projectile.activate(start_position, shoot_direction)
		i += 1


func add_bee_projectile() -> void:
	var shoot_directions: Array[Vector2] = [Vector2(1, -1), Vector2(1, 0)]
	var shoot_speeds: Array[Vector2] = [Vector2(40, 5), Vector2(40, 0)]
	var projectile = projectile_pool.get_projectile("bee")
	projectile.flip_h = flip_h

	if projectile and not projectile.visible:
		var start_position: Vector2 = Vector2(_hitbox.global_position.x, _hitbox.global_position.y + 2)
		var vfx_start_position: Vector2 = Vector2(_hitbox.global_position.x + 6, _hitbox.global_position.y + 1)
		if flip_h:
			start_position.x = _hitbox.global_position.x - 2
			vfx_start_position.x = _hitbox.global_position.x - 6
		var shoot_direction = shoot_directions.pick_random()
		shoot_direction.x = get_direction()
		projectile.speed = shoot_speeds.pick_random()
		projectile.activate(start_position, shoot_direction)
		add_vfx("beehive_shoot_trails", vfx_start_position, flip_h)


func do_idle() -> void:
	zero_gravity()
	reset_velocity()
	_animated_sprite.play("idle")
	_fsm_timer.start(1.0)


func do_fly_left(is_advance_fsm: bool = true) -> void:
	_flying_left = true
	_animated_sprite.play("idle")
	if is_advance_fsm:
		_fsm_timer.start(0.8)


func do_fly_right(is_advance_fsm: bool = true) -> void:
	_flying_right = true
	_animated_sprite.play("idle")
	if is_advance_fsm:
		_fsm_timer.start(0.8)


func do_fly_up() -> void:
	_flying_up = true
	_animated_sprite.play("fly")
	_fsm_timer.start(1.2)


func do_fly_down() -> void:
	_flying_down = true
	_animated_sprite.play("idle")
	reset_gravity()


func do_flying_kiss() -> void:
	attacking = true
	_fsm_index += 1
	_animated_sprite.play("flying_kiss")


func do_summon_beehives() -> void:
	_flying_up = false
	zero_gravity()
	reset_velocity()
	_animated_sprite.play("beehives_summoned")
	Events.emit_signal("beehives_summon_started")


func do_shoot_bee() -> void:
	_animated_sprite.play("shoot_bee")
	add_bee_projectile()


func reset() -> void:
	super.reset()
	reset_flying_states()
	_fsm_index = -1


func reset_flying_states() -> void:
	_flying_left = false
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
	#add_vfx("impact_dusts", 0.0, _hitbox.global_position.y - _hitbox.shape.get_rect().size.y/8)
	# sounds
	# player logics here


func on_damage() -> void:
	if _animation_player.is_playing():
		return
	_animation_player.play("hurt")
	var frame_index: int = health
	Events.emit_signal("update_boss_health_bar", frame_index)


func _on_animated_sprite_complete() -> void:
	if _animated_sprite.animation == "beehives_summoned":
		Events.emit_signal("beehives_summon_finished")
		Events.camera_shake.emit()
		advance_fsm()
	if _animated_sprite.animation == "shoot_bee":
		advance_fsm()
	if _animated_sprite.animation == "flying_kiss":
		advance_fsm()


func _on_animated_sprite_frame_changed() -> void:
	if _animated_sprite.animation == "beehives_summoned":
		if _animated_sprite.frame == 3:
			Events.camera_shake.emit()
	if _animated_sprite.animation == "flying_kiss":
		if _animated_sprite.frame == 3:
			add_queens_love_projectile()


func _on_fsm_timer_timeout() -> void:
	advance_fsm()

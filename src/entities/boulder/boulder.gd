class_name Boulder
extends Actor


const BoulderState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"ROLL": "ROLL",
	"STOP": "STOP",
}

var _is_ready_for_stop: bool = false

@onready var _left_ray_cast: RayCast2D = $LeftRayCast2D
@onready var _right_ray_cast: RayCast2D = $RightRayCast2D
@onready var _area_2d: Area2D = $Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	type = "boulder"
	default_speed = Vector2(25, 0)
	speed = default_speed
	change_state(BoulderState.STOP)
	zero_gravity()


func _physics_process(delta) -> void:
	super(delta)
	update_movement()


func update_movement() -> void:
	if falling:
		return
	if moving:
		velocity.x = lerp(velocity.x, get_direction() * speed.x, acceleration.x)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction.x)


func change_state(new_state: String) -> void:
	super.change_state(new_state)
	match new_state:
		BoulderState.IDLE:
			do_idle()
		BoulderState.ROLL:
			do_roll()
		BoulderState.STOP:
			do_stop()


func do_stop() -> void:
	_animated_sprite.stop()
	moving = false


func do_idle() -> void:
	do_stop()
	change_state(BoulderState.ROLL)


func do_roll() -> void:
	moving = true
	_animated_sprite.play("roll")


func switch_off() -> void:
	reset_velocity()
	zero_gravity()
	_area_2d.set_deferred("monitoring", false)
	change_state(BoulderState.STOP)


## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(from: Node2D, trigger: Node2D) -> void:
	if trigger.is_in_group("kill_tool"):
		switch_off()
		queue_free()
	if trigger.is_in_group("stop_tool") and not _is_ready_for_stop:
		_is_ready_for_stop = true
		switch_off()
	if from.is_in_group("player") or from.is_in_group("alice"):
		reset_gravity()
		change_state(BoulderState.ROLL)


func on_landed() -> void:
	if current_state != BoulderState.IDLE:
		change_state(BoulderState.IDLE)
		if _left_ray_cast.is_colliding():
			flip_h = false
		if _right_ray_cast.is_colliding():
			flip_h = true
		if _is_ready_for_stop:
			change_state(BoulderState.STOP)

	Events.camera_shake.emit()
	reset_speed()
	add_vfx("impact_dusts", Vector2(0.0, _hitbox.global_position.y - _hitbox.shape.get_rect().size.y/8))


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player: Player = body as Player
		player.receive_damage(1, self)

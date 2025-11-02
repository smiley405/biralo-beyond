class_name Alice
extends Area2D


@export var flip_h: bool = false
@export var run_duration: float = 3.0
@export var jump_duration: float = 0.3

const AliceState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"WAVE": "WAVE",
	"JUMP": "JUMP",
	"RUN": "RUN",
	"FALL": "FALL",
	"KILL": "KILL",
	"LOVE_CAT": "LOVE_CAT",
	"CLIFF_HANG_START": "CLIFF_HANG_START",
	"CLIFF_HANG_END": "CLIFF_HANG_END",
}

## Finite State Machine list
var fsm: Array[String] = [
	AliceState.WAVE,
]
var type: String = "Alice"
var moving: bool = false
var jumping: bool = false
var falling: bool = false
var default_speed: Vector2 = Vector2(30.0, 40.0)
var jump_force: float = 55.0
var speed: Vector2 = default_speed
var direction: Vector2 = Vector2.RIGHT
var current_state: String = "" # Dictionary enum

var _loved_cat: bool = false
var _fsm_index: int = -1

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hit_box: CollisionShape2D = $CollisionShape2D
@onready var _run_timer: Timer = $RunTimer
@onready var _jump_timer: Timer = $JumpTimer
@onready var _fsm_timer: Timer = $FSMTimer


func _ready() -> void:
	advance_fsm()
	_animated_sprite.connect("animation_finished", _on_animated_sprite_complete)


func _physics_process(delta: float) -> void:
	if moving or jumping or falling:
		position += direction * speed * delta

	_animated_sprite.flip_h = flip_h


func change_state(new_state: String) -> void:
	current_state = new_state

	match new_state:
		AliceState.IDLE:
			do_idle()
		AliceState.WAVE:
			do_wave()
		AliceState.RUN:
			do_run()
		AliceState.JUMP:
			do_jump()
		AliceState.LOVE_CAT:
			do_love_cat()
		AliceState.FALL:
			do_fall()
		AliceState.KILL:
			do_kill()
		AliceState.CLIFF_HANG_START:
			do_cliff_hang_start()
		AliceState.CLIFF_HANG_END:
			do_cliff_hang_end()


func advance_fsm() -> void:
	_fsm_timer.stop()
	_fsm_index += 1

	if _fsm_index > fsm.size() - 1:
		_fsm_index = 0

	var next_state: String = fsm[_fsm_index]
	change_state(next_state)


func do_run() -> void:
	_animated_sprite.play("run")
	moving = true
	speed = default_speed
	speed.y = 0
	direction = Vector2.LEFT if flip_h else Vector2.RIGHT
	_run_timer.start(run_duration)


func do_wave() -> void:
	_animated_sprite.play("wave")


func do_idle() -> void:
	_animated_sprite.play("idle")
	_fsm_timer.start(1.0)


func do_love_cat() -> void:
	speed = Vector2.ZERO
	_animated_sprite.play("love")
	AudioManager.play_sfx(AudioManifest.SFX.POWER_UP_2)


func do_fall() -> void:
	_animated_sprite.play("fall")
	var _tween: Tween = create_tween()
	var target_y: float = position.y + 96.0
	_tween.tween_property(self, "position:y", target_y, 1.0).set_delay(0.2)


func do_jump() -> void:
	jumping = true
	speed.x = 0
	speed.y = jump_force
	direction = Vector2.UP
	_animated_sprite.play("jump")
	_jump_timer.start(jump_duration)


func do_kill() -> void:
	queue_free()


func climb_that_cliff() -> void:
	reset_fsm()
	fsm = [
		AliceState.IDLE,
		AliceState.IDLE,
		AliceState.JUMP,
		AliceState.CLIFF_HANG_START,
		AliceState.CLIFF_HANG_END,
		AliceState.RUN,
		AliceState.KILL,
	]
	advance_fsm()


func do_cliff_hang_start() -> void:
	_animated_sprite.play("cliff_hang_start")
	_fsm_timer.start(2.0)


func do_cliff_hang_end() -> void:
	_animated_sprite.play("cliff_hang_end")
	position.y = position.y - _hit_box.shape.get_rect().size.y + 1


func run_and_vanish() -> void:
	reset_fsm()
	fsm = [
		AliceState.RUN,
		AliceState.KILL,
	]
	advance_fsm()


func reset_fsm() -> void:
	fsm.clear()
	_fsm_index = -1
	_fsm_timer.stop()


## This function is called internally by the tools/trigger [br]
## [param entity] - is a node which trrigered it. i.e player, enemies [br]
## [param trigger] - is the node that's been triggered
func triggered_by(from: Node2D, trigger: Node2D) -> void:
	if from.is_in_group("player"):
		change_state(AliceState.FALL)


func _on_animated_sprite_complete() -> void:
	if _animated_sprite.animation == "cliff_hang_end":
		advance_fsm()


func _on_body_entered(body: Node2D) -> void:
	if _loved_cat or not body.is_in_group("player"):
		return

	if current_state == AliceState.WAVE:
		var player: Player = body as Player
		player.do_love()

		_loved_cat = true
		change_state(AliceState.LOVE_CAT)
		GameState.game_won = true
		Events.emit_signal("game_finished")


func _on_run_timer_timeout() -> void:
	moving = false


func _on_jump_timer_timeout() -> void:
	jumping = false
	advance_fsm()


func _on_fsm_timer_timeout() -> void:
	advance_fsm()

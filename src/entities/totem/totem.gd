class_name Totem
extends Actor


const TotemState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"ATTACK": "ATTACK",
}

@export var delay_attack_time: float = 1.0
@onready var _switch_attack_timer: Timer = $SwitchAttackTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	type = "totem"
	change_state(TotemState.IDLE)
	_animated_sprite.connect("animation_finished", _on_animation_sprite_finished)


func change_state(new_state: String) -> void:
	super.change_state(new_state)
	match new_state:
		TotemState.IDLE:
			do_idle()
		TotemState.ATTACK:
			do_attack()


func add_projectile() -> void:
	var projectile = projectile_pool.get_projectile("fire_ball")

	if projectile and not projectile.visible:
		var start_position: Vector2 = Vector2(_hitbox.global_position.x, _hitbox.global_position.y + 5)
		var shoot_direction: Vector2 = Vector2.LEFT if flip_h else Vector2.RIGHT
		projectile.speed = Vector2(40, 0)
		projectile.activate(start_position, shoot_direction)
		AudioManager.play_sfx(AudioManifest.SFX.SHOOT)


func do_idle() -> void:
	_animated_sprite.play("idle")
	_switch_attack_timer.start(delay_attack_time)


func do_attack() -> void:
	attacking = true
	_animated_sprite.play("attack")


func kill() -> void:
	super.kill()
	# sound > blast
	add_vfx("blast")
	_switch_attack_timer.stop()
	detach()
	AudioManager.play_sfx(AudioManifest.SFX.EXPLODE)


func reset_attack_state() -> void:
	attacking = false


func _on_animation_sprite_finished() -> void:
	var anim_name: String = _animated_sprite.animation

	if anim_name == "attack":
		reset_attack_state()
		change_state(TotemState.IDLE)
		add_projectile()


func _on_switch_attack_timer_timeout() -> void:
	change_state(TotemState.ATTACK)

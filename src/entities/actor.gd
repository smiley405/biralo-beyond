class_name Actor
extends CharacterBody2D


@export var flip_h: bool = false:
	set = set_flip_h,
	get = get_flip_h

var health: int = 1
var default_gravity: float = ProjectSettings.get("physics/2d/default_gravity")
var default_speed: Vector2 = Vector2(45, 0)
var gravity: float = default_gravity
var jump_gravity: float = 400
var jump_speed: Vector2 = Vector2(35, 0)
var speed: Vector2 = default_speed
var friction: Vector2 = Vector2(0.3, 0)
var acceleration: Vector2 = Vector2(0.3, 0)
var jump_force: float = 120.0
var dead: bool = false
var moving: bool = false
var grounded: bool = false
var falling: bool = false
var jumping: bool = false
var attacking: bool = false
var type: String = "actor"

# Use a Dictionary as a String Enum
# Because it is Debug-Friendly
#const Action: Dictionary[String, String] = {
#    "RUN": "RUN",
#    "IDLE": "IDLE",
#    "JUMP": "JUMP"
#}
var current_state: String = "" # Dictionary enum
var prev_state: String = current_state
# Will be set from root level
var vfx_pool: VfxPool
var projectile_pool: ProjectilePool

var alpha: float = 1.0:
	set = set_alpha,
	get = get_alpha

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hitbox: CollisionShape2D = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("vfx_targets")
	add_to_group("projectile_targets")
	call_deferred("_init_after_ready")


## Safe to access all children and start logic
func _init_after_ready() -> void:
	pass


func _physics_process(delta) -> void:
	update_animated_sprite()
	update_velocity(delta)


func update_velocity(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()

	if !grounded and velocity.y > 0:
		falling = true

	if grounded and falling:
		on_landed()
		falling = false

	grounded = is_on_floor()


func update_animated_sprite() -> void:
	if _animated_sprite:
		_animated_sprite.flip_h = flip_h


func change_state(new_state: String) -> void:
	prev_state = current_state
	current_state = new_state


func add_vfx(vfx_data: Dictionary, pos: Vector2 = Vector2(0.0, 0.0), is_flip_h: bool = false) -> void:
	var vfx = vfx_pool.get_vfx(vfx_data)

	if vfx and not vfx.visible:
		vfx.activate()
		vfx.set_flip_h(is_flip_h)
		vfx.position.x = pos.x if pos.x else _hitbox.global_position.x
		vfx.position.y = pos.y if pos.y else _hitbox.global_position.y


func receive_damage(amount: int, from: Node2D) -> void:
	if dead:
		return

	health -= amount
	on_damage()

	if health <= 0:
		health = 0
		kill()


func kill() -> void:
	dead = true
	_hitbox.set_deferred("disabled", true)


func reset() -> void:
	health = 1
	flip_h = false
	dead = false
	moving = false
	grounded = false
	jumping = false
	falling = false
	attacking = false
	reset_velocity()
	reset_gravity()
	reset_speed()


func detach() -> void:
	reset()
	queue_free()


func reset_speed() -> void:
	speed = default_speed


func reset_velocity() -> void:
	velocity = Vector2.ZERO


func reset_velocity_x() -> void:
	velocity.x = 0


func reset_velocity_y() -> void:
	velocity.y = 0


func zero_gravity() -> void:
	gravity = 0


func reset_gravity() -> void:
	gravity = default_gravity


func set_alpha(value: float) -> void:
	alpha = value
	modulate.a = value


func get_alpha() -> float:
	return alpha


func set_flip_h(value: bool) -> void:
	flip_h = value


func get_flip_h() -> bool:
	return flip_h


func get_direction() -> int:
	return -1 if flip_h else 1


func on_damage() -> void:
	pass


func on_landed() -> void:
	pass

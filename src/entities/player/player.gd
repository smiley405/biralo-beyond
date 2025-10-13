class_name Player
extends Actor


const PlayerState: Dictionary[String, String] = {
	"IDLE": "IDLE",
	"RUN": "RUN",
	"FALL": "FALL",
	"ATTACT": "ATTACK",
	"HURT": "HURT",
	"JUMP": "JUMP",
}

var _jump_attacked: bool = false
var _attack_area_offsets: Array[Vector2] = []
var _loved: bool = false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _attack_aread_2d: Area2D = $AttackArea2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	type = "player"
	do_idle()
	_animation_player.play("default")
	
	_animation_player.connect("animation_finished", _on_animation_finished)
	
	# Store area2d collisionShape - their initial offsets
	for shape in _attack_aread_2d.get_children():
		if shape is CollisionShape2D:
			_attack_area_offsets.append(Vector2(shape.position.x, shape.position.y))


func _physics_process(delta) -> void:
	super(delta)
	
	if _locked_movement():
		reset_velocity()
		zero_gravity()
		do_idle()
		return
	
	moving = false
	
	if Input.is_action_pressed("move_right"):
		flip_h = false
		moving = true
	elif Input.is_action_pressed("move_left"):
		flip_h = true
		moving = true
	
	if moving:
		velocity.x = lerp(velocity.x, get_direction() * speed.x, acceleration.x)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction.x)
	
	if grounded:
		jumping = false
		_jump_attacked = false
	
	update_inputs()
	
	if falling and not attacking:
		change_state("FALL")
	
	if attacking:
		reset_velocity()
		zero_gravity()
	
	#control_camera()


func update_inputs() -> void:
	if Input.is_action_pressed("move_right"):
		if not attacking:
			change_state("RUN")
	elif Input.is_action_pressed("move_left"):
		if not attacking:
			change_state("RUN")
	else:
		if grounded and not attacking:
			change_state("IDLE")
			
	if Input.is_action_just_pressed("jump"):
		on_jump()
	
	if Input.is_action_just_pressed("attack"):
		on_attack()


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


func change_state(new_state) -> void:
	current_state = new_state
	match new_state:
		"IDLE":
			do_idle()
		"RUN":
			do_run()
		"JUMP":
			do_jump()
		"FALL":
			do_fall()
		"ATTACK":
			do_attack()


func add_power() -> void:
	# extract from pool
	pass


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
	
	if not moving:
		_animated_sprite.play("jump")


func do_fall() -> void:
	_animated_sprite.play("fall")


func do_attack() -> void:
	attacking = true
	
	if jumping and not _jump_attacked:
		_jump_attacked = true
		
	# add_power()
	_animation_player.play("attack_logic")


func do_love() -> void:
	if _loved:
		return
	_loved = true
	GameState.game_won = true
	
	var love_vfx = vfx_pool.get_vfx("love")
	if love_vfx and not love_vfx.visible:
		love_vfx.play()
		love_vfx.position.x = _hitbox.global_position.x
		love_vfx.position.y = _hitbox.global_position.y - _hitbox.shape.get_rect().size.y - 4


func reset() -> void:
	super.reset()
	_jump_attacked = false
	_loved = false


func kill() -> void:
	super.kill()
	# player logics here
	# sound > blast
	# vfx > blast


func reset_attack_state() -> void:
	attacking = false
	gravity = jump_gravity if jumping else default_gravity


func _locked_movement() -> bool:
	return _loved


func on_landed() -> void:
	add_vfx("impact_dusts")
	# sounds
	# player logics here


func on_jump() -> void:
	if jumping:
		return
	
	if grounded and not attacking:
		change_state("JUMP")


func on_attack() -> void:
	if dead or attacking or _jump_attacked:
		return
	
	change_state("ATTACK")


func on_kill() -> void:
	SceneManager.reload_scene()


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack_logic":
		_animation_player.play("default")
		reset_attack_state()


func _on_KillTimer_timeout():
	on_kill()

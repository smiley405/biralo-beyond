class_name BaseProjectile
extends Node2D


var type: String = ""
# Will be set from root level
var vfx_pool:VfxPool

var speed: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hitbox: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("vfx_targets")
	_animated_sprite.stop()


func _physics_process(delta: float) -> void:
	if not visible:
		return

	position += direction * speed * delta


func play() -> void:
	if _animated_sprite.is_playing():
		return
	_animated_sprite.play("default")


func activate(start_position: Vector2, shoot_direction: Vector2) -> void:
	position = start_position
	direction = shoot_direction.normalized()
	visible = true
	_hitbox.disabled = false
	play()


func deactivate() -> void:
	visible = false
	_hitbox.disabled = true


func kill() -> void:
	# Wait until physics processing is done, then call this
	call_deferred("deactivate")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player: Player = body as Player
		if not player.dead:
			player.receive_damage(1, self)
			kill()

	if body.is_in_group("platforms"):
		kill()

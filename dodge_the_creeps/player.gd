extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
@export var max_lives: int = 3
@export var invincible_time: float = 1.0

var lives: int
var _can_take_damage := true
@export var hits_label: Label

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	lives = max_lives
	if hits_label:
		hits_label.text = "Hits left: %d" % lives
 

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		rotation = PI if velocity.y > 0 else 0


func start(pos):
	position = pos
	rotation = 0
	lives = max_lives
	_can_take_damage = true
	show()
	if hits_label:
		hits_label.text = "Hits left: %d" % lives
	$CollisionShape2D.disabled = false


func _on_body_entered(_body):
	if not _can_take_damage:
		return

	lives -= 1
	if hits_label:
		hits_label.text = "Hits left: %d" % max(lives, 0)


	if lives <= 0:
		hide() # Player disappears after final hit
		hit.emit()
		$CollisionShape2D.set_deferred(&"disabled", true)
	else:
		# Temporary invincibility after being hit
		_can_take_damage = false
		modulate.a = 0.5
		await get_tree().create_timer(invincible_time).timeout
		modulate.a = 1.0
		_can_take_damage = true

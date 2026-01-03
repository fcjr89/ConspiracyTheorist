extends CharacterBody2D
# Attach to Player node in scene
# Requires: Sprite2D, CollisionShape2D

@export var speed := 120.0
@export var animation_speed := 6.0  # sprite frame speed

var current_direction := "down"
var is_moving := false
var sprite: Sprite2D
var anim_frame := 0
var frame_timer := 0.0

func _ready():
	sprite = get_node("Sprite2D")
	# Start with idle down sprite
	sprite.frame = 0

func _physics_process(dt):
	# Read input
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Update direction based on last input
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		_update_direction(input_vector)
		is_moving = true
	else:
		is_moving = false
	
	# Movement
	velocity = input_vector * speed
	move_and_slide()
	
	# Animation
	_update_animation(dt)

func _update_direction(direction: Vector2):
	"""Set direction and update sprite row"""
	if abs(direction.x) > abs(direction.y):
		current_direction = "right" if direction.x > 0 else "left"
	else:
		current_direction = "down" if direction.y > 0 else "up"

func _update_animation(dt):
	"""Cycle through sprite frames based on direction and movement"""
	if not sprite:
		return
	
	# Define frame ranges per direction (assuming 4 frames per direction)
	# Layout: row 0=down, 1=up, 2=left, 3=right (standard RPG layout)
	var frame_map = {
		"down": [0, 1, 2, 3],
		"up": [4, 5, 6, 7],
		"left": [8, 9, 10, 11],
		"right": [12, 13, 14, 15]
	}
	
	if is_moving:
		frame_timer += dt * animation_speed
		if frame_timer >= 1.0:
			frame_timer = 0.0
			anim_frame = (anim_frame + 1) % 4
		sprite.frame = frame_map[current_direction][anim_frame]
	else:
		# Idle frame (first frame of direction)
		anim_frame = 0
		sprite.frame = frame_map[current_direction][0]

func can_move() -> bool:
	"""Check if player is allowed to move (not in dialogue, battle, etc)"""
	return true  # Expand this later with pause checks

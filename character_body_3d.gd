extends CharacterBody3D

const TILE_SIZE := 2
const MOVE_SPEED := 4 # tiles per second

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_moving: bool = false
var target_position: Vector3
var last_dir: String = "down"

func _ready() -> void:
	# Snap player to grid at start
	global_position = _snap_to_grid(global_position)
	target_position = global_position

func _physics_process(delta: float) -> void:
	if is_moving:
		_move_towards_target(delta)
	else:
		_handle_input()
		
	if not is_on_floor():
		velocity.y -= 20 * delta
	else:
		velocity.y = 0
	move_and_slide()


func _handle_input() -> void:
	if is_moving:
		return  # ignore input while moving

	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_dir = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"):
		input_dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_down"):
		input_dir = Vector2.DOWN
	elif Input.is_action_pressed("ui_up"):
		input_dir = Vector2.UP

	if input_dir != Vector2.ZERO:
		var move_vec := Vector3(input_dir.x, 0, input_dir.y) * TILE_SIZE
		var new_target := global_position + move_vec

		# check if the tile is blocked
		if not test_move(transform, move_vec):
			target_position = new_target
			is_moving = true

			# animations
			match input_dir:
				Vector2.RIGHT:
					last_dir = "right"
					_play_anim("walk_right")
				Vector2.LEFT:
					last_dir = "left"
					_play_anim("walk_left")
				Vector2.DOWN:
					last_dir = "down"
					_play_anim("walk_down")
				Vector2.UP:
					last_dir = "up"
					_play_anim("walk_up")
	else:
		_play_anim("idle_" + last_dir)


func _move_towards_target(delta: float) -> void:
	var dir := (target_position - global_position).normalized()
	var step := dir * MOVE_SPEED * TILE_SIZE * delta

	# stop exactly on the tile, no overshoot
	if step.length() >= global_position.distance_to(target_position):
		global_position = target_position
		is_moving = false
	else:
		global_position += step



func _snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		round(pos.x / TILE_SIZE) * TILE_SIZE,
		pos.y,
		round(pos.z / TILE_SIZE) * TILE_SIZE
	)


func _play_anim(name: String) -> void:
	if animation_player.current_animation != name:
		animation_player.play(name)

extends CharacterBody3D

@export var SPEED : float = 8.0
@export var JUMP_VELOCITY : float = 9.5
@export var JUMP_COUNT : int = 5	#Known Bug: Modifying the jump count anywhere other than this line of code will not work
@export var DASH_SPEED : float = 16.0
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
var current_jump_count = JUMP_COUNT

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
func _input(event):
	
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
func _update_camera(delta):
	
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _ready():

	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _physics_process(delta):
	
	# Update camera movement based on mouse movement
	_update_camera(delta)
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if is_on_floor():
		current_jump_count = JUMP_COUNT
		
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and current_jump_count > 0:
		velocity.y = JUMP_VELOCITY
		current_jump_count -= 1
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = 0.0
	if Input.is_action_pressed("sprint"):
		current_speed = DASH_SPEED
	else:
		current_speed = SPEED
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func velocity_reset():
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0

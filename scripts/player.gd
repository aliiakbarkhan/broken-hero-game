extends CharacterBody3D

@onready var camera = $head/Camera3D
@onready var head = $head
@onready var standing_collision = $standing_collision
@onready var crouch_collision = $crouch_collision
@onready var gun_anim = $"head/Camera3D/Root Scene"

var SPEED_CURRENT = 5.0

const WALKING_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUNCH_SPEED = 3.0

const JUMP_VELOCITY = 4.5

const mouse_sen = 0.4

var LARP_SPEED = 10.0

var direction = Vector3.ZERO

var crouch_cam = -0.5

#bob variable
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sen))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sen))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89),deg_to_rad(89))


func _physics_process(delta):
	
	if Input.is_action_pressed("crouch"):
		SPEED_CURRENT = CROUNCH_SPEED
		head.position.y = lerp(head.position.y,1.8 + crouch_cam,delta*LARP_SPEED)
		standing_collision.disabled = true
		crouch_collision.disabled = false
		
	else:
		standing_collision.disabled = false
		crouch_collision.disabled = true
		head.position.y = lerp(head.position.y,1.8,delta*LARP_SPEED)

	if Input.is_action_pressed("sprint"):
		SPEED_CURRENT = SPRINT_SPEED
	else:
		SPEED_CURRENT = WALKING_SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*LARP_SPEED)
	
	if direction:
		velocity.x = direction.x * SPEED_CURRENT
		velocity.z = direction.z * SPEED_CURRENT
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_CURRENT)
		velocity.z = move_toward(velocity.z, 0, SPEED_CURRENT)

	#head bob
	t_bob+= delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos

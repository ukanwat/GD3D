extends KinematicBody

export (float) var NORMAL_SPEED: float = 10
export (float) var JUMP_FORCE: float = 10
export (Vector3) var GRAVITY: Vector3 = Vector3.DOWN * 15
export (float) var MOUSE_SENSIVITY: float = 0.3
export (float, 0, 200) var inertia: float = 0.5

var velocity: Vector3 = Vector3.ZERO
var is_jumping: bool = false
var can_shoot: bool = true

onready var bullet: PackedScene = preload("res://Bullet.tscn")
onready var CAMERA: Camera = $Camera

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _process(delta: float) -> void:
	_input_move()
	_input_shoot()
	pass

func _input_move() -> void:
	var input = Vector3.ZERO
	var speed = NORMAL_SPEED
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_FORCE
		is_jumping = true
	else: is_jumping = false
	
	# Move
	if Input.is_action_pressed("run") and is_on_floor(): speed = NORMAL_SPEED * 1.5
		
	if Input.is_action_pressed("move_forward"): input += -speed * transform.basis.z
	if Input.is_action_pressed("move_backward"): input += speed * transform.basis.z
	
	if Input.is_action_pressed("move_left"): input += -speed * transform.basis.x
	if Input.is_action_pressed("move_right"): input += speed * transform.basis.x
	
	velocity.x = input.x
	velocity.z = input.z
	pass

func _input_shoot() -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		
		$ShootCooldown.start()
		
		var new_bullet = bullet.instance()
		
		get_tree().root.add_child(new_bullet)
		new_bullet.global_translation = $Camera/gun.global_translation
		
		var direction = ($Camera/bullet_direction.global_translation - $Camera/gun.global_translation).normalized()
		new_bullet.apply_central_impulse(direction * 75)
		pass
	pass

func _physics_process(delta: float) -> void:
	velocity += GRAVITY * delta
	
	var snap_vector = Vector3.DOWN if not is_jumping else Vector3.ZERO
	
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 10, deg2rad(70), true)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bouce_object"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * MOUSE_SENSIVITY))
		CAMERA.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSIVITY))
		CAMERA.rotation.x = clamp(CAMERA.rotation.x , deg2rad(-90), deg2rad(90))
		
	if Input.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().set_input_as_handled()
		pass
		
	if Input.is_action_just_pressed("click") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _on_ShootCooldown_timeout() -> void:
	can_shoot = true
	pass

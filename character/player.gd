extends CharacterBody2D


@export var speed: float = 200.0
@export var jump_velocity: float = -200.0
@export var double_jump_velocity: float = -100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump: bool=false
var animation_lock: bool = false
var direction: Vector2 = Vector2.ZERO
var was_in_air:bool = false
var is_landed: bool = false



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else: 
		has_double_jump = false
		
		if was_in_air == true:
			landed()
			
		was_in_air= false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			# normal jump
			jump()
		elif not has_double_jump:
			double_jump()
			
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if direction.x != 0 && animated_sprite.animation != "jump_end":
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	if not animation_lock:
		if not is_on_floor():
			animated_sprite.play("jump_loop")
		else:
			if direction.x != 0:
				animated_sprite.play("run")
			else:
				animated_sprite.play("idle")
			

func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true 
		
func jump():
	velocity.y = jump_velocity
	animated_sprite.play("jump_start")
	animation_lock = true
	
func double_jump():
	velocity.y = double_jump_velocity
	animated_sprite.play("jump_double")
	has_double_jump = true
	animation_lock = true
	
	
func landed():
	animated_sprite.play("jump_end")
	animation_lock = true
	

func _on_animated_sprite_2d_animation_finished():
	if(["jump_start","jump_end","jump_double"]).has(animated_sprite.animation):
		animation_lock = false
	

extends KinematicBody2D

export (PackedScene) var Bullet

export (String) var up = "ui_up"
export (String) var down = "ui_down"
export (String) var left = "ui_left"
export (String) var right = "ui_right"
export (String) var action = "ui_action"
export (String) var command = "ui_command"

signal toogle_command()
signal use_hatch()
signal dead()

var command_av : bool = false
var hatch_av : bool = false

const I = "player"

enum S { #status
	ILeft, # I stand for input
	IRight,
	IUp,
	IDown,
	IFiring,
	ICommand,
	INone,
	LLeft, # L stand for look at
	LRight,
	PWalking, # P stand for physic 
	PFalling,
	PAcceleratingFall,
	PJumping,
	PIdle,
	ANone, # A stand for action
	AFiring,
	CFloor, # C stand for contact
	CCeil,
	CWall,
	CNone
}

var istatus = {}
var lstatus = S.LRight
var pstatus = S.PIdle
var astatus = S.ANone
var cstatus = S.CFloor

# Member variables
const GRAVITY = 500.0 # pixels/second/second

const STOP_FORCE = 1300

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40

const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200

const JUMP_SPEED = 350
const JUMP_MAX_AIRBORNE_TIME = 0.1

const FALL_FORCE = 3000
const FALL_MIN_SPEED = 10
const FALL_MAX_SPEED = 1000

const CEIL_FALL_FORCE = 5000
const CEIL_JUMP_SPEED = 50

const WALL_WALK_FORCE = 1000
const WALL_JUMP_SPEED = 200

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var force = Vector2()

var on_air_time = 100

var prev_jump_pressed = false
var rest_time = 0

var firing_direction = "none"

var bullet_spawn_position = {
	"left" : Vector2(-11,4),
	"right" : Vector2(10,4),
	"right_up" : Vector2(-4,-16),
	"right_down" : Vector2(-1,17),
	"left_up" : Vector2(5,-16),
	"left_down" : Vector2(2,17)
}

const fire_rate = 5
var elapsed_time_since_last_fire = 1.0/fire_rate

func command_available():
	command_av = true

func command_unavailable():
	command_av = false
	
func hatch_available():
	print("hatch_available")
	hatch_av = true

func hatch_unavailable():
	print("hatch_unavailable")
	hatch_av = false


func _fire():
	if istatus[S.IFiring]:
		if elapsed_time_since_last_fire >= 1.0/fire_rate and firing_direction != "none":
			elapsed_time_since_last_fire = 0
			var bullet = Bullet.instance()
			bullet.direction = firing_direction
			var lpre = ""
			
			if firing_direction == "left":
				bullet.set_rotation_degrees(180)
			elif firing_direction == "up":
				bullet.set_rotation_degrees(-90)
			elif firing_direction == "down":
				bullet.set_rotation_degrees(90)
			
			if firing_direction != "left" and firing_direction != "right":
				if lstatus == S.LLeft:
					lpre = "left_"
				else:
					lpre = "right_"
			bullet.position = bullet_spawn_position[lpre+firing_direction]+position
			get_parent().add_child(bullet)
		
	

func _ready():
	pass
	
	
func _inputs_process(delta):
	istatus = {
		S.IFiring : false,
		S.ILeft : false,
		S.IRight : false,
		S.IUp : false,
		S.IDown : false,
		S.ICommand : false
	}
	
	if Input.is_action_pressed(action):
		istatus[S.IFiring] = true
		
	if Input.is_action_pressed(left):
		istatus[S.ILeft] = true
		lstatus = S.LLeft
	elif Input.is_action_pressed(right):
		istatus[S.IRight] = true
		lstatus = S.LRight
		
	if Input.is_action_pressed(up):
		istatus[S.IUp] = true
	elif Input.is_action_pressed(down):
		istatus[S.IDown] = true
		
	if Input.is_action_just_pressed(command):
		istatus[S.ICommand] = true
		if command_av:
			emit_signal("toogle_command")
		elif hatch_av:
			emit_signal("use_hatch")

func _xvelocity_process(delta):
	var stop = true

	if istatus[S.ILeft] and not istatus[S.IFiring] :
		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
			if cstatus == S.CWall:
				force.x -= WALL_WALK_FORCE
				velocity.x -= WALL_JUMP_SPEED
			else:
				force.x -= WALK_FORCE
			stop = false

	elif istatus[S.IRight] and not istatus[S.IFiring]:
		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
			if cstatus == S.CWall:
				force.x += WALL_WALK_FORCE
				velocity.x += WALL_JUMP_SPEED
			else:
				force.x += WALK_FORCE
			stop = false

	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)

		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
			if cstatus == S.CFloor or cstatus == S.CWall:
				pstatus = S.PIdle
		else:
			if cstatus == S.CFloor or cstatus == S.CWall:
				pstatus = S.PWalking

		velocity.x = vlen * vsign
		
	else:
		if cstatus == S.CFloor or cstatus == S.CWall:
			pstatus = S.PWalking
	
func _yvelocity_process(delta):
	if pstatus == S.PJumping and velocity.y > 0:
		# If falling, no longer jumping
		pstatus = S.PFalling
	
	if pstatus == S.PFalling or pstatus == S.PAcceleratingFall or pstatus == S.PJumping:
		if istatus[S.IDown] and not istatus[S.IFiring]:
			if velocity.y >= -FALL_MIN_SPEED and velocity.y < FALL_MAX_SPEED:
				if cstatus == S.CCeil:
					force.y += CEIL_FALL_FORCE
				else:
					force.y += FALL_FORCE
			pstatus = S.PAcceleratingFall
		on_air_time += delta
				

	elif (pstatus == S.PIdle or pstatus == S.PWalking) and istatus[S.IUp] and not istatus[S.IFiring]:
		if on_air_time < JUMP_MAX_AIRBORNE_TIME:
			if not prev_jump_pressed:
				# Jump must also be allowed to happen if the character left the floor a little bit ago.
				# Makes controls more snappy.
				if cstatus == S.CWall:
					velocity.y = -WALL_JUMP_SPEED
				else:
					velocity.y = -JUMP_SPEED
			pstatus = S.PJumping

	prev_jump_pressed = istatus[S.IUp]

func _change_animation(animation):
	if $AnimatedSprite.animation != animation:
		$AnimatedSprite.animation = animation 
		$AnimatedSprite.playing = true
	
func _animate(delta):
	if lstatus == S.LLeft:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

	
	if istatus[S.IFiring]:
		if istatus[S.IUp]:
			_change_animation("firing_up")
			firing_direction = "up"
		elif istatus[S.IDown]:
			_change_animation("firing_down")
			firing_direction = "down"
		else:
			_change_animation("firing")
			if lstatus == S.LLeft:
				firing_direction = "left"
			else:
				firing_direction = "right"
	elif pstatus == S.PIdle:
		_change_animation("idle")
	elif pstatus == S.PFalling:
		_change_animation("falling")
	elif pstatus == S.PJumping:
		_change_animation("jumping")
	elif pstatus == S.PWalking:
		_change_animation("walking")
	elif pstatus == S.PAcceleratingFall:
		_change_animation("accelerating_fall")

	
	
func _physics_process(delta):
	elapsed_time_since_last_fire+= delta
	force = Vector2(0, GRAVITY)
	_inputs_process(delta)
	_xvelocity_process(delta)
	_yvelocity_process(delta)
	
	# Integrate forces to velocity
	velocity += force * delta
	# Integrate velocity into motion and move
	var collision = move_and_collide(velocity*delta)
	if collision:
		if(collision.normal.y < 0):
			cstatus = S.CFloor
			on_air_time = 0
		elif(collision.normal.y > 0 and collision.normal.x < 0.1 and collision.normal.x > -0.1):
			cstatus = S.CCeil
		elif(collision.normal.x > 0.9 or collision.normal.x < -0.9 and collision.normal.y < 0.1):
			cstatus = S.CWall
			on_air_time = 0
		else:
			cstatus = S.CNone

		velocity = velocity.slide(collision.normal)
	else:
		cstatus = S.CNone
		
	_animate(delta)
	_fire()
	
func hitten():
	emit_signal("dead")
	$AnimatedSprite.animation = "dead"
	set_physics_process(false)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "dead":
		get_parent().remove_child(self)

func receive_message_from_screen(message):
	print (message)
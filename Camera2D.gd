extends Camera2D

# Code based on "Camera Setup for 2D Top Down (Isometric) Game in Godot"
# Link: https://www.youtube.com/watch?v=viyRI66gY18

# Sets map panning speed (larger is faster)
const PAN_SPEED = 500

var viewport_size
var cam_x
var cam_y

# Sets camera (x, y) to middle of screen scaled by current zoom level
func _ready():
	viewport_size = get_viewport().size
	cam_x = (viewport_size.x / 2) * self.zoom.x
	cam_y = (viewport_size.y / 2) * self.zoom.y

func _process(delta):
	var move_vector = Vector2()
	
	# Horizontal map panning via keyboard
	if Input.is_action_pressed("pan_left") && self.position.x - cam_x > self.limit_left:
		move_vector.x -= 1
	elif Input.is_action_pressed("pan_right") && self.position.x + cam_x < self.limit_right:
		move_vector.x += 1

	# Vertical map panning via keyboard
	if Input.is_action_pressed("pan_up") && self.position.y - cam_y > self.limit_top:
		move_vector.y -= 1
	elif Input.is_action_pressed("pan_down") && self.position.y + cam_y < self.limit_bottom:
		move_vector.y += 1

	# Zooming out via keyboard
	if Input.is_action_just_released("zoom_out") && self.zoom.x < 1.5:
		self.zoom.x += 0.25
		self.zoom.y += 0.25
		
		viewport_size = get_viewport().size
		cam_x = (viewport_size.x / 2) * self.zoom.x
		cam_y = (viewport_size.y / 2) * self.zoom.y
		
		# Checks if after zooming out the camera is outside horizontal limit
		if self.position.x - cam_x < self.limit_left:
			self.position.x += self.limit_left + (self.position.x - cam_x) * -1
		elif self.position.x + cam_x > self.limit_right:
			self.position.x -= self.position.x + cam_x - self.limit_right
			
		# Checks if after zooming out the camera is outside vertical limit
		if self.position.y - cam_y < self.limit_top:
			self.position.y += self.limit_top + (self.position.y - cam_y) * -1
		elif self.position.y + cam_y > self.limit_bottom:
			self.position.y -= self.position.y + cam_y - self.limit_bottom
	
	# Zooming in via keyboard
	elif Input.is_action_just_released("zoom_in") && self.zoom.x > 0.25:
		self.zoom.x -= 0.25
		self.zoom.y -= 0.25
		
		viewport_size = get_viewport().size
		cam_x = (viewport_size.x / 2) * self.zoom.x
		cam_y = (viewport_size.y / 2) * self.zoom.y
	
	# Enables map panning using the mouse on screen edge (maybe don't use?)
	# var mouse_pos = get_viewport().get_mouse_position()
	# const MOUSE_PAN_BUFFER
	# if mouse_pos.x < MOUSE_PAN_BUFFER && self.position.x - cam_x > self.limit_left:
	#	move_vector.x = -1
	# elif mouse_pos.x > viewport_size.x - MOUSE_PAN_BUFFER && self.position.x + cam_x < self.limit_right:
	#	move_vector.x = 1
	
	# if mouse_pos.y < MOUSE_PAN_BUFFER && self.position.y - cam_y > self.limit_top:
	#	move_vector.y = -1
	# elif mouse_pos.y > viewport_size.y - MOUSE_PAN_BUFFER && self.position.y + cam_y < self.limit_bottom:
	#	move_vector.y = 1

	# Move the camera based on changes to vector, scaled by zoom level
	global_translate(move_vector * delta * PAN_SPEED * self.zoom.x)
